import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class DetectionService extends GetxService {
  // Use the IP provided by you.
  // Note: Ensure your phone/emulator is on the same network.
  // For Emulator use '10.0.2.2' if the server is on the host machine.
  // Current Machine IP: 192.168.1.115
  final String _apiUrl = 'http://192.168.1.115:8000/predict';

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    // 1. Client-Side Validation: Ensure Image is X-Ray like (Grayscale)
    await _validateXray(imagePath);

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // DEBUG LOGGING
        // print removed"RAW API RESPONSE: ${response.body}");
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse;

        // Handle case where API returns a list or wrapped in 'results'
        if (data is Map &&
            data.containsKey('results') &&
            data['results'] is List) {
          if ((data['results'] as List).isNotEmpty) {
            data = data['results'][0];
          }
        }

        // Parse Probabilities safely
        Map<String, dynamic> rawProbs = {};
        // API returns 'all_probabilities', checking both just in case
        var probsData = data['all_probabilities'] ?? data['probabilities'];

        if (probsData != null) {
          if (probsData is Map) {
            rawProbs = Map<String, dynamic>.from(probsData);
          }
        }

        // Ensure values are doubles and normalize keys
        Map<String, double> cleanProbs = {};
        rawProbs.forEach((key, value) {
          // 1. Normalize Key (Normal, Benign, Malignant)
          String normalizedKey =
              key.substring(0, 1).toUpperCase() +
              key.substring(1).toLowerCase();

          // 2. Parse Value
          double val = 0.0;
          if (value is num) {
            val = value.toDouble();
          } else if (value is String) {
            val = double.tryParse(value) ?? 0.0;
          }
          cleanProbs[normalizedKey] = val;
        });

        final result = {
          "image_path": imagePath,
          "prediction": data['prediction'] ?? 'Unknown',
          "true_label": data['true_label'] ?? 'N/A',
          "confidence": (data['confidence'] ?? 0.0).toDouble(),
          "probabilities": cleanProbs, // Fixed: Restored field
          "details": data['details'] ?? {},
          "raw_data": data, // PASS FULL RAW DATA FOR DEBUGGING
          "timestamp": FieldValue.serverTimestamp(), // Add server timestamp
        };

        // VALIDATION: If confidence is too low/ambiguous, treating it as "Not a valid X-Ray"
        // Adjust threshold as needed (e.g. 0.60)
        if ((result['confidence'] as double) < 0.40) {
          throw "Image Unrecognized. Please upload a clear Lung X-Ray.";
        }

        // SAVE TO FIRESTORE
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('history')
                .add(result);
          }
        } catch (e) {
          // print removed"Failed to save to history: $e");
          // Continue execution, don't block user
        }

        // print removed"PARSED DATA SENT TO UI: $result");
        return result;
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar(
        "API Error",
        "Analysis Failed: ${e.toString()}",
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
      // STRICT MODE: Rethrow for UI handling
      rethrow;
    }
  }

  /// Validates if an image is likely an X-Ray (Grayscale/Black & White)
  Future<void> _validateXray(String path) async {
    final File imageFile = File(path);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      return; // Could not decode.
    }

    // Check a sample of pixels (e.g., center 100x100 or stride)
    // X-Rays have R, G, B values very close to each other.

    int colorfulPixels = 0;
    int totalChecked = 0;
    int step = 10; // Check every 10th pixel for speed

    for (int y = 0; y < decodedImage.height; y += step) {
      for (int x = 0; x < decodedImage.width; x += step) {
        final pixel = decodedImage.getPixel(x, y);
        // Correct way to access channels in 'image' v4
        final num r = pixel.r;
        final num g = pixel.g;
        final num b = pixel.b;

        // Calculate variance/saturation
        // If Red, Green, Blue difference is high, it's colorful
        if ((r - g).abs() > 15 || (r - b).abs() > 15 || (g - b).abs() > 15) {
          colorfulPixels++;
        }
        totalChecked++;
      }
    }

    // If more than 5% of pixels are colorful, reject it.
    if (totalChecked == 0) {
      return;
    }

    double colorfulRatio = colorfulPixels / totalChecked;
    // print removed"Image Colorful Ratio: ${(colorfulRatio * 100).toStringAsFixed(2)}%");

    if (colorfulRatio > 0.05) {
      throw "Invalid Image: This appears to be a colored photo, not an X-Ray. Please upload a valid Chest X-Ray.";
    }
  }
}
