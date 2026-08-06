import 'enums.dart';

/// The full set of user preferences that drive every generation call.
class PreferenceBlock {
  final List<String> fields;
  final AcademicLevel level;
  final Tone tone;
  final Scope scope;
  final Mood mood;
  final List<String> excludedFields;
  final String language; // "fr" | "en"

  const PreferenceBlock({
    required this.fields,
    required this.level,
    required this.tone,
    required this.scope,
    required this.mood,
    required this.excludedFields,
    required this.language,
  });

  PreferenceBlock copyWith({
    List<String>? fields,
    AcademicLevel? level,
    Tone? tone,
    Scope? scope,
    Mood? mood,
    List<String>? excludedFields,
    String? language,
  }) {
    return PreferenceBlock(
      fields: fields ?? this.fields,
      level: level ?? this.level,
      tone: tone ?? this.tone,
      scope: scope ?? this.scope,
      mood: mood ?? this.mood,
      excludedFields: excludedFields ?? this.excludedFields,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
    'fields': fields,
    'level': level.apiValue,
    'tone': tone.apiValue,
    'scope': scope.apiValue,
    'mood': mood.apiValue,
    'excludedFields': excludedFields,
    'language': language,
  };

  static PreferenceBlock initial() => const PreferenceBlock(
    fields: ['history', 'catholic_theology', 'art'],
    level: AcademicLevel.licence,
    tone: Tone.neutral,
    scope: Scope.broad,
    mood: Mood.curious,
    excludedFields: [],
    language: 'fr',
  );
}
