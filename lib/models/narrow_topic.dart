import 'bibliography_entry.dart';
import 'outline_part.dart';

class NarrowTopic {
  final String id;
  final String title;
  final String pitch;
  final String problematique;
  final String levelNotes;
  final String fieldsIntersectionExplanation;
  final List<BibliographyEntry> starterBibliography;
  final List<OutlinePart> suggestedStructure;

  /// Only present on responses from the "refine" flow.
  final String? refinementSummary;

  const NarrowTopic({
    required this.id,
    required this.title,
    required this.pitch,
    required this.problematique,
    required this.levelNotes,
    required this.fieldsIntersectionExplanation,
    required this.starterBibliography,
    required this.suggestedStructure,
    this.refinementSummary,
  });

  factory NarrowTopic.fromJson(Map<String, dynamic> json) {
    return NarrowTopic(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      pitch: json['pitch']?.toString() ?? '',
      problematique: json['problematique']?.toString() ?? '',
      levelNotes: json['levelNotes']?.toString() ?? '',
      fieldsIntersectionExplanation:
          json['fieldsIntersectionExplanation']?.toString() ?? '',
      starterBibliography:
          (json['starterBibliography'] as List?)
              ?.map(
                (e) => BibliographyEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      suggestedStructure:
          (json['suggestedStructure'] as List?)
              ?.map((e) => OutlinePart.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      refinementSummary: json['refinementSummary']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'pitch': pitch,
    'problematique': problematique,
    'levelNotes': levelNotes,
    'fieldsIntersectionExplanation': fieldsIntersectionExplanation,
    'starterBibliography': starterBibliography.map((e) => e.toJson()).toList(),
    'suggestedStructure': suggestedStructure.map((e) => e.toJson()).toList(),
    if (refinementSummary != null) 'refinementSummary': refinementSummary,
  };

  NarrowTopic copyWith({String? id}) {
    return NarrowTopic(
      id: id ?? this.id,
      title: title,
      pitch: pitch,
      problematique: problematique,
      levelNotes: levelNotes,
      fieldsIntersectionExplanation: fieldsIntersectionExplanation,
      starterBibliography: starterBibliography,
      suggestedStructure: suggestedStructure,
      refinementSummary: refinementSummary,
    );
  }
}
