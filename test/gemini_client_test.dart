import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:xyno_scholar/models/enums.dart';
import 'package:xyno_scholar/models/narrow_topic.dart';
import 'package:xyno_scholar/models/preference_block.dart';
import 'package:xyno_scholar/services/gemini_client.dart';

/// Wraps [innerJsonText] the way Gemini's `generateContent` response does
/// when `responseMimeType: "application/json"` is set: the model's JSON
/// output arrives as the `text` of the first candidate's first part.
http.Response _generateContentResponse(String innerJsonText) {
  return http.Response(
    jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': innerJsonText},
            ],
            'role': 'model',
          },
          'finishReason': 'STOP',
        },
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

http.Response _errorResponse(
  int statusCode, {
  String status = 'INVALID_ARGUMENT',
  String message = 'Something went wrong.',
  List<Map<String, dynamic>>? details,
}) {
  return http.Response(
    jsonEncode({
      'error': {
        'code': statusCode,
        'message': message,
        'status': status,
        if (details != null) 'details': details,
      },
    }),
    statusCode,
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
    'generate() parses a broad-scope response and sends the specified request config',
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
        return _generateContentResponse(broadJson);
      });

      final client = GeminiClient(httpClient: mockClient);
      final response = await client.generate(
        apiKey: 'test-key',
        prefs: _preferences,
      );

      expect(response.scope, 'broad');
      expect(response.broadTopics, hasLength(1));
      expect(response.broadTopics.first.title, 'Test Topic');

      expect(capturedRequests, hasLength(1));
      final request = capturedRequests.single;
      expect(
        request.url.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent',
      );
      expect(request.headers['x-goog-api-key'], 'test-key');
      expect(request.headers['Authorization'], isNull);

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['systemInstruction'], isNotNull);
      expect(body.containsKey('stream'), isFalse);
      final config = body['generationConfig'] as Map<String, dynamic>;
      expect(config['temperature'], 1.0);
      expect(config['topP'], 0.95);
      expect(config['maxOutputTokens'], 65000);
      expect(config['responseMimeType'], 'application/json');
      expect(config['responseSchema'], isNotNull);
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
      return _generateContentResponse(narrowJson);
    });

    final client = GeminiClient(httpClient: mockClient);
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
      return _generateContentResponse(refinedJson);
    });

    final client = GeminiClient(httpClient: mockClient);
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
        return _generateContentResponse(
          callCount == 1 ? 'this is not JSON at all' : validJson,
        );
      });

      final client = GeminiClient(httpClient: mockClient);
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
        return _generateContentResponse('still not JSON');
      });

      final client = GeminiClient(httpClient: mockClient);
      expect(
        () => client.generate(apiKey: 'test-key', prefs: _preferences),
        throwsA(isA<GeminiApiException>()),
      );
    },
  );

  test('generate() throws ApiKeyRejectedException on 403', () async {
    final mockClient = MockClient((request) async {
      return _errorResponse(
        403,
        status: 'PERMISSION_DENIED',
        message: 'Permission denied.',
      );
    });

    final client = GeminiClient(httpClient: mockClient);
    expect(
      () => client.generate(apiKey: 'bad-key', prefs: _preferences),
      throwsA(isA<ApiKeyRejectedException>()),
    );
  });

  test(
    'generate() throws ApiKeyRejectedException on 400 API_KEY_INVALID',
    () async {
      final mockClient = MockClient((request) async {
        return _errorResponse(
          400,
          message: 'API key not valid. Please pass a valid API key.',
          details: [
            {
              '@type': 'type.googleapis.com/google.rpc.ErrorInfo',
              'reason': 'API_KEY_INVALID',
              'domain': 'googleapis.com',
            },
          ],
        );
      });

      final client = GeminiClient(httpClient: mockClient);
      expect(
        () => client.generate(apiKey: 'bad-key', prefs: _preferences),
        throwsA(
          isA<ApiKeyRejectedException>().having(
            (e) => e.message,
            'message',
            contains('API key'),
          ),
        ),
      );
    },
  );

  test(
    'generate() surfaces a plain 400 (unrelated to the key) as GeminiApiException',
    () async {
      final mockClient = MockClient((request) async {
        return _errorResponse(
          400,
          message: 'Request contains an invalid argument.',
        );
      });

      final client = GeminiClient(httpClient: mockClient);
      expect(
        () => client.generate(apiKey: 'test-key', prefs: _preferences),
        throwsA(isA<GeminiApiException>()),
      );
    },
  );
}
