/// Academic level calibrates corpus difficulty for generated topics.
enum AcademicLevel {
  licence,
  master,
  memoire,
  phd,
  generalPublic;

  String get apiValue => switch (this) {
    AcademicLevel.licence => 'licence',
    AcademicLevel.master => 'master',
    AcademicLevel.memoire => 'memoire',
    AcademicLevel.phd => 'phd',
    AcademicLevel.generalPublic => 'general_public',
  };

  static AcademicLevel fromApiValue(String value) {
    return AcademicLevel.values.firstWhere(
      (l) => l.apiValue == value,
      orElse: () => AcademicLevel.licence,
    );
  }

  String labelFr() => switch (this) {
    AcademicLevel.licence => 'Licence',
    AcademicLevel.master => 'Master',
    AcademicLevel.memoire => 'Mémoire',
    AcademicLevel.phd => 'Doctorat',
    AcademicLevel.generalPublic => 'Grand public',
  };

  String labelEn() => switch (this) {
    AcademicLevel.licence => 'Undergraduate',
    AcademicLevel.master => "Master's",
    AcademicLevel.memoire => 'Thesis',
    AcademicLevel.phd => 'PhD',
    AcademicLevel.generalPublic => 'General public',
  };

  String descriptionFr() => switch (this) {
    AcademicLevel.licence =>
      'Corpus borné et accessible, sans paléographie ni langues anciennes requises.',
    AcademicLevel.master =>
      'Historiographie spécialisée, capacité à situer le sujet dans un débat scientifique.',
    AcademicLevel.memoire =>
      'Méthodologie resserrée autour d\'une problématique précise et traitable.',
    AcademicLevel.phd =>
      'Contribution archivistique originale, corpus primaire étendu et exigeant.',
    AcademicLevel.generalPublic =>
      'Sans jargon technique, accessible à un lecteur curieux non spécialiste.',
  };

  String descriptionEn() => switch (this) {
    AcademicLevel.licence =>
      'Bounded, accessible corpus — no paleography or ancient languages required.',
    AcademicLevel.master =>
      'Specialized historiography, situates the topic within a scholarly debate.',
    AcademicLevel.memoire =>
      'Focused methodology built around one precise, tractable problématique.',
    AcademicLevel.phd =>
      'Original archival contribution, extensive and demanding primary corpus.',
    AcademicLevel.generalPublic =>
      'Jargon-free, accessible to a curious non-specialist reader.',
  };
}

enum Tone {
  playful,
  serious,
  neutral;

  String get apiValue => name;

  static Tone fromApiValue(String value) {
    return Tone.values.firstWhere(
      (t) => t.apiValue == value,
      orElse: () => Tone.neutral,
    );
  }

  String labelFr() => switch (this) {
    Tone.playful => 'Ludique',
    Tone.serious => 'Sérieux',
    Tone.neutral => 'Neutre',
  };

  String labelEn() => switch (this) {
    Tone.playful => 'Playful',
    Tone.serious => 'Serious',
    Tone.neutral => 'Neutral',
  };
}

enum Scope {
  broad,
  narrow;

  String get apiValue => name;

  static Scope fromApiValue(String value) {
    return Scope.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => Scope.broad,
    );
  }

  String labelFr() => switch (this) {
    Scope.broad => 'Large (5–8 pistes)',
    Scope.narrow => 'Ciblé (approfondissement)',
  };

  String labelEn() => switch (this) {
    Scope.broad => 'Broad (5–8 options)',
    Scope.narrow => 'Narrow (deep dive)',
  };
}

enum Mood {
  curious,
  provocative,
  reverent,
  irreverent;

  String get apiValue => name;

  static Mood fromApiValue(String value) {
    return Mood.values.firstWhere(
      (m) => m.apiValue == value,
      orElse: () => Mood.curious,
    );
  }

  String labelFr() => switch (this) {
    Mood.curious => 'Curieux',
    Mood.provocative => 'Provocateur',
    Mood.reverent => 'Révérencieux',
    Mood.irreverent => 'Irrévérencieux',
  };

  String labelEn() => switch (this) {
    Mood.curious => 'Curious',
    Mood.provocative => 'Provocative',
    Mood.reverent => 'Reverent',
    Mood.irreverent => 'Irreverent',
  };
}
