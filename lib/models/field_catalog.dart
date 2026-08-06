/// A single selectable academic field.
class FieldOption {
  final String id;
  final String labelFr;
  final String labelEn;

  const FieldOption({
    required this.id,
    required this.labelFr,
    required this.labelEn,
  });

  String label(String language) => language == 'fr' ? labelFr : labelEn;
}

/// A collapsible category of related fields, shown in the sidebar checklist.
class FieldCategory {
  final String id;
  final String titleFr;
  final String titleEn;
  final List<FieldOption> fields;

  const FieldCategory({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.fields,
  });

  String title(String language) => language == 'fr' ? titleFr : titleEn;
}

/// Default, editable catalog of fields grouped by category. Fully generic —
/// users may add any custom field via free text on top of this list.
const List<FieldCategory> kDefaultFieldCatalog = [
  FieldCategory(
    id: 'humanities_history',
    titleFr: 'Humanités & Histoire',
    titleEn: 'Humanities & History',
    fields: [
      FieldOption(id: 'history', labelFr: 'Histoire', labelEn: 'History'),
      FieldOption(
        id: 'literature',
        labelFr: 'Littérature',
        labelEn: 'Literature',
      ),
      FieldOption(
        id: 'philosophy',
        labelFr: 'Philosophie',
        labelEn: 'Philosophy',
      ),
      FieldOption(
        id: 'linguistics',
        labelFr: 'Linguistique',
        labelEn: 'Linguistics',
      ),
      FieldOption(
        id: 'archaeology',
        labelFr: 'Archéologie',
        labelEn: 'Archaeology',
      ),
    ],
  ),
  FieldCategory(
    id: 'theology_religion',
    titleFr: 'Théologie & Sciences religieuses',
    titleEn: 'Theology & Religious Studies',
    fields: [
      FieldOption(
        id: 'catholic_theology',
        labelFr: 'Théologie catholique',
        labelEn: 'Catholic theology',
      ),
      FieldOption(
        id: 'religious_studies',
        labelFr: 'Sciences des religions',
        labelEn: 'Religious studies',
      ),
      FieldOption(
        id: 'church_history',
        labelFr: 'Histoire de l\'Église',
        labelEn: 'Church history',
      ),
      FieldOption(
        id: 'biblical_studies',
        labelFr: 'Études bibliques',
        labelEn: 'Biblical studies',
      ),
    ],
  ),
  FieldCategory(
    id: 'arts_architecture_culture',
    titleFr: 'Arts, Architecture & Culture',
    titleEn: 'Arts, Architecture & Culture',
    fields: [
      FieldOption(
        id: 'art',
        labelFr: 'Histoire de l\'art',
        labelEn: 'Art history',
      ),
      FieldOption(
        id: 'architecture',
        labelFr: 'Architecture',
        labelEn: 'Architecture',
      ),
      FieldOption(id: 'music', labelFr: 'Musicologie', labelEn: 'Musicology'),
      FieldOption(
        id: 'cinema',
        labelFr: 'Études cinématographiques',
        labelEn: 'Film studies',
      ),
    ],
  ),
  FieldCategory(
    id: 'social_sciences_law',
    titleFr: 'Sciences sociales & Droit',
    titleEn: 'Social Sciences & Law',
    fields: [
      FieldOption(id: 'sociology', labelFr: 'Sociologie', labelEn: 'Sociology'),
      FieldOption(
        id: 'political_science',
        labelFr: 'Science politique',
        labelEn: 'Political science',
      ),
      FieldOption(id: 'law', labelFr: 'Droit', labelEn: 'Law'),
      FieldOption(
        id: 'anthropology',
        labelFr: 'Anthropologie',
        labelEn: 'Anthropology',
      ),
      FieldOption(id: 'economics', labelFr: 'Économie', labelEn: 'Economics'),
    ],
  ),
  FieldCategory(
    id: 'sciences_environment_interdisciplinary',
    titleFr: 'Sciences, Environnement & Interdisciplinaire',
    titleEn: 'Sciences, Environment & Interdisciplinary',
    fields: [
      FieldOption(
        id: 'environmental_history',
        labelFr: 'Histoire environnementale',
        labelEn: 'Environmental history',
      ),
      FieldOption(
        id: 'history_of_science',
        labelFr: 'Histoire des sciences',
        labelEn: 'History of science',
      ),
      FieldOption(id: 'geography', labelFr: 'Géographie', labelEn: 'Geography'),
      FieldOption(
        id: 'medicine_history',
        labelFr: 'Histoire de la médecine',
        labelEn: 'History of medicine',
      ),
    ],
  ),
];

/// Look up a display label for any field id, including custom user-added
/// fields that aren't part of the default catalog (falls back to the id).
String fieldLabel(String fieldId, String language) {
  for (final category in kDefaultFieldCatalog) {
    for (final field in category.fields) {
      if (field.id == fieldId) return field.label(language);
    }
  }
  return fieldId;
}
