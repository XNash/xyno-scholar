import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xyno_scholar/app.dart';

void main() {
  testWidgets('Shows the API key unlock screen on first run', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: XynoScholarApp()));
    await tester.pumpAndSettle();

    expect(find.text('Entrez votre clé API Gemini'), findsOneWidget);
  });
}
