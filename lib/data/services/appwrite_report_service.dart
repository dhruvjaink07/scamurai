import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scamurai/core/app_constants.dart';

class AppwriteReportService {
  final Client client = Client();
  late Databases database;
  late Storage storage;

  AppwriteReportService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(AppConstant.PROJECT_ID);
    database = Databases(client);
    storage = Storage(client);
  }

  Future<void> saveReports({
    required String userId,
    required String scamType,
    required String description,
    required String contact,
    required String scamDate,
    PlatformFile? file,
  }) async {
    try {
      // Upload file to storage and get URL
      String? fileUrl;
      if (file != null) {
        final uploadedFile = await _uploadFile(file);
        if (uploadedFile != null) {
          fileUrl =
              'https://cloud.appwrite.io/v1/storage/buckets/${AppConstant.REPORT_BUCKET_ID}/files/${uploadedFile.$id}/view?project=${AppConstant.PROJECT_ID}';
        }
      }

      // Save report to database
      String databaseId = AppConstant.DATABASE_ID;
      String reportCollectionId = AppConstant.SCAM_REPORT_COLLECTION_ID;

      await database.createDocument(
        databaseId: databaseId,
        collectionId: reportCollectionId,
        documentId: ID.unique(),
        data: {
          "userId": userId,
          "scamType": scamType,
          "description": description,
          "scamDate": scamDate,
          "contact": contact,
          "fileUrl": fileUrl,
        },
      );
    } catch (e) {
      print("Error Saving reports: $e");
    }
  }

  Future<File?> _uploadFile(PlatformFile file) async {
    try {
      final result = await storage.createFile(
        bucketId: AppConstant.REPORT_BUCKET_ID,
        fileId: ID.unique(),
        file: InputFile(
          path: file.path!,
          filename: file.name,
        ),
      );
      return result;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }
}
