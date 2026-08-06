import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_colors.dart';

class StatusBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const StatusBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.rose.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.rose.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertTriangle, size: 18, color: colors.rose),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.ink),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(LucideIcons.x, size: 16, color: colors.inkMuted),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
