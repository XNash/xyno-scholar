import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A single visually-distinct card in the sidebar dock. Multiple of these are
/// stacked, never merged into one mega-card.
class SidebarCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const SidebarCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: colors.ink),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
