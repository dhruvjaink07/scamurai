import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/data/services/link_opener_service.dart';
import 'package:scamurai/state_management/news_controller.dart';
import 'package:scamurai/core/app_constants.dart';

class NewsListScreen extends StatelessWidget {
  final NewsController newsController = Get.find<NewsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Fraud News"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (newsController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsController.newsList.isEmpty) {
            return const Text("No fraud news available at the moment.");
          }

          return ListView.builder(
            itemCount: newsController.newsList.length,
            itemBuilder: (context, index) {
              final article = newsController.newsList[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Center(
                            child: Icon(
                          Icons.error,
                          color: Theme.of(context).cardColor,
                        ))),
                  ),
                ),
                title: Text(article.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(article.source),
                onTap: () => LinkOpenerService().openLinkWithBrowserChooser(
                    article.url, AppConstant.OPENING_BROWSER),
              );
            },
          );
        }),
      ),
    );
  }
}
