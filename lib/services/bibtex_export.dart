import '../models/bibliography_entry.dart';

String _bibtexEscape(String value) =>
    value.replaceAll('{', '(').replaceAll('}', ')');

String _citationKey(BibliographyEntry entry, int index) {
  final firstAuthorWord = entry.authors
      .split(RegExp(r'[,\s]+'))
      .firstWhere((w) => w.isNotEmpty, orElse: () => 'ref');
  final slug = firstAuthorWord.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  final year = entry.year.replaceAll(RegExp(r'[^0-9]'), '');
  final base = '${slug.isEmpty ? 'ref' : slug}${year.isEmpty ? '' : year}';
  return base.isEmpty ? 'ref$index' : '$base${index > 0 ? index : ''}';
}

String _entryType(String type) => switch (type) {
  'book' => 'book',
  'article' => 'article',
  'primary_source' => 'misc',
  _ => 'misc',
};

/// Generates one valid BibTeX entry per bibliography source.
String bibtexForEntry(BibliographyEntry entry, {int index = 0}) {
  final key = _citationKey(entry, index);
  final type = _entryType(entry.type);
  final buffer = StringBuffer('@$type{$key,\n');
  buffer.writeln('  author = {${_bibtexEscape(entry.authors)}},');
  buffer.writeln('  title = {${_bibtexEscape(entry.title)}},');
  buffer.writeln('  year = {${_bibtexEscape(entry.year)}},');
  switch (type) {
    case 'book':
      buffer.writeln('  publisher = {${_bibtexEscape(entry.publication)}},');
      break;
    case 'article':
      buffer.writeln('  journal = {${_bibtexEscape(entry.publication)}},');
      break;
    default:
      buffer.writeln('  howpublished = {${_bibtexEscape(entry.publication)}},');
      buffer.writeln('  note = {Primary source},');
  }
  buffer.write('}');
  return buffer.toString();
}

/// Generates the full .bib file content for a list of sources.
String bibtexForEntries(List<BibliographyEntry> entries) {
  return entries
      .asMap()
      .entries
      .map((e) => bibtexForEntry(e.value, index: e.key))
      .join('\n\n');
}
