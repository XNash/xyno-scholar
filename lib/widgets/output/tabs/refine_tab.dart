import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/strings.dart';
import '../../../theme/app_colors.dart';

const _presetsFr = [
  'Décale la période vers le XVIIIe siècle',
  'Plus de sources primaires',
  'Un angle plus ludique',
  'Réduis la portée géographique',
];

const _presetsEn = [
  'Shift the period to the 18th century',
  'More primary sources',
  'A more playful angle',
  'Narrow the geographic scope',
];

class RefineTab extends StatefulWidget {
  final String language;
  final bool isRefining;
  final ValueChanged<String> onSubmit;

  const RefineTab({
    super.key,
    required this.language,
    required this.isRefining,
    required this.onSubmit,
  });

  @override
  State<RefineTab> createState() => _RefineTabState();
}

class _RefineTabState extends State<RefineTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String instruction) {
    if (instruction.trim().isEmpty) return;
    widget.onSubmit(instruction.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = AppStrings(widget.language);
    final presets = widget.language == 'fr' ? _presetsFr : _presetsEn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              return ActionChip(
                label: Text(preset, style: const TextStyle(fontSize: 12)),
                onPressed: widget.isRefining ? null : () => _submit(preset),
                backgroundColor: colors.teal.withValues(alpha: 0.08),
                side: BorderSide(color: colors.teal.withValues(alpha: 0.3)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: s.refinePlaceholder),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: widget.isRefining
                  ? null
                  : () {
                      _submit(_controller.text);
                      _controller.clear();
                    },
              icon: widget.isRefining
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.amberOn,
                      ),
                    )
                  : const Icon(LucideIcons.wand2, size: 16),
              label: Text(widget.isRefining ? s.generating : s.refineButton),
            ),
          ),
        ],
      ),
    );
  }
}
