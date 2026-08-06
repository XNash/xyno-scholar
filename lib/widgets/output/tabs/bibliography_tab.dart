import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/bibliography_entry.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../common/markdown_text.dart';

Uri _googleScholarUri(BibliographyEntry e) => Uri.https(
  'scholar.google.com',
  '/scholar',
  {'q': '${e.authors} ${e.title}'},
);

Uri _jstorUri(BibliographyEntry e) =>
    Uri.https('www.jstor.org', '/action/doBasicSearch', {'Query': e.title});

Uri _worldcatUri(BibliographyEntry e) =>
    Uri.https('search.worldcat.org', '/search', {'q': e.title});

String _typeLabel(String type, String language) {
  final fr = language == 'fr';
  return switch (type) {
    'book' => fr ? 'Livre' : 'Book',
    'article' => fr ? 'Article' : 'Article',
    'primary_source' => fr ? 'Source primaire' : 'Primary source',
    _ => type,
  };
}

class BibliographyTab extends StatelessWidget {
  final List<BibliographyEntry> entries;
  final String language;

  const BibliographyTab({
    super.key,
    required this.entries,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: AppTypography.serif(
                          fontSize: 16,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _typeLabel(entry.type, language),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: colors.amber.withValues(alpha: 0.14),
                      side: BorderSide(
                        color: colors.amber.withValues(alpha: 0.4),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.authors} · ${entry.year} · ${entry.publication}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: 10),
                MarkdownText(entry.relevance),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LinkButton(
                      label: 'Google Scholar',
                      icon: LucideIcons.graduationCap,
                      uri: _googleScholarUri(entry),
                    ),
                    _LinkButton(
                      label: 'JSTOR',
                      icon: LucideIcons.library,
                      uri: _jstorUri(entry),
                    ),
                    _LinkButton(
                      label: 'WorldCat',
                      icon: LucideIcons.archive,
                      uri: _worldcatUri(entry),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Uri uri;

  const _LinkButton({
    required this.label,
    required this.icon,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
