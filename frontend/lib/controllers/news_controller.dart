import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsController extends GetxController {
  final isLoading = true.obs;
  final articles = <dynamic>[].obs;

  // Note: Ideally, API keys should be in a secure config file or environment variable.
  final String _apiKey = '28c5b3e1b1fd461497549b607d978131';
  final String _baseUrl = 'https://newsapi.org/v2/everything';

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?q=lung-cancer&language=en&sortBy=publishedAt&apiKey=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        articles.value = data['articles'] ?? [];
      } else {
        // print removed'Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      // print removed'Error fetching news: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchArticleUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not launch article.");
    }
  }
}
