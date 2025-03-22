import 'package:appwrite/appwrite.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/app_constants.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:get/get.dart';

class AppwriteService {
  final Client client = Client();
  late Databases database;
  late Storage storage;

  AppwriteService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(AppConstant.PROJECT_ID);

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
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;
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
      String bucketId = AppConstant.BUCKET_ID;

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
          'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/${response.$id}/view?project=${AppConstant.PROJECT_ID}';

      await updateDocumentWithProfile(userId, photoUrl);

      // Fetch updated user profile data
      final UserController _userController = Get.find<UserController>();
      await _userController.fetchUserProfile(userId);

      print("Profile image uploaded successfully");
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  Future<void> updateDocumentWithProfile(String userId, String photoUrl) async {
    try {
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;

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

  Future<void> updateUserDocument({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;

      var result = await database.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: data,
      );
      print(result);
      print("User document updated successfully");
    } catch (e) {
      print("Error updating user document: $e");
    }
  }

  // Method to initialize statistics for a user
  Future<void> initializeUserStatistics(String userId) async {
    try {
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;

      // Fetch the user document
      final document = await database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
      );

      // Check if statistics fields exist, if not, initialize them
      if (!document.data.containsKey("phishyCount") ||
          !document.data.containsKey("notPhishyCount")) {
        await database.updateDocument(
          databaseId: databaseId,
          collectionId: userCollectionId,
          documentId: userId,
          data: {
            "phishyCount": 0,
            "notPhishyCount": 0,
          },
        );
        print("User statistics initialized successfully.");
      }
    } catch (e) {
      print("Error initializing user statistics: $e");
    }
  }

  // Method to update user-specific statistics
  Future<void> updateUserStatistics({
    required String userId,
    required bool isPhishy,
  }) async {
    try {
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;

      // Fetch the current statistics
      final document = await database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
      );

      int phishyCount = document.data["phishyCount"] ?? 0;
      int notPhishyCount = document.data["notPhishyCount"] ?? 0;

      // Update the count based on the result
      if (isPhishy) {
        phishyCount++;
      } else {
        notPhishyCount++;
      }

      // Update the document in the database
      await database.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: {
          "phishyCount": phishyCount,
          "notPhishyCount": notPhishyCount,
        },
      );

      print("User statistics updated successfully.");
    } catch (e) {
      print("Error updating user statistics: $e");
    }
  }

  // Method to retrieve user-specific statistics
  Future<Map<String, int>> getUserStatistics(String userId) async {
    try {
      String databaseId = AppConstant.DATABASE_ID;
      String userCollectionId = AppConstant.USER_COLLECTION_ID;

      final document = await database.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
      );

      return {
        "phishyCount": document.data["phishyCount"] ?? 0,
        "notPhishyCount": document.data["notPhishyCount"] ?? 0,
      };
    } catch (e) {
      print("Error retrieving user statistics: $e");
      return {"phishyCount": 0, "notPhishyCount": 0};
    }
  }
}
