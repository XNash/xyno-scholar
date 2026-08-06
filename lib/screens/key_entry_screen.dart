import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/strings.dart';
import '../providers/api_key_provider.dart';
import '../providers/preference_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

final _mistralConsoleUri = Uri.parse('https://console.mistral.ai/');

class KeyEntryScreen extends ConsumerStatefulWidget {
  const KeyEntryScreen({super.key});

  @override
  ConsumerState<KeyEntryScreen> createState() => _KeyEntryScreenState();
}

class _KeyEntryScreenState extends ConsumerState<KeyEntryScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    ref.read(keyRejectedMessageProvider.notifier).state = null;
    ref
        .read(apiKeyProvider.notifier)
        .setKey(key, rememberForSession: _remember);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final language = ref.watch(preferenceBlockProvider).language;
    final rejectedMessage = ref.watch(keyRejectedMessageProvider);
    final s = AppStrings(language);

    return Scaffold(
      backgroundColor: colors.parchment,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.bookOpen,
                              color: colors.amber,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              s.appTitle,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.appSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.inkMuted),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.unlockTitle,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.unlockSubtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.inkMuted),
                              ),
                              const SizedBox(height: 20),
                              if (rejectedMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.rose.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colors.rose.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.alertTriangle,
                                        size: 16,
                                        color: colors.rose,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          s.keyRejected,
                                          style: TextStyle(color: colors.ink),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              TextField(
                                controller: _controller,
                                obscureText: _obscure,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: s.apiKeyLabel,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? LucideIcons.eye
                                          : LucideIcons.eyeOff,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                style: AppTypography.mono(
                                  fontSize: 14,
                                  color: colors.ink,
                                ),
                                onSubmitted: (_) => _submit(),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => launchUrl(
                                    _mistralConsoleUri,
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  icon: const Icon(
                                    LucideIcons.externalLink,
                                    size: 14,
                                  ),
                                  label: Text(
                                    s.getApiKeyLink,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Switch(
                                    value: _remember,
                                    onChanged: (v) =>
                                        setState(() => _remember = v),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      s.rememberSession,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: colors.inkMuted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(s.unlockButton),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
