import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import 'sidebar_card.dart';

class ExcludedFieldsCard extends ConsumerStatefulWidget {
  const ExcludedFieldsCard({super.key});

  @override
  ConsumerState<ExcludedFieldsCard> createState() => _ExcludedFieldsCardState();
}

class _ExcludedFieldsCardState extends ConsumerState<ExcludedFieldsCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(WidgetRef ref) {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    ref.read(preferenceBlockProvider.notifier).addExcludedTag(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferenceBlockProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return SidebarCard(
      title: s.excludedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prefs.excludedFields.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: prefs.excludedFields.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    deleteIcon: const Icon(LucideIcons.x, size: 14),
                    onDeleted: () => ref
                        .read(preferenceBlockProvider.notifier)
                        .removeExcludedTag(tag),
                    backgroundColor: colors.rose.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: colors.rose.withValues(alpha: 0.35),
                    ),
                  );
                }).toList(),
              ),
            ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: s.excludedHint,
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.plus, size: 18),
                onPressed: () => _submit(ref),
              ),
            ),
            onSubmitted: (_) => _submit(ref),
          ),
        ],
      ),
    );
  }
}
