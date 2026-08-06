import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/strings.dart';
import '../../models/enums.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import 'sidebar_card.dart';

class ScopeToneMoodCard extends ConsumerWidget {
  const ScopeToneMoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final notifier = ref.read(preferenceBlockProvider.notifier);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return SidebarCard(
      title: s.scopeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<Scope>(
            segments: Scope.values
                .map(
                  (scope) => ButtonSegment(
                    value: scope,
                    label: Text(
                      prefs.language == 'fr'
                          ? scope.labelFr()
                          : scope.labelEn(),
                    ),
                  ),
                )
                .toList(),
            selected: {prefs.scope},
            onSelectionChanged: (selection) =>
                notifier.setScope(selection.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? colors.teal.withValues(alpha: 0.16)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(s.toneTitle, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: Tone.values.map((tone) {
              final selected = prefs.tone == tone;
              return ChoiceChip(
                label: Text(
                  prefs.language == 'fr' ? tone.labelFr() : tone.labelEn(),
                ),
                selected: selected,
                onSelected: (_) => notifier.setTone(tone),
                selectedColor: colors.teal.withValues(alpha: 0.16),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(s.moodTitle, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: Mood.values.map((mood) {
              final selected = prefs.mood == mood;
              return ChoiceChip(
                label: Text(
                  prefs.language == 'fr' ? mood.labelFr() : mood.labelEn(),
                ),
                selected: selected,
                onSelected: (_) => notifier.setMood(mood),
                selectedColor: colors.teal.withValues(alpha: 0.16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
