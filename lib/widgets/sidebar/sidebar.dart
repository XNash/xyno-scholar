import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../providers/generation_provider.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import 'excluded_fields_card.dart';
import 'field_selector_card.dart';
import 'free_text_panel_card.dart';
import 'level_selector_card.dart';
import 'scope_tone_mood_card.dart';

/// The docked, fixed-width left sidebar containing every preference panel,
/// each kept as its own visually distinct card, plus the generate action.
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final generation = ref.watch(generationProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return Container(
      color: colors.parchment,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FieldSelectorCard(),
                  SizedBox(height: 16),
                  ExcludedFieldsCard(),
                  SizedBox(height: 16),
                  LevelSelectorCard(),
                  SizedBox(height: 16),
                  ScopeToneMoodCard(),
                  SizedBox(height: 16),
                  FreeTextPanelCard(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: colors.parchment,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: generation.isLoading
                    ? null
                    : () => ref.read(generationProvider.notifier).generate(),
                icon: generation.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.amberOn,
                        ),
                      )
                    : const Icon(LucideIcons.sparkles, size: 18),
                label: Text(
                  generation.isLoading
                      ? (generation.streamedChars > 0
                            ? s.receiving(generation.streamedChars)
                            : s.connecting)
                      : s.generateButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
