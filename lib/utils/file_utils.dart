import 'dart:typed_data';
import 'dart:html' as html;

class FileUtils {
  static void downloadPdf(Uint8List bytes) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "photos.pdf")
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}