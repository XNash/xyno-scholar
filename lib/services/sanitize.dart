import 'package:html_unescape/html_unescape.dart';

final _unescape = HtmlUnescape();

/// Recursively walks a decoded JSON tree (Map / List / String / primitives)
/// and HTML-entity-decodes every String value, so a model slip-up (e.g.
/// `&#128161;` or `&amp;`) never reaches the UI as a literal entity.
dynamic sanitizeJsonTree(dynamic value) {
  if (value is String) {
    return _unescape.convert(value);
  }
  if (value is Map) {
    // Built explicitly (rather than via `value.map(...)`) because promoting
    // a `dynamic` value to `Map` via `is Map` loses the `<String, dynamic>`
    // type arguments, so `.map()` on it silently returns `Map<dynamic,
    // dynamic>` — which then fails the `as Map<String, dynamic>` cast at
    // every call site.
    final result = <String, dynamic>{};
    value.forEach((key, v) {
      result[key as String] = sanitizeJsonTree(v);
    });
    return result;
  }
  if (value is List) {
    return value.map(sanitizeJsonTree).toList();
  }
  return value;
}
