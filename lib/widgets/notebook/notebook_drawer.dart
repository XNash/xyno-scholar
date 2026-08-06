import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/strings.dart';
import '../../models/notebook_entry.dart';
import '../../providers/notebook_provider.dart';
import '../../providers/preference_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/markdown_text.dart';

class NotebookDrawer extends ConsumerWidget {
  const NotebookDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final notebookAsync = ref.watch(notebookProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return Drawer(
      width: 440,
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Icon(LucideIcons.bookMarked, color: colors.ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.notebookTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: notebookAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    s.genericError,
                    style: TextStyle(color: colors.rose),
                  ),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          s.notebookEmpty,
                          style: TextStyle(color: colors.inkMuted),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) =>
                        _NotebookEntryCard(entry: entries[index], strings: s),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookEntryCard extends ConsumerStatefulWidget {
  final NotebookEntry entry;
  final AppStrings strings;

  const _NotebookEntryCard({required this.entry, required this.strings});

  @override
  ConsumerState<_NotebookEntryCard> createState() => _NotebookEntryCardState();
}

class _NotebookEntryCardState extends ConsumerState<_NotebookEntryCard> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.entry.personalNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.entry.topic.title,
                  style: AppTypography.serif(fontSize: 16, color: colors.ink),
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 16, color: colors.rose),
                tooltip: widget.strings.remove,
                onPressed: () =>
                    ref.read(notebookProvider.notifier).remove(widget.entry.id),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MarkdownText(widget.entry.topic.pitch),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: widget.strings.personalNotesHint,
            ),
            onChanged: (value) => ref
                .read(notebookProvider.notifier)
                .updateNotes(widget.entry.id, value),
          ),
        ],
      ),
    );
  }
}
