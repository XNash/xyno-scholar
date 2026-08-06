class BroadTopic {
  final String id;
  final String title;
  final String whyFitsAllFields;
  final List<String> fieldsCovered;
  final List<String> keyKeywords;

  const BroadTopic({
    required this.id,
    required this.title,
    required this.whyFitsAllFields,
    required this.fieldsCovered,
    required this.keyKeywords,
  });

  factory BroadTopic.fromJson(Map<String, dynamic> json) {
    return BroadTopic(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      whyFitsAllFields: json['whyFitsAllFields']?.toString() ?? '',
      fieldsCovered:
          (json['fieldsCovered'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      keyKeywords:
          (json['keyKeywords'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'whyFitsAllFields': whyFitsAllFields,
    'fieldsCovered': fieldsCovered,
    'keyKeywords': keyKeywords,
  };
}
