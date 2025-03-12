import 'package:dio/dio.dart';
import 'package:scamurai/core/api_endpoints.dart';

class ChatbotService {
  final Dio _dio = Dio();

  Future<String?> getChatResponse(String prompt) async {
    try {
      final response = await _dio.post(
          "${APIENDPOINTS.BASE_URL}/finance/chat-bot",
          data: {"prompt": prompt});
      String message = response.data['message'];
      return message;
    } catch (e) {
      print("Error getting chat response: $e");
      return null;
    }
  }
}
