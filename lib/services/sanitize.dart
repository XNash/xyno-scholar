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
    return value.map((key, v) => MapEntry(key, sanitizeJsonTree(v)));
  }
  if (value is List) {
    return value.map(sanitizeJsonTree).toList();
  }
  return value;
}
