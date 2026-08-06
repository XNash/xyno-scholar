class BibliographyEntry {
  final String authors;
  final String year;
  final String title;
  final String publication;
  final String type; // book | article | primary_source
  final String relevance;

  const BibliographyEntry({
    required this.authors,
    required this.year,
    required this.title,
    required this.publication,
    required this.type,
    required this.relevance,
  });

  factory BibliographyEntry.fromJson(Map<String, dynamic> json) {
    return BibliographyEntry(
      authors: json['authors']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      publication: json['publication']?.toString() ?? '',
      type: json['type']?.toString() ?? 'book',
      relevance: json['relevance']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'authors': authors,
    'year': year,
    'title': title,
    'publication': publication,
    'type': type,
    'relevance': relevance,
  };
}
