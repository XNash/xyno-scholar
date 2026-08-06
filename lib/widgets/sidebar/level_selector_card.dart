import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/enums.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import 'sidebar_card.dart';

class LevelSelectorCard extends ConsumerWidget {
  const LevelSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return SidebarCard(
      title: s.levelTitle,
      child: Column(
        children: AcademicLevel.values.map((level) {
          final isSelected = prefs.level == level;
          final label = prefs.language == 'fr'
              ? level.labelFr()
              : level.labelEn();
          final description = prefs.language == 'fr'
              ? level.descriptionFr()
              : level.descriptionEn();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  ref.read(preferenceBlockProvider.notifier).setLevel(level),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? colors.teal.withValues(alpha: 0.10)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colors.teal : colors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected
                          ? LucideIcons.checkCircle2
                          : LucideIcons.circle,
                      size: 18,
                      color: isSelected ? colors.teal : colors.inkMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
