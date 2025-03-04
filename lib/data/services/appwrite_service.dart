import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_service.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:get/get.dart';

class AppwriteService {
  final Client client = Client();
  late Databases database;
  late Storage storage;
  final AuthService _authService = AuthService();

  AppwriteService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(dotenv.env['PROJECT_ID']!);

    database = Databases(client);
    storage = Storage(client);
  }

  Future<void> saveUserDetails({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String userType,
    String? securityAnswer,
    String preferredCommunication = "Email",
  }) async {
    try {
      String databaseId = dotenv.env['DATABASE_ID']!;
      String userCollectionId = dotenv.env['USER_COLLECTION_ID']!;
      print(userId);

      var result = await database.createDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: {
          "createdAt": DateTime.now().toIso8601String(),
          "name": name,
          "email": email,
          "phone": phone,
          "dob": dob,
          "userType": userType,
          "securityAnswer": securityAnswer,
          "preferredCommunication": preferredCommunication,
        },
      );
      print(result);
      print("User details saved successfully");
    } catch (e) {
      print("Error Saving user details: $e");
      print(userId);
    }
  }

  Future<void> uploadProfileImage(String userId, String filePath,
      {Uint8List? webImage}) async {
    try {
      String bucketId = dotenv.env['BUCKET_ID']!;

      InputFile inputFile;
      if (kIsWeb && webImage != null) {
        inputFile = InputFile.fromBytes(
          filename: filePath.split('/').last,
          bytes: webImage,
        );
      } else {
        inputFile = InputFile.fromPath(
          path: filePath,
        );
      }

      final response = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: inputFile,
      );

      String photoUrl =
          'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/${response.$id}/view?project=${dotenv.env['PROJECT_ID']}';

      await updateUserDocument(userId, photoUrl);

      // Fetch updated user profile data
      final UserController _userController = Get.find<UserController>();
      await _userController.fetchUserProfile(userId);

      print("Profile image uploaded successfully");
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  Future<void> updateUserDocument(String userId, String photoUrl) async {
    try {
      String databaseId = dotenv.env['DATABASE_ID']!;
      String userCollectionId = dotenv.env['USER_COLLECTION_ID']!;

      var result = await database.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: {
          "photoUrl": photoUrl,
        },
      );
      print(result);
      print("User document updated with photoUrl successfully");
    } catch (e) {
      print("Error updating user document: $e");
    }
  }
}
