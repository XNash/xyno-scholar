class OutlinePart {
  final String partNumber; // I | II | III
  final String title;
  final String description;

  const OutlinePart({
    required this.partNumber,
    required this.title,
    required this.description,
  });

  factory OutlinePart.fromJson(Map<String, dynamic> json) {
    return OutlinePart(
      partNumber: json['partNumber']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'partNumber': partNumber,
    'title': title,
    'description': description,
  };
}
