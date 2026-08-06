import 'narrow_topic.dart';

/// A narrow topic saved to the persistent notebook, with the user's own notes.
class NotebookEntry {
  final String id;
  final NarrowTopic topic;
  final String personalNotes;
  final DateTime savedAt;

  const NotebookEntry({
    required this.id,
    required this.topic,
    required this.personalNotes,
    required this.savedAt,
  });

  NotebookEntry copyWith({String? personalNotes}) {
    return NotebookEntry(
      id: id,
      topic: topic,
      personalNotes: personalNotes ?? this.personalNotes,
      savedAt: savedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic.toJson(),
    'personalNotes': personalNotes,
    'savedAt': savedAt.toIso8601String(),
  };

  factory NotebookEntry.fromJson(Map<String, dynamic> json) {
    return NotebookEntry(
      id: json['id']?.toString() ?? '',
      topic: NarrowTopic.fromJson(json['topic'] as Map<String, dynamic>),
      personalNotes: json['personalNotes']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
