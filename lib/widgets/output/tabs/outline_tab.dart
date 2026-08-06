import 'package:flutter/material.dart';
import '../../../models/outline_part.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../common/markdown_text.dart';

class OutlineTab extends StatelessWidget {
  final List<OutlinePart> parts;

  const OutlineTab({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.map((part) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    part.partNumber,
                    style: AppTypography.serif(
                      weight: FontWeight.w700,
                      color: colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part.title,
                        style: AppTypography.serif(
                          fontSize: 17,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      MarkdownText(part.description),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
