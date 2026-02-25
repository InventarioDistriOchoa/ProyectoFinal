// lib/utils/web_download.dart
import 'dart:typed_data';
import 'dart:html' as html;

void downloadBytesWeb(Uint8List bytes, String fileName, String mime) {
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final a = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.children.add(a);
  a.click();
  a.remove();

  html.Url.revokeObjectUrl(url);
}
