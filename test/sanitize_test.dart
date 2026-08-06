import 'package:flutter_test/flutter_test.dart';
import 'package:xyno_scholar/services/sanitize.dart';

void main() {
  test('sanitizeJsonTree preserves Map<String, dynamic> after decoding', () {
    // Mirrors the shape returned by jsonDecode on a typical API response.
    final decoded = <String, dynamic>{
      'title': 'A &amp; B',
      'nested': <String, dynamic>{'value': '&#128161;'},
      'list': <dynamic>[
        <String, dynamic>{'x': '&lt;ok&gt;'},
      ],
    };

    final sanitized = sanitizeJsonTree(decoded);

    // This is the exact cast every call site performs; it must not throw.
    final result = sanitized as Map<String, dynamic>;
    expect(result['title'], 'A & B');
    expect((result['nested'] as Map<String, dynamic>)['value'], '💡');
    expect(
      ((result['list'] as List).first as Map<String, dynamic>)['x'],
      '<ok>',
    );
  });
}
