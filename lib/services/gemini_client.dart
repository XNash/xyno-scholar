import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/preference_block.dart';
import '../models/generation_response.dart';
import '../models/narrow_topic.dart';
import 'sanitize.dart';

/// Thrown when Gemini rejects the API key (400 API_KEY_INVALID, 401, or
/// 403). The caller should clear the key and return to the unlock screen.
class ApiKeyRejectedException implements Exception {
  final String message;
  const ApiKeyRejectedException([this.message = 'Your API key was rejected.']);
  @override
  String toString() => message;
}

/// Any other failure talking to Gemini (network, malformed response, etc).
/// The message is always safe to show the user — it never includes the key.
class GeminiApiException implements Exception {
  final String message;
  const GeminiApiException(this.message);
  @override
  String toString() => message;
}

/// Gemini `Schema` (a constrained subset of OpenAPI) describing exactly the
/// shape of [BibliographyEntry].
const Map<String, dynamic> _bibliographyEntrySchema = {
  'type': 'OBJECT',
  'properties': {
    'authors': {'type': 'STRING'},
    'year': {'type': 'STRING'},
    'title': {'type': 'STRING'},
    'publication': {'type': 'STRING'},
    'type': {
      'type': 'STRING',
      'enum': ['book', 'article', 'primary_source'],
    },
    'relevance': {'type': 'STRING'},
  },
  'required': ['authors', 'year', 'title', 'publication', 'type', 'relevance'],
};

/// Mirrors [OutlinePart].
const Map<String, dynamic> _outlinePartSchema = {
  'type': 'OBJECT',
  'properties': {
    'partNumber': {
      'type': 'STRING',
      'enum': ['I', 'II', 'III'],
    },
    'title': {'type': 'STRING'},
    'description': {'type': 'STRING'},
  },
  'required': ['partNumber', 'title', 'description'],
};

/// Mirrors [BroadTopic].
const Map<String, dynamic> _broadTopicSchema = {
  'type': 'OBJECT',
  'properties': {
    'id': {'type': 'STRING'},
    'title': {'type': 'STRING'},
    'whyFitsAllFields': {'type': 'STRING'},
    'fieldsCovered': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
    'keyKeywords': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
  },
  'required': [
    'id',
    'title',
    'whyFitsAllFields',
    'fieldsCovered',
    'keyKeywords',
  ],
};

/// Mirrors [NarrowTopic] (minus [NarrowTopic.refinementSummary], which is
/// only ever populated by the refine flow and is therefore left optional).
const Map<String, dynamic> _narrowTopicSchema = {
  'type': 'OBJECT',
  'nullable': true,
  'properties': {
    'id': {'type': 'STRING'},
    'title': {'type': 'STRING'},
    'pitch': {'type': 'STRING'},
    'problematique': {'type': 'STRING'},
    'levelNotes': {'type': 'STRING'},
    'fieldsIntersectionExplanation': {'type': 'STRING'},
    'starterBibliography': {
      'type': 'ARRAY',
      'items': _bibliographyEntrySchema,
      'minItems': 3,
      'maxItems': 3,
    },
    'suggestedStructure': {
      'type': 'ARRAY',
      'items': _outlinePartSchema,
      'minItems': 3,
      'maxItems': 3,
    },
    'refinementSummary': {'type': 'STRING', 'nullable': true},
  },
  'required': [
    'id',
    'title',
    'pitch',
    'problematique',
    'levelNotes',
    'fieldsIntersectionExplanation',
    'starterBibliography',
    'suggestedStructure',
  ],
};

/// Mirrors [GenerationResponse] — the single top-level shape returned by
/// every call (generate and refine alike).
const Map<String, dynamic> _responseSchema = {
  'type': 'OBJECT',
  'properties': {
    'scope': {
      'type': 'STRING',
      'enum': ['broad', 'narrow'],
    },
    'language': {'type': 'STRING'},
    'fieldsCovered': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
    'clarifyingQuestion': {'type': 'STRING', 'nullable': true},
    'broadTopics': {
      'type': 'ARRAY',
      'items': _broadTopicSchema,
      'minItems': 0,
      'maxItems': 8,
    },
    'narrowTopic': _narrowTopicSchema,
  },
  'required': ['scope', 'language', 'fieldsCovered', 'broadTopics'],
};

class GeminiClient {
  static const _model = 'gemini-3.6-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const _temperature = 1.0;
  static const _topP = 0.95;
  static const _maxOutputTokens = 65000;

  final http.Client _http;

  GeminiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  void dispose() => _http.close();

  String _systemPrompt(PreferenceBlock prefs) {
    final fieldsList = prefs.fields.join(', ');
    final excludedList = prefs.excludedFields.isEmpty
        ? '(none)'
        : prefs.excludedFields.join(', ');

    return '''
You are a research-topic advisor helping an undergraduate ("licence"-level and above) scholar find interdisciplinary research subjects. Follow these rules strictly, without exception:

1. Never drop a selected field. The user has selected exactly these fields: [$fieldsList]. EVERY proposed subject must genuinely engage ALL of these fields substantively — not merely be superficially compatible with them.
2. Never add a field the user did not select, and never assume one field implies another (e.g. theology does not imply art, history does not imply theology, etc). Fields to actively avoid, if any: [$excludedList].
3. If the user's free-text input conflicts with, or implies, a field that is NOT in the selected list, ask exactly ONE short clarifying question in the "clarifyingQuestion" field of the JSON response — but you must STILL provide usable topic options in the same response. Never return a bare question with nothing else.
4. Match the requested tone ("${prefs.tone.apiValue}") and mood ("${prefs.mood.apiValue}") precisely:
   - tone playful = light, witty phrasing; tone serious = measured, formal academic phrasing; tone neutral = plain, matter-of-fact phrasing.
   - mood curious = exploratory, open questions; mood provocative = challenges assumptions, bold framing; mood reverent = respectful, careful of sensitive subject matter; mood irreverent = unconventional, willing to poke at orthodoxy.
5. Calibrate depth and corpus to the academic level "${prefs.level.apiValue}":
   - licence: bounded, accessible corpus, no paleography or ancient-language skills required.
   - master: specialized historiography, situates the topic within a scholarly debate.
   - memoire: focused methodology built around one precise, tractable problématique.
   - phd: original archival contribution, extensive and demanding primary corpus.
   - general_public: no technical jargon, accessible to a curious non-specialist.
6. Every subject must name REAL, VERIFIABLE events, works, people, or documents. Never invent anecdotes or fabricate references, titles, or names.
7. Write all output text in this language: "${prefs.language}".
8. Formatting rules (strict):
   - Never emit raw HTML tags or HTML/numeric character entities (e.g. "&#128161;", "&amp;") anywhere in any field. For emphasis use real Markdown syntax (**bold**, *italic*); for an emoji use the actual Unicode character directly, never an HTML entity.
   - Title fields are plain text: no Markdown, no emoji.
   - Prose fields (pitch, explanations, relevance notes, descriptions) may use light Markdown (bold/italic/short lists) and nothing more elaborate.
9. Your entire response must be a single strictly valid JSON object matching the schema below. No prose outside the JSON. No markdown code fences around the JSON itself. No trailing commas.

If scope is "broad": populate "broadTopics" with 5 to 8 entries, leave "narrowTopic" null.
If scope is "narrow": populate "narrowTopic" (with its required starterBibliography and suggestedStructure), leave "broadTopics" an empty array.
Always set "fieldsCovered" at the top level to the full list of fields you engaged with.
''';
  }

  Map<String, dynamic> _userPayload({
    required PreferenceBlock prefs,
    required String freeText,
    String? focusTitle,
    Map<String, dynamic>? existingNarrowTopic,
    String? refinementRequest,
  }) {
    if (existingNarrowTopic != null) {
      return {
        'preferences': prefs.toJson(),
        'instruction':
            'Refine the following existing narrowTopic per the refinement request below. Return the FULL updated narrowTopic object again (same shape as the schema\'s "narrowTopic"), plus an added "refinementSummary" string field describing what changed. Respond with the top-level JSON object exactly as described in the system prompt schema, with scope="narrow", "narrowTopic" populated (including "refinementSummary" inside it), and "broadTopics" empty.',
        'existingNarrowTopic': existingNarrowTopic,
        'refinementRequest': refinementRequest,
      };
    }
    return {
      'preferences': prefs.toJson(),
      if (freeText.trim().isNotEmpty) 'freeTextFocus': freeText.trim(),
      if (focusTitle != null) 'deepDiveOnTitle': focusTitle,
      'instruction': prefs.scope.apiValue == 'narrow'
          ? 'Generate ONE narrow, deep-dive topic (scope="narrow") following the rules and schema exactly.'
          : 'Generate 5 to 8 broad topic options (scope="broad") following the rules and schema exactly.',
    };
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        final message = decoded['error']['message'];
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Not a JSON error body; fall through to a generic message.
    }
    return null;
  }

  bool _isKeyRejection(int statusCode, String body) {
    if (statusCode == 401 || statusCode == 403) return true;
    if (statusCode != 400) return false;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map || decoded['error'] is! Map) return false;
      final error = decoded['error'] as Map;
      final details = error['details'];
      final hasInvalidKeyReason =
          details is List &&
          details.any((d) => d is Map && d['reason'] == 'API_KEY_INVALID');
      if (hasInvalidKeyReason) return true;
      final status = error['status'];
      final message = (error['message'] as String?)?.toLowerCase() ?? '';
      return status == 'INVALID_ARGUMENT' && message.contains('api key');
    } catch (_) {
      return false;
    }
  }

  /// Sends a single `generateContent` request and returns the sanitized,
  /// schema-conformant JSON object it produced.
  Future<Map<String, dynamic>> _callGemini({
    required String apiKey,
    required String systemPrompt,
    required Map<String, dynamic> userPayload,
  }) async {
    http.Response response;
    try {
      response = await _http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': jsonEncode(userPayload)},
              ],
            },
          ],
          'generationConfig': {
            'temperature': _temperature,
            'topP': _topP,
            'maxOutputTokens': _maxOutputTokens,
            'responseMimeType': 'application/json',
            'responseSchema': _responseSchema,
          },
        }),
      );
    } catch (_) {
      throw const GeminiApiException(
        'Could not reach Gemini. Check your connection and try again.',
      );
    }

    if (_isKeyRejection(response.statusCode, response.body)) {
      throw ApiKeyRejectedException(
        _extractErrorMessage(response.body) ?? 'Your API key was rejected.',
      );
    }
    if (response.statusCode != 200) {
      final message = _extractErrorMessage(response.body);
      throw GeminiApiException(
        message ??
            'Gemini returned an error (HTTP ${response.statusCode}). Please try again.',
      );
    }

    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const GeminiApiException(
        'Received an unreadable response from Gemini.',
      );
    }

    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiApiException('Gemini returned no candidates.');
    }
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    final text = parts != null && parts.isNotEmpty
        ? parts.first['text'] as String?
        : null;
    if (text == null || text.trim().isEmpty) {
      throw const GeminiApiException('Gemini returned an empty response.');
    }

    final Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw const GeminiApiException(
        'Gemini returned a response that was not valid JSON.',
      );
    }
    return sanitizeJsonTree(parsed) as Map<String, dynamic>;
  }

  /// Sends the request, with one defensive retry if the first attempt fails
  /// for any reason other than a rejected API key (network hiccup, a
  /// non-200 response, or — despite `responseSchema` — malformed JSON).
  Future<Map<String, dynamic>> _requestJson({
    required String apiKey,
    required String systemPrompt,
    required Map<String, dynamic> userPayload,
  }) async {
    try {
      return await _callGemini(
        apiKey: apiKey,
        systemPrompt: systemPrompt,
        userPayload: userPayload,
      );
    } on ApiKeyRejectedException {
      rethrow;
    } catch (_) {
      try {
        return await _callGemini(
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          userPayload: userPayload,
        );
      } on ApiKeyRejectedException {
        rethrow;
      } catch (_) {
        throw const GeminiApiException(
          'Gemini did not return a valid response, even after a retry.',
        );
      }
    }
  }

  Future<GenerationResponse> generate({
    required String apiKey,
    required PreferenceBlock prefs,
    String freeText = '',
    String? deepDiveOnTitle,
  }) async {
    final json = await _requestJson(
      apiKey: apiKey,
      systemPrompt: _systemPrompt(prefs),
      userPayload: _userPayload(
        prefs: prefs,
        freeText: freeText,
        focusTitle: deepDiveOnTitle,
      ),
    );
    return GenerationResponse.fromJson(json);
  }

  Future<NarrowTopic> refine({
    required String apiKey,
    required PreferenceBlock prefs,
    required NarrowTopic currentTopic,
    required String refinementInstruction,
  }) async {
    final json = await _requestJson(
      apiKey: apiKey,
      systemPrompt: _systemPrompt(prefs),
      userPayload: _userPayload(
        prefs: prefs,
        freeText: '',
        existingNarrowTopic: currentTopic.toJson(),
        refinementRequest: refinementInstruction,
      ),
    );
    final response = GenerationResponse.fromJson(json);
    if (response.narrowTopic == null) {
      throw const GeminiApiException('Gemini did not return a refined topic.');
    }
    return response.narrowTopic!;
  }
}
