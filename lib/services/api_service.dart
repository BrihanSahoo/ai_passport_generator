import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://bg-removal-backend-fastapi-production.up.railway.app";

  static Future<Uint8List?> generateA4({
    required Uint8List imageBytes,
    required String fileName,
    required int copies,
    required String size,
    required String bgColor,
    required bool bw,
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/generate-a4"),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: fileName,
        ),
      );

      request.fields["copies"] = copies.toString();
      request.fields["size"] = size;
      request.fields["bg_color"] = bgColor;
      request.fields["bw"] = bw.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        return await response.stream.toBytes();
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}