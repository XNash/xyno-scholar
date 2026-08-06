import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xyno_scholar/models/enums.dart';
import 'package:xyno_scholar/models/preference_block.dart';
import 'package:xyno_scholar/services/cerebras_client.dart';

/// Encodes [fullContent] as a sequence of OpenAI-style SSE `data:` chunks,
/// split into a few fragments to exercise the accumulation logic, terminated
/// by `data: [DONE]`.
String _sseEncode(String fullContent, {int chunkSize = 37}) {
  final buffer = StringBuffer();
  for (var i = 0; i < fullContent.length; i += chunkSize) {
    final end = (i + chunkSize < fullContent.length)
        ? i + chunkSize
        : fullContent.length;
    final chunk = fullContent.substring(i, end);
    final event = jsonEncode({
      'choices': [
        {
          'delta': {'content': chunk},
        },
      ],
    });
    buffer.write('data: $event\n\n');
  }
  buffer.write('data: [DONE]\n\n');
  return buffer.toString();
}

final _preferences = PreferenceBlock(
  fields: const ['history', 'art'],
  level: AcademicLevel.licence,
  tone: Tone.neutral,
  scope: Scope.broad,
  mood: Mood.curious,
  excludedFields: const [],
  language: 'en',
);

void main() {
  test(
    'generate() parses a streamed broad-scope response and reports progress',
    () async {
      final broadJson = jsonEncode({
        'scope': 'broad',
        'language': 'en',
        'fieldsCovered': ['history', 'art'],
        'clarifyingQuestion': null,
        'broadTopics': [
          {
            'id': 't1',
            'title': 'Test Topic',
            'whyFitsAllFields': 'It fits.',
            'fieldsCovered': ['history', 'art'],
            'keyKeywords': ['keyword'],
          },
        ],
        'narrowTopic': null,
      });

      final capturedBodies = <Map<String, dynamic>>[];
      final mockClient = MockClient((request) async {
        capturedBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response(
          _sseEncode(broadJson),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final client = CerebrasClient(httpClient: mockClient);
      final progressSamples = <int>[];

      final response = await client.generate(
        apiKey: 'test-key',
        prefs: _preferences,
        onProgress: progressSamples.add,
      );

      expect(response.scope, 'broad');
      expect(response.broadTopics, hasLength(1));
      expect(response.broadTopics.first.title, 'Test Topic');

      // Progress should have been reported at least once, strictly
      // increasing, and end at the full content length.
      expect(progressSamples, isNotEmpty);
      for (var i = 1; i < progressSamples.length; i++) {
        expect(progressSamples[i], greaterThan(progressSamples[i - 1]));
      }
      expect(progressSamples.last, broadJson.length);

      // Confirm the exact request parameters specified for this integration.
      expect(capturedBodies, hasLength(1));
      final capturedBody = capturedBodies.single;
      expect(capturedBody['model'], 'zai-glm-4.7');
      expect(capturedBody['stream'], true);
      expect(capturedBody['max_tokens'], 65000);
      expect(capturedBody['temperature'], 1.0);
      expect(capturedBody['top_p'], 0.95);
    },
  );

  test('generate() parses a streamed narrow-scope response', () async {
    final narrowJson = jsonEncode({
      'scope': 'narrow',
      'language': 'en',
      'fieldsCovered': ['history', 'art'],
      'clarifyingQuestion': null,
      'broadTopics': [],
      'narrowTopic': {
        'id': 'n1',
        'title': 'Narrow Title',
        'pitch': 'A pitch.',
        'problematique': 'A problematique.',
        'levelNotes': 'Notes.',
        'fieldsIntersectionExplanation': 'Explanation.',
        'starterBibliography': [
          {
            'authors': 'Author A',
            'year': '2001',
            'title': 'Book One',
            'publication': 'Publisher',
            'type': 'book',
            'relevance': 'Relevant.',
          },
          {
            'authors': 'Author B',
            'year': '2002',
            'title': 'Article Two',
            'publication': 'Journal',
            'type': 'article',
            'relevance': 'Relevant.',
          },
          {
            'authors': 'Author C',
            'year': '2003',
            'title': 'Source Three',
            'publication': 'Archive',
            'type': 'primary_source',
            'relevance': 'Relevant.',
          },
        ],
        'suggestedStructure': [
          {'partNumber': 'I', 'title': 'Part I', 'description': 'Desc I'},
          {'partNumber': 'II', 'title': 'Part II', 'description': 'Desc II'},
          {'partNumber': 'III', 'title': 'Part III', 'description': 'Desc III'},
        ],
      },
    });

    final mockClient = MockClient((request) async {
      return http.Response(
        _sseEncode(narrowJson),
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });

    final client = CerebrasClient(httpClient: mockClient);
    final response = await client.generate(
      apiKey: 'test-key',
      prefs: _preferences.copyWith(scope: Scope.narrow),
    );

    expect(response.scope, 'narrow');
    expect(response.narrowTopic, isNotNull);
    expect(response.narrowTopic!.starterBibliography, hasLength(3));
    expect(response.narrowTopic!.suggestedStructure, hasLength(3));
  });

  test(
    'generate() retries once when the first stream is not valid JSON',
    () async {
      var callCount = 0;
      final validJson = jsonEncode({
        'scope': 'broad',
        'language': 'en',
        'fieldsCovered': ['history'],
        'clarifyingQuestion': null,
        'broadTopics': <Map<String, dynamic>>[],
        'narrowTopic': null,
      });

      final mockClient = MockClient((request) async {
        callCount++;
        final content = callCount == 1 ? 'this is not JSON at all' : validJson;
        return http.Response(
          _sseEncode(content),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final client = CerebrasClient(httpClient: mockClient);
      final response = await client.generate(
        apiKey: 'test-key',
        prefs: _preferences,
      );

      expect(callCount, 2);
      expect(response.scope, 'broad');
    },
  );

  test(
    'generate() throws after a second invalid-JSON stream (retry exhausted)',
    () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          _sseEncode('still not JSON'),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final client = CerebrasClient(httpClient: mockClient);
      expect(
        () => client.generate(apiKey: 'test-key', prefs: _preferences),
        throwsA(isA<CerebrasApiException>()),
      );
    },
  );

  test('generate() throws ApiKeyRejectedException on 401', () async {
    final mockClient = MockClient((request) async {
      return http.Response('', 401);
    });

    final client = CerebrasClient(httpClient: mockClient);
    expect(
      () => client.generate(apiKey: 'bad-key', prefs: _preferences),
      throwsA(isA<ApiKeyRejectedException>()),
    );
  });
}
