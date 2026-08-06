import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/field_catalog.dart';
import '../../providers/preference_providers.dart';
import '../../services/field_detection.dart';
import '../../theme/app_colors.dart';
import 'sidebar_card.dart';

const _examplesFr = [
  'Les vitraux de la cathédrale de Chartres au XIIIe siècle',
  'La réception de la Bible dans la peinture baroque italienne',
  'Le concile de Trente et l\'art sacré',
  'Pèlerinages médiévaux et architecture romane',
];

const _examplesEn = [
  'Stained glass windows of Chartres Cathedral in the 13th century',
  'The reception of the Bible in Italian Baroque painting',
  'The Council of Trent and sacred art',
  'Medieval pilgrimage routes and Romanesque architecture',
];

class FreeTextPanelCard extends ConsumerStatefulWidget {
  const FreeTextPanelCard({super.key});

  @override
  ConsumerState<FreeTextPanelCard> createState() => _FreeTextPanelCardState();
}

class _FreeTextPanelCardState extends ConsumerState<FreeTextPanelCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(freeTextProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setText(String value) {
    ref.read(freeTextProvider.notifier).state = value;
    ref.read(dismissedFieldSuggestionsProvider.notifier).state = {};
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferenceBlockProvider);
    final freeText = ref.watch(freeTextProvider);
    final dismissed = ref.watch(dismissedFieldSuggestionsProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);
    final examples = prefs.language == 'fr' ? _examplesFr : _examplesEn;

    final suggestions = detectImpliedFields(
      freeText,
      prefs.fields,
    ).where((m) => !dismissed.contains(m.fieldId)).toList();

    return SidebarCard(
      title: s.freeTextTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: s.freeTextHint),
            onChanged: _setText,
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...suggestions.map((match) {
              final label = fieldLabel(match.fieldId, prefs.language);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.amber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.lightbulb, size: 15, color: colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: colors.ink),
                          children: [
                            TextSpan(text: '${s.fieldSuggestionPrefix} '),
                            TextSpan(
                              text: label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(preferenceBlockProvider.notifier)
                            .addField(match.fieldId);
                      },
                      child: Text(s.addField),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      tooltip: s.dismiss,
                      onPressed: () {
                        ref
                            .read(dismissedFieldSuggestionsProvider.notifier)
                            .state = {
                          ...dismissed,
                          match.fieldId,
                        };
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 12),
          Text(s.examplesLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: examples.map((example) {
              return ActionChip(
                label: Text(example, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  _controller.text = example;
                  _setText(example);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
