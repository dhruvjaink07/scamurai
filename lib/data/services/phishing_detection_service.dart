import 'package:dio/dio.dart';
import 'package:scamurai/core/api_endpoints.dart';

class ScamDetectionService {
  final String _baseUrl = "${APIENDPOINTS.BASE_URL}/phishing/predict";
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> detectScam(String url) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {"url": url},
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        print("Error: ${response.statusCode} - ${response.data}");
        return null;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return null;
    }
  }
}
