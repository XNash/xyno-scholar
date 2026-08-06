import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/bibliography_entry.dart';
import '../../services/bibtex_export.dart';
import '../../services/web_download.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

Future<void> showBibtexExportDialog(
  BuildContext context, {
  required List<BibliographyEntry> entries,
  required String language,
  required String topicSlug,
}) {
  final content = bibtexForEntries(entries);
  return showDialog(
    context: context,
    builder: (context) => _BibtexDialog(
      content: content,
      language: language,
      topicSlug: topicSlug,
    ),
  );
}

class _BibtexDialog extends StatelessWidget {
  final String content;
  final String language;
  final String topicSlug;

  const _BibtexDialog({
    required this.content,
    required this.language,
    required this.topicSlug,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = AppStrings(language);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.bibtexDialogTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.parchment,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      content,
                      style: AppTypography.mono(
                        fontSize: 12.5,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.close),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: content));
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(s.copied)));
                      }
                    },
                    icon: const Icon(LucideIcons.copy, size: 15),
                    label: Text(s.copyAll),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        downloadTextFile('$topicSlug.bib', content),
                    icon: const Icon(LucideIcons.download, size: 15),
                    label: Text(s.downloadBib),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
