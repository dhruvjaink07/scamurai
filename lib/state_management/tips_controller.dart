import 'package:get/get.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';

class TipsController extends GetxController {
  var isLoading = true.obs;
  var tipsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    fetchTips();
    super.onInit();
  }

  Future<void> fetchTips() async {
    try {
      final databases = AppwriteService().database;
      final response = await databases.listDocuments(
        databaseId: AppConstant.DATABASE_ID,
        collectionId: AppConstant.TIPS_COLLECTION_ID,
      );

      tipsList.value = response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print("Error fetching fraud tips: $e");
    } finally {
      isLoading(false);
    }
  }
}
