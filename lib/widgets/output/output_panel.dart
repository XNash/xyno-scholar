import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../providers/generation_provider.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import '../common/markdown_text.dart';
import 'broad_topics_list.dart';
import 'narrow_topic_view.dart';
import 'status_banner.dart';

/// Right-column content: status/error banner + generated output, or an
/// empty state before the first generation.
class OutputPanel extends ConsumerWidget {
  const OutputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(generationProvider);
    final prefs = ref.watch(preferenceBlockProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (generation.error != null)
          StatusBanner(
            message: generation.error!,
            onDismiss: () => ref.read(generationProvider.notifier).clearError(),
            retryLabel: s.retry,
            onRetry: generation.failedDeepDiveTopic != null
                ? () => ref
                      .read(generationProvider.notifier)
                      .deepDive(generation.failedDeepDiveTopic!)
                : null,
          ),
        if (generation.isLoading && generation.response == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: colors.teal),
                  const SizedBox(height: 14),
                  Text(
                    s.generating,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else if (generation.response == null)
          _EmptyState(strings: s)
        else
          _ResponseContent(strings: s),
      ],
    );
  }
}

class _ResponseContent extends ConsumerWidget {
  final AppStrings strings;

  const _ResponseContent({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(generationProvider);
    final response = generation.response!;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (response.clarifyingQuestion != null &&
            response.clarifyingQuestion!.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.helpCircle, size: 18, color: colors.amber),
                const SizedBox(width: 10),
                Expanded(child: MarkdownText(response.clarifyingQuestion!)),
              ],
            ),
          ),
        if (response.scope == 'narrow' && response.narrowTopic != null)
          NarrowTopicView(
            topic: response.narrowTopic!,
            fieldsCovered: response.fieldsCovered,
            language: response.language,
          )
        else if (response.broadTopics.isNotEmpty)
          BroadTopicsList(topics: response.broadTopics)
        else
          _EmptyState(strings: strings),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppStrings strings;

  const _EmptyState({required this.strings});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.compass, size: 44, color: colors.inkMuted),
            const SizedBox(height: 16),
            Text(
              strings.emptyStateTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                strings.emptyStateBody,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
