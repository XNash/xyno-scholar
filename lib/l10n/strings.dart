/// Lightweight bilingual UI copy — deliberately not full `intl`/ARB tooling,
/// since this is a single-user app with exactly two UI languages.
class AppStrings {
  final String language;
  const AppStrings(this.language);

  bool get _fr => language == 'fr';

  String get appTitle => 'Xyno Scholar';
  String get appSubtitle =>
      _fr ? 'Découverte de sujets de recherche' : 'Research topic discovery';

  // Unlock screen
  String get unlockTitle =>
      _fr ? 'Entrez votre clé API Gemini' : 'Enter your Gemini API key';
  String get unlockSubtitle => _fr
      ? 'Votre clé reste dans ce navigateur, elle n\'est jamais envoyée ailleurs qu\'à Google.'
      : 'Your key stays in this browser — it is never sent anywhere but Google.';
  String get apiKeyLabel => _fr ? 'Clé API Gemini' : 'Gemini API key';
  String get getApiKeyLink => _fr
      ? 'Obtenir une clé sur Google AI Studio'
      : 'Get a key from Google AI Studio';
  String get rememberSession => _fr
      ? 'Se souvenir pour cette session de navigateur'
      : 'Remember for this browser session';
  String get unlockButton => _fr ? 'Continuer' : 'Continue';
  String get keyRejected => _fr
      ? 'Votre clé API a été rejetée par Gemini.'
      : 'Your API key was rejected by Gemini.';
  String get forgetKey => _fr ? 'Oublier la clé' : 'Forget key';

  // Sidebar — fields
  String get fieldsTitle => _fr ? 'Champs disciplinaires' : 'Fields';
  String get addCustomFieldHint =>
      _fr ? 'Ajouter un champ personnalisé…' : 'Add a custom field…';
  String get atLeastOneField => _fr
      ? 'Au moins un champ doit rester sélectionné.'
      : 'At least one field must stay selected.';

  // Sidebar — excluded
  String get excludedTitle => _fr ? 'Thèmes exclus' : 'Excluded themes';
  String get excludedHint =>
      _fr ? 'ex. guerre, XXe siècle…' : 'e.g. war, 20th century…';

  // Sidebar — level
  String get levelTitle => _fr ? 'Niveau académique' : 'Academic level';

  // Sidebar — scope/tone/mood
  String get scopeTitle => _fr ? 'Portée' : 'Scope';
  String get toneTitle => _fr ? 'Ton' : 'Tone';
  String get moodTitle => _fr ? 'Ambiance' : 'Mood';

  // Free text
  String get freeTextTitle =>
      _fr ? 'Angle ou mot-clé (optionnel)' : 'Angle or keyword (optional)';
  String get freeTextHint => _fr
      ? 'ex. une période, un lieu, un objet précis…'
      : 'e.g. a period, a place, a specific object…';
  String get examplesLabel => _fr ? 'Exemples' : 'Examples';
  String get fieldSuggestionPrefix =>
      _fr ? 'Votre texte semble évoquer' : 'Your text seems to mention';
  String get addField => _fr ? 'Ajouter le champ' : 'Add field';
  String get dismiss => _fr ? 'Ignorer' : 'Dismiss';

  // Generate
  String get generateButton => _fr ? 'Générer des sujets' : 'Generate topics';
  String get generating => _fr ? 'Génération en cours…' : 'Generating…';

  // Output
  String get emptyStateTitle => _fr ? 'Prêt à explorer' : 'Ready to explore';
  String get emptyStateBody => _fr
      ? 'Ajustez vos préférences à gauche, puis générez des sujets de recherche.'
      : 'Adjust your preferences on the left, then generate research topics.';
  String get deepDive => _fr ? 'Approfondir →' : 'Deep Dive →';
  String get saveToNotebook =>
      _fr ? 'Enregistrer au carnet' : 'Save to Notebook';
  String get savedToNotebook =>
      _fr ? 'Enregistré au carnet.' : 'Saved to notebook.';
  String get exportBibtex => _fr ? 'Exporter en BibTeX' : 'Export BibTeX';
  String get copyProblematique =>
      _fr ? 'Copier la problématique' : 'Copy problématique';
  String get copied =>
      _fr ? 'Copié dans le presse-papiers.' : 'Copied to clipboard.';

  // Tabs
  String get tabIntersection =>
      _fr ? 'Analyse d\'intersection' : 'Intersection Analysis';
  String get tabBibliography =>
      _fr ? 'Bibliographie de départ' : 'Starter Bibliography';
  String get tabOutline => _fr ? 'Plan en 3 parties' : '3-Part Outline';
  String get tabRefine => _fr ? 'Affiner' : 'Refine';

  String get refinePlaceholder => _fr
      ? 'Décrivez comment affiner ce sujet…'
      : 'Describe how to refine this topic…';
  String get refineButton => _fr ? 'Affiner le sujet' : 'Refine topic';

  // Notebook
  String get notebookTitle => _fr ? 'Carnet' : 'Notebook';
  String get notebookEmpty =>
      _fr ? 'Aucun sujet enregistré pour l\'instant.' : 'No topics saved yet.';
  String get personalNotesHint =>
      _fr ? 'Notes personnelles…' : 'Personal notes…';
  String get remove => _fr ? 'Retirer' : 'Remove';

  // BibTeX dialog
  String get bibtexDialogTitle => _fr ? 'Export BibTeX' : 'Export BibTeX';
  String get copyAll => _fr ? 'Tout copier' : 'Copy all';
  String get downloadBib => _fr ? 'Télécharger .bib' : 'Download .bib';
  String get close => _fr ? 'Fermer' : 'Close';

  // Errors
  String get genericError => _fr
      ? 'Une erreur est survenue. Veuillez réessayer.'
      : 'Something went wrong. Please try again.';
}
