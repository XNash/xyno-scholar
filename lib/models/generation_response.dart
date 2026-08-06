import 'broad_topic.dart';
import 'narrow_topic.dart';

class GenerationResponse {
  final String scope; // "broad" | "narrow"
  final String language;
  final List<String> fieldsCovered;
  final String? clarifyingQuestion;
  final List<BroadTopic> broadTopics;
  final NarrowTopic? narrowTopic;

  const GenerationResponse({
    required this.scope,
    required this.language,
    required this.fieldsCovered,
    this.clarifyingQuestion,
    this.broadTopics = const [],
    this.narrowTopic,
  });

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      scope: json['scope']?.toString() ?? 'broad',
      language: json['language']?.toString() ?? 'fr',
      fieldsCovered:
          (json['fieldsCovered'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      clarifyingQuestion: json['clarifyingQuestion']?.toString(),
      broadTopics:
          (json['broadTopics'] as List?)
              ?.map((e) => BroadTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      narrowTopic: json['narrowTopic'] != null
          ? NarrowTopic.fromJson(json['narrowTopic'] as Map<String, dynamic>)
          : null,
    );
  }
}
