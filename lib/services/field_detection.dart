/// Pure Dart, no-API-call detection of fields implied by free text but not
/// currently selected. Never assumes silently — callers must surface this as
/// a dismissible suggestion chip, not an automatic change.
class FieldDetectionMatch {
  final String fieldId;
  final String matchedKeyword;

  const FieldDetectionMatch(this.fieldId, this.matchedKeyword);
}

/// keyword (normalized, no accents, lowercase) -> implied field id.
const Map<String, String> _fieldTriggerKeywords = {
  // Art history
  'tableau': 'art',
  'peinture': 'art',
  'peintre': 'art',
  'fresque': 'art',
  'sculpture': 'art',
  'musee': 'art',
  'toile': 'art',
  'painting': 'art',
  'artwork': 'art',
  'fresco': 'art',
  'museum': 'art',

  // Architecture
  'cathedrale': 'architecture',
  'basilique': 'architecture',
  'abbaye': 'architecture',
  'facade': 'architecture',
  'vitrail': 'architecture',
  'cathedral': 'architecture',
  'basilica': 'architecture',
  'abbey': 'architecture',
  'stained glass': 'architecture',

  // Music
  'musique': 'music',
  'symphonie': 'music',
  'opera': 'music',
  'partition': 'music',
  'symphony': 'music',
  'hymn': 'music',
  'sheet music': 'music',

  // Theology / religious studies
  'bible': 'catholic_theology',
  'evangile': 'catholic_theology',
  'theologie': 'catholic_theology',
  'liturgie': 'catholic_theology',
  'pape': 'catholic_theology',
  'encyclique': 'catholic_theology',
  'concile': 'catholic_theology',
  'gospel': 'catholic_theology',
  'theology': 'catholic_theology',
  'liturgy': 'catholic_theology',
  'papal': 'catholic_theology',
  'encyclical': 'catholic_theology',

  // Law
  'jurisprudence': 'law',
  'tribunal': 'law',
  'lawsuit': 'law',
  'legal code': 'law',

  // Political science
  'parlement': 'political_science',
  'parliament': 'political_science',
  'election': 'political_science',

  // Philosophy
  'philosophe': 'philosophy',
  'philosopher': 'philosophy',
  'metaphysique': 'philosophy',
  'metaphysics': 'philosophy',
};

String _stripDiacritics(String input) {
  const from = 'àâäáãåèéêëìíîïòóôöõùúûüçñÀÂÄÁÃÅÈÉÊËÌÍÎÏÒÓÔÖÕÙÚÛÜÇÑ';
  const to = 'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

/// Scans [freeText] for keywords implying academic fields not present in
/// [selectedFieldIds], returning at most one suggestion per implied field.
List<FieldDetectionMatch> detectImpliedFields(
  String freeText,
  List<String> selectedFieldIds,
) {
  if (freeText.trim().isEmpty) return const [];

  final normalized = ' ${_stripDiacritics(freeText.toLowerCase())} ';
  final selected = selectedFieldIds.toSet();
  final matches = <String, FieldDetectionMatch>{};

  _fieldTriggerKeywords.forEach((keyword, fieldId) {
    if (selected.contains(fieldId) || matches.containsKey(fieldId)) return;
    if (normalized.contains(keyword)) {
      matches[fieldId] = FieldDetectionMatch(fieldId, keyword);
    }
  });

  return matches.values.toList();
}
