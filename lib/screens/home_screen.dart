import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../l10n/strings.dart';
import '../providers/api_key_provider.dart';
import '../providers/preference_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/notebook/notebook_drawer.dart';
import '../widgets/output/output_panel.dart';
import '../widgets/sidebar/sidebar.dart';

const _mobileBreakpoint = 900.0;
const _sidebarWidth = 420.0;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceBlockProvider);
    final colors = context.colors;
    final s = AppStrings(prefs.language);

    return Scaffold(
      endDrawer: const NotebookDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(LucideIcons.bookOpen, color: colors.amber),
            const SizedBox(width: 10),
            Text(s.appTitle),
          ],
        ),
        actions: [
          _LanguageToggle(currentLanguage: prefs.language),
          const SizedBox(width: 8),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(LucideIcons.bookMarked),
              tooltip: s.notebookTitle,
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            tooltip: s.forgetKey,
            onPressed: () => ref.read(apiKeyProvider.notifier).forget(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < _mobileBreakpoint;
          if (isMobile) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 640, child: const Sidebar()),
                  Container(height: 1, color: colors.border),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: const OutputPanel(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: _sidebarWidth,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: colors.border)),
                ),
                child: const Sidebar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: const OutputPanel(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageToggle extends ConsumerWidget {
  final String currentLanguage;

  const _LanguageToggle({required this.currentLanguage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'fr', label: Text('FR')),
        ButtonSegment(value: 'en', label: Text('EN')),
      ],
      selected: {currentLanguage},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => ref
          .read(preferenceBlockProvider.notifier)
          .setLanguage(selection.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.teal.withValues(alpha: 0.16)
              : null,
        ),
      ),
    );
  }
}
