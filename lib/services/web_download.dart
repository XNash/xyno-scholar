import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Triggers a browser download of [content] as a text file named [filename].
void downloadTextFile(String filename, String content) {
  final blobParts = <JSAny>[content.toJS].toJS;
  final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'text/plain'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
