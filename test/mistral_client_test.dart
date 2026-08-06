import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xyno_scholar/models/enums.dart';
import 'package:xyno_scholar/models/narrow_topic.dart';
import 'package:xyno_scholar/models/preference_block.dart';
import 'package:xyno_scholar/services/mistral_client.dart';

/// Wraps [content] the way an OpenAI-compatible `chat/completions` response
/// does (the shape returned by the relay Worker, unchanged from Mistral).
http.Response _chatCompletionResponse(String content) {
  return http.Response(
    jsonEncode({
      'choices': [
        {
          'message': {'role': 'assistant', 'content': content},
        },
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
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
    'generate() parses a broad-scope response and posts the specified request config',
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

      final capturedRequests = <http.Request>[];
      final mockClient = MockClient((request) async {
        capturedRequests.add(request);
        return _chatCompletionResponse(broadJson);
      });

      final client = MistralClient(httpClient: mockClient);
      final response = await client.generate(
        apiKey: 'test-key',
        prefs: _preferences,
      );

      expect(response.scope, 'broad');
      expect(response.broadTopics, hasLength(1));
      expect(response.broadTopics.first.title, 'Test Topic');

      expect(capturedRequests, hasLength(1));
      final request = capturedRequests.single;
      expect(request.headers['Authorization'], 'Bearer test-key');
      expect(request.headers['x-goog-api-key'], isNull);

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['model'], 'mistral-large-latest');
      expect(body['response_format'], {'type': 'json_object'});
      expect(body.containsKey('stream'), isFalse);
      expect((body['messages'] as List).first['role'], 'system');
    },
  );

  test('generate() parses a narrow-scope response', () async {
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
      return _chatCompletionResponse(narrowJson);
    });

    final client = MistralClient(httpClient: mockClient);
    final response = await client.generate(
      apiKey: 'test-key',
      prefs: _preferences.copyWith(scope: Scope.narrow),
    );

    expect(response.scope, 'narrow');
    expect(response.narrowTopic, isNotNull);
    expect(response.narrowTopic!.starterBibliography, hasLength(3));
    expect(response.narrowTopic!.suggestedStructure, hasLength(3));
  });

  test('refine() returns the updated topic with a refinementSummary', () async {
    final refinedJson = jsonEncode({
      'scope': 'narrow',
      'language': 'en',
      'fieldsCovered': ['history'],
      'clarifyingQuestion': null,
      'broadTopics': [],
      'narrowTopic': {
        'id': 'n1',
        'title': 'Refined Title',
        'pitch': 'A refined pitch.',
        'problematique': 'A refined problematique.',
        'levelNotes': 'Notes.',
        'fieldsIntersectionExplanation': 'Explanation.',
        'starterBibliography': [
          {
            'authors': 'A',
            'year': '2001',
            'title': 'T1',
            'publication': 'P1',
            'type': 'book',
            'relevance': 'R',
          },
          {
            'authors': 'B',
            'year': '2002',
            'title': 'T2',
            'publication': 'P2',
            'type': 'article',
            'relevance': 'R',
          },
          {
            'authors': 'C',
            'year': '2003',
            'title': 'T3',
            'publication': 'P3',
            'type': 'primary_source',
            'relevance': 'R',
          },
        ],
        'suggestedStructure': [
          {'partNumber': 'I', 'title': 'P1', 'description': 'D1'},
          {'partNumber': 'II', 'title': 'P2', 'description': 'D2'},
          {'partNumber': 'III', 'title': 'P3', 'description': 'D3'},
        ],
        'refinementSummary': 'Shifted the period to the 18th century.',
      },
    });

    final mockClient = MockClient((request) async {
      return _chatCompletionResponse(refinedJson);
    });

    final client = MistralClient(httpClient: mockClient);
    final updated = await client.refine(
      apiKey: 'test-key',
      prefs: _preferences.copyWith(scope: Scope.narrow),
      currentTopic: NarrowTopic.fromJson(
        jsonDecode(refinedJson)['narrowTopic'] as Map<String, dynamic>,
      ),
      refinementInstruction: 'Shift the period to the 18th century',
    );

    expect(updated.title, 'Refined Title');
    expect(
      updated.refinementSummary,
      'Shifted the period to the 18th century.',
    );
  });

  test('generate() strips markdown code fences before parsing', () async {
    final validJson = jsonEncode({
      'scope': 'broad',
      'language': 'en',
      'fieldsCovered': ['history'],
      'clarifyingQuestion': null,
      'broadTopics': <Map<String, dynamic>>[],
      'narrowTopic': null,
    });

    final mockClient = MockClient((request) async {
      return _chatCompletionResponse('```json\n$validJson\n```');
    });

    final client = MistralClient(httpClient: mockClient);
    final response = await client.generate(
      apiKey: 'test-key',
      prefs: _preferences,
    );

    expect(response.scope, 'broad');
  });

  test(
    'generate() retries once when the first response is not valid JSON',
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
        return _chatCompletionResponse(
          callCount == 1 ? 'this is not JSON at all' : validJson,
        );
      });

      final client = MistralClient(httpClient: mockClient);
      final response = await client.generate(
        apiKey: 'test-key',
        prefs: _preferences,
      );

      expect(callCount, 2);
      expect(response.scope, 'broad');
    },
  );

  test(
    'generate() throws after a second invalid-JSON response (retry exhausted)',
    () async {
      final mockClient = MockClient((request) async {
        return _chatCompletionResponse('still not JSON');
      });

      final client = MistralClient(httpClient: mockClient);
      expect(
        () => client.generate(apiKey: 'test-key', prefs: _preferences),
        throwsA(isA<MistralApiException>()),
      );
    },
  );

  test('generate() throws ApiKeyRejectedException on 401', () async {
    final mockClient = MockClient((request) async {
      return http.Response('{"error":"invalid api key"}', 401);
    });

    final client = MistralClient(httpClient: mockClient);
    expect(
      () => client.generate(apiKey: 'bad-key', prefs: _preferences),
      throwsA(isA<ApiKeyRejectedException>()),
    );
  });

  test('generate() throws ApiKeyRejectedException on 403', () async {
    final mockClient = MockClient((request) async {
      return http.Response('{"error":"forbidden"}', 403);
    });

    final client = MistralClient(httpClient: mockClient);
    expect(
      () => client.generate(apiKey: 'bad-key', prefs: _preferences),
      throwsA(isA<ApiKeyRejectedException>()),
    );
  });
}
