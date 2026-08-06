import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/broad_topic.dart';
import '../../models/field_catalog.dart';
import '../../providers/generation_provider.dart';
import '../../providers/preference_providers.dart';
import '../../screens/narrow_topic_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/markdown_text.dart';

class BroadTopicsList extends ConsumerWidget {
  final List<BroadTopic> topics;

  const BroadTopicsList({super.key, required this.topics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final generation = ref.watch(generationProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < topics.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.amber.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: AppTypography.sans(
                          weight: FontWeight.w700,
                          color: colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topics[i].title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MarkdownText(topics[i].whyFitsAllFields),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: topics[i].fieldsCovered.map((fieldId) {
                    return Chip(
                      label: Text(
                        fieldLabel(fieldId, prefs.language),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: colors.teal.withValues(alpha: 0.10),
                      side: BorderSide(
                        color: colors.teal.withValues(alpha: 0.3),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Builder(
                    builder: (context) {
                      final isThisCardLoading =
                          generation.activeDeepDiveId == topics[i].id;
                      return TextButton.icon(
                        onPressed: generation.isLoading
                            ? null
                            : () async {
                                final narrow = await ref
                                    .read(generationProvider.notifier)
                                    .deepDive(topics[i]);
                                if (narrow != null && context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => NarrowTopicScreen(
                                        initialTopic: narrow,
                                        fieldsCovered:
                                            topics[i].fieldsCovered,
                                        language: prefs.language,
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: isThisCardLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.amber,
                                ),
                              )
                            : const Icon(LucideIcons.arrowRight, size: 16),
                        label: Text(
                          isThisCardLoading ? s.generating : s.deepDive,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
