import 'package:dio/dio.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/data/models/news_article.dart';

class NewsService {
  final Dio _dio = Dio();

  Future<List<NewsArticle>> fetchFraudNews() async {
    // const String apiKey = AppConstant.NEWS_API;
    const String url = AppConstant.NEWS_URL;

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        List articles = response.data['articles'];
        return articles.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}
