import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/preference_block.dart';
import '../models/generation_response.dart';
import '../models/narrow_topic.dart';
import 'sanitize.dart';

/// Thrown when Cerebras rejects the API key (401/403). The caller should
/// clear the key and return to the unlock screen.
class ApiKeyRejectedException implements Exception {
  final String message;
  const ApiKeyRejectedException([this.message = 'Your API key was rejected.']);
  @override
  String toString() => message;
}

/// Any other failure talking to Cerebras (network, malformed response, etc).
/// The message is always safe to show the user — it never includes the key.
class CerebrasApiException implements Exception {
  final String message;
  const CerebrasApiException(this.message);
  @override
  String toString() => message;
}

class CerebrasClient {
  static const _endpoint = 'https://api.cerebras.ai/v1/chat/completions';
  static const _model = 'llama-3.3-70b';

  final http.Client _http;

  CerebrasClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

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

JSON schema:
{
  "scope": "broad" | "narrow",
  "language": string,
  "fieldsCovered": string[],
  "clarifyingQuestion": string or null,
  "broadTopics": [
    {
      "id": string,
      "title": string,
      "whyFitsAllFields": string,
      "fieldsCovered": string[],
      "keyKeywords": string[]
    }
  ],
  "narrowTopic": {
    "id": string,
    "title": string,
    "pitch": string,
    "problematique": string,
    "levelNotes": string,
    "fieldsIntersectionExplanation": string,
    "starterBibliography": [
      { "authors": string, "year": string, "title": string, "publication": string, "type": "book"|"article"|"primary_source", "relevance": string }
    ],
    "suggestedStructure": [
      { "partNumber": "I"|"II"|"III", "title": string, "description": string }
    ]
  } or null
}

Rules for populating the schema:
- If scope is "broad": populate "broadTopics" with 5 to 8 entries, leave "narrowTopic" null.
- If scope is "narrow": populate "narrowTopic" with exactly 3 entries in "starterBibliography" and exactly 3 entries (I, II, III) in "suggestedStructure", leave "broadTopics" an empty array.
- Always set "fieldsCovered" at the top level to the full list of fields you engaged with.
''';
  }

  Map<String, dynamic> _userTurn({
    required PreferenceBlock prefs,
    required String freeText,
    String? focusTitle,
  }) {
    final payload = {
      'preferences': prefs.toJson(),
      if (freeText.trim().isNotEmpty) 'freeTextFocus': freeText.trim(),
      if (focusTitle != null) 'deepDiveOnTitle': focusTitle,
      'instruction': prefs.scope.apiValue == 'narrow'
          ? 'Generate ONE narrow, deep-dive topic (scope="narrow") following the rules and schema exactly.'
          : 'Generate 5 to 8 broad topic options (scope="broad") following the rules and schema exactly.',
    };
    return {'role': 'user', 'content': jsonEncode(payload)};
  }

  String _stripCodeFences(String text) {
    var trimmed = text.trim();
    final fenceMatch = RegExp(
      r'^```(?:json)?\s*([\s\S]*?)\s*```$',
    ).firstMatch(trimmed);
    if (fenceMatch != null) {
      trimmed = fenceMatch.group(1)!.trim();
    }
    return trimmed;
  }

  Future<Map<String, dynamic>> _chat({
    required String apiKey,
    required List<Map<String, dynamic>> messages,
  }) async {
    http.Response response;
    try {
      response = await _http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 4000,
        }),
      );
    } catch (_) {
      throw const CerebrasApiException(
        'Could not reach Cerebras. Check your connection and try again.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ApiKeyRejectedException();
    }
    if (response.statusCode != 200) {
      throw CerebrasApiException(
        'Cerebras returned an error (HTTP ${response.statusCode}). Please try again.',
      );
    }

    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const CerebrasApiException(
        'Received an unreadable response from Cerebras.',
      );
    }
    return decoded;
  }

  String _extractContent(Map<String, dynamic> chatResponse) {
    final choices = chatResponse['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const CerebrasApiException(
        'Cerebras returned no response content.',
      );
    }
    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const CerebrasApiException('Cerebras returned an empty response.');
    }
    return content;
  }

  /// Sends [messages], defensively parses the JSON reply, retrying once if
  /// the model's first output is not valid JSON.
  Future<Map<String, dynamic>> _requestJson({
    required String apiKey,
    required List<Map<String, dynamic>> messages,
  }) async {
    final chatResponse = await _chat(apiKey: apiKey, messages: messages);
    final rawContent = _extractContent(chatResponse);
    final cleaned = _stripCodeFences(rawContent);

    try {
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      return sanitizeJsonTree(parsed) as Map<String, dynamic>;
    } catch (_) {
      final retryMessages = [
        ...messages,
        {'role': 'assistant', 'content': rawContent},
        {
          'role': 'user',
          'content':
              'Your last message was not valid JSON. Resend your ENTIRE answer again, as ONE strictly valid JSON object matching the schema from the system prompt. Output nothing except the JSON object: no prose, no markdown code fences.',
        },
      ];
      final retryResponse = await _chat(
        apiKey: apiKey,
        messages: retryMessages,
      );
      final retryRaw = _extractContent(retryResponse);
      final retryCleaned = _stripCodeFences(retryRaw);
      try {
        final parsed = jsonDecode(retryCleaned) as Map<String, dynamic>;
        return sanitizeJsonTree(parsed) as Map<String, dynamic>;
      } catch (_) {
        throw const CerebrasApiException(
          'Cerebras did not return valid JSON, even after a retry.',
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
    final messages = [
      {'role': 'system', 'content': _systemPrompt(prefs)},
      _userTurn(prefs: prefs, freeText: freeText, focusTitle: deepDiveOnTitle),
    ];
    final json = await _requestJson(apiKey: apiKey, messages: messages);
    return GenerationResponse.fromJson(json);
  }

  Future<NarrowTopic> refine({
    required String apiKey,
    required PreferenceBlock prefs,
    required NarrowTopic currentTopic,
    required String refinementInstruction,
  }) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt(prefs)},
      {
        'role': 'user',
        'content': jsonEncode({
          'preferences': prefs.toJson(),
          'instruction':
              'Refine the following existing narrowTopic per the refinement request below. Return the FULL updated narrowTopic object again (same shape as the schema\'s "narrowTopic", still with exactly 3 starterBibliography entries and 3 suggestedStructure parts), plus an added "refinementSummary" string field describing what changed. Respond with the top-level JSON object exactly as described in the system prompt schema, with scope="narrow", "narrowTopic" populated (including "refinementSummary" inside it), and "broadTopics" empty.',
          'existingNarrowTopic': currentTopic.toJson(),
          'refinementRequest': refinementInstruction,
        }),
      },
    ];
    final json = await _requestJson(apiKey: apiKey, messages: messages);
    final response = GenerationResponse.fromJson(json);
    if (response.narrowTopic == null) {
      throw const CerebrasApiException(
        'Cerebras did not return a refined topic.',
      );
    }
    return response.narrowTopic!;
  }
}
