import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ProblematiqueCallout extends ConsumerWidget {
  final String problematique;
  final String language;

  const ProblematiqueCallout({
    super.key,
    required this.problematique,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final s = AppStrings(language);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problematique,
            style: AppTypography.serif(
              style: FontStyle.italic,
              weight: FontWeight.w500,
              fontSize: 19,
              color: colors.parchment,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: colors.parchment),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: problematique));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.copied)));
                }
              },
              icon: const Icon(LucideIcons.copy, size: 15),
              label: Text(s.copyProblematique),
            ),
          ),
        ],
      ),
    );
  }
}
