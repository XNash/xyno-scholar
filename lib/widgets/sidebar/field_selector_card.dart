import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/field_catalog.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import 'sidebar_card.dart';

class FieldSelectorCard extends ConsumerStatefulWidget {
  const FieldSelectorCard({super.key});

  @override
  ConsumerState<FieldSelectorCard> createState() => _FieldSelectorCardState();
}

class _FieldSelectorCardState extends ConsumerState<FieldSelectorCard> {
  final _customFieldController = TextEditingController();
  final Set<String> _expandedCategories = {kDefaultFieldCatalog.first.id};

  @override
  void dispose() {
    _customFieldController.dispose();
    super.dispose();
  }

  void _submitCustomField(WidgetRef ref, String language) {
    final raw = _customFieldController.text.trim();
    if (raw.isEmpty) return;
    final id = raw.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    ref.read(preferenceBlockProvider.notifier).addField(id);
    _customFieldController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferenceBlockProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);
    final selected = prefs.fields.toSet();

    return SidebarCard(
      title: s.fieldsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selected.map((fieldId) {
                return InputChip(
                  label: Text(fieldLabel(fieldId, prefs.language)),
                  onDeleted: prefs.fields.length > 1
                      ? () => ref
                            .read(preferenceBlockProvider.notifier)
                            .toggleField(fieldId)
                      : null,
                  deleteIcon: const Icon(LucideIcons.x, size: 14),
                  backgroundColor: colors.teal.withValues(alpha: 0.12),
                  side: BorderSide(color: colors.teal.withValues(alpha: 0.4)),
                );
              }).toList(),
            ),
          if (prefs.fields.length <= 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                s.atLeastOneField,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.inkMuted),
              ),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...kDefaultFieldCatalog.map((category) {
            final isExpanded = _expandedCategories.contains(category.id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    if (isExpanded) {
                      _expandedCategories.remove(category.id);
                    } else {
                      _expandedCategories.add(category.id);
                    }
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          isExpanded
                              ? LucideIcons.chevronDown
                              : LucideIcons.chevronRight,
                          size: 16,
                          color: colors.inkMuted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category.title(prefs.language),
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 22, bottom: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: category.fields.map((field) {
                        final isSelected = selected.contains(field.id);
                        return FilterChip(
                          label: Text(field.label(prefs.language)),
                          selected: isSelected,
                          onSelected: (_) => ref
                              .read(preferenceBlockProvider.notifier)
                              .toggleField(field.id),
                          selectedColor: colors.teal.withValues(alpha: 0.16),
                          checkmarkColor: colors.teal,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
          TextField(
            controller: _customFieldController,
            decoration: InputDecoration(
              hintText: s.addCustomFieldHint,
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.plus, size: 18),
                onPressed: () => _submitCustomField(ref, prefs.language),
              ),
            ),
            onSubmitted: (_) => _submitCustomField(ref, prefs.language),
          ),
        ],
      ),
    );
  }
}
