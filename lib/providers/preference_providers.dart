import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/preference_block.dart';

class PreferenceController extends Notifier<PreferenceBlock> {
  @override
  PreferenceBlock build() => PreferenceBlock.initial();

  /// Adds or removes a field. Refuses to remove the last remaining field.
  void toggleField(String fieldId) {
    if (state.fields.contains(fieldId)) {
      if (state.fields.length <= 1) return;
      state = state.copyWith(
        fields: state.fields.where((f) => f != fieldId).toList(),
      );
    } else {
      state = state.copyWith(fields: [...state.fields, fieldId]);
    }
  }

  void addField(String fieldId) {
    if (state.fields.contains(fieldId)) return;
    state = state.copyWith(fields: [...state.fields, fieldId]);
  }

  void addExcludedTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || state.excludedFields.contains(trimmed)) return;
    state = state.copyWith(excludedFields: [...state.excludedFields, trimmed]);
  }

  void removeExcludedTag(String tag) {
    state = state.copyWith(
      excludedFields: state.excludedFields.where((t) => t != tag).toList(),
    );
  }

  void setLevel(AcademicLevel level) => state = state.copyWith(level: level);
  void setTone(Tone tone) => state = state.copyWith(tone: tone);
  void setScope(Scope scope) => state = state.copyWith(scope: scope);
  void setMood(Mood mood) => state = state.copyWith(mood: mood);
  void setLanguage(String language) =>
      state = state.copyWith(language: language);
}

final preferenceBlockProvider =
    NotifierProvider<PreferenceController, PreferenceBlock>(
      PreferenceController.new,
    );

/// Optional free-text angle/period/keyword focus.
final freeTextProvider = StateProvider<String>((ref) => '');

/// Field ids the user has explicitly dismissed from the free-text
/// implied-field suggestion, so the chip doesn't reappear for that field
/// until the text changes again.
final dismissedFieldSuggestionsProvider = StateProvider<Set<String>>(
  (ref) => {},
);
