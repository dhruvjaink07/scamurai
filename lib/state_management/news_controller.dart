import 'package:get/get.dart';
import 'package:scamurai/data/models/news_article.dart';
import 'package:scamurai/data/services/news_service.dart';

class NewsController extends GetxController {
  var newsList = <NewsArticle>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchNews();
    super.onInit();
  }

  void fetchNews() async {
    try {
      isLoading(true);
      var articles = await NewsService().fetchFraudNews();
      newsList.assignAll(articles);
    } finally {
      isLoading(false);
    }
  }
}
