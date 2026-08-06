import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/narrow_topic.dart';
import '../../providers/notebook_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dialogs/bibtex_export_dialog.dart';
import '../common/markdown_text.dart';
import 'problematique_callout.dart';
import 'tabs/bibliography_tab.dart';
import 'tabs/intersection_tab.dart';
import 'tabs/outline_tab.dart';
import 'tabs/refine_tab.dart';

class NarrowTopicView extends ConsumerWidget {
  final NarrowTopic topic;
  final List<String> fieldsCovered;
  final String language;

  const NarrowTopicView({
    super.key,
    required this.topic,
    required this.fieldsCovered,
    required this.language,
  });

  String get _slug => topic.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final s = AppStrings(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic.title, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 12),
        MarkdownText(topic.pitch),
        const SizedBox(height: 10),
        if (topic.refinementSummary != null &&
            topic.refinementSummary!.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.teal.withValues(alpha: 0.3)),
            ),
            child: MarkdownText(topic.refinementSummary!),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.parchment,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: MarkdownText(topic.levelNotes),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.success,
                foregroundColor: colors.successOn,
              ),
              onPressed: () async {
                await ref.read(notebookProvider.notifier).save(topic);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.savedToNotebook)));
                }
              },
              icon: const Icon(LucideIcons.bookmarkPlus, size: 16),
              label: Text(s.saveToNotebook),
            ),
            OutlinedButton.icon(
              onPressed: () => showBibtexExportDialog(
                context,
                entries: topic.starterBibliography,
                language: language,
                topicSlug: _slug.isEmpty ? 'xyno-scholar-topic' : _slug,
              ),
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: Text(s.exportBibtex),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ProblematiqueCallout(
          problematique: topic.problematique,
          language: language,
        ),
        const SizedBox(height: 24),
        DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: s.tabIntersection),
                  Tab(text: s.tabBibliography),
                  Tab(text: s.tabOutline),
                  Tab(text: s.tabRefine),
                ],
              ),
              SizedBox(
                height: 620,
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: IntersectionTab(
                        topic: topic,
                        fields: fieldsCovered,
                        language: language,
                      ),
                    ),
                    SingleChildScrollView(
                      child: BibliographyTab(
                        entries: topic.starterBibliography,
                        language: language,
                      ),
                    ),
                    SingleChildScrollView(
                      child: OutlineTab(parts: topic.suggestedStructure),
                    ),
                    SingleChildScrollView(
                      child: RefineTab(topic: topic, language: language),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
