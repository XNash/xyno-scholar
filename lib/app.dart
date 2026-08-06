import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/api_key_provider.dart';
import 'screens/home_screen.dart';
import 'screens/key_entry_screen.dart';
import 'theme/app_theme.dart';

class XynoScholarApp extends ConsumerWidget {
  const XynoScholarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyState = ref.watch(apiKeyProvider);

    return MaterialApp(
      title: 'Xyno Scholar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: apiKeyState.isUnlocked
          ? const HomeScreen()
          : const KeyEntryScreen(),
    );
  }
}
