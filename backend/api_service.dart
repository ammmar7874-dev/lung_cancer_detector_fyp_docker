import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Replace '192.168.X.X' with YOUR laptop's IPv4 address
  // Your friend will use this to find your running model
  static const String baseUrl = "http://10.122.188.69:8000"; 

  static Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      
      // 'file' matches the 'file: UploadFile' in your FastAPI main.py
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }
}