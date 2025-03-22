import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final UserController userController = Get.find<UserController>();
      final user = userController.getUser();
      if (user != null) {
        if (kIsWeb) {
          Uint8List webImage = await image.readAsBytes();
          await AppwriteService()
              .uploadProfileImage(user.$id, image.name, webImage: webImage);
        } else {
          await AppwriteService().uploadProfileImage(user.$id, image.path);
        }
        // Fetch updated user profile data
        await userController.fetchUserProfile(user.$id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    userController.getUserProfile();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                Get.toNamed('/profile-setup', arguments: {'update': true}),
          ),
        ],
      ),
      body: Obx(() {
        final userProfile = userController.getUserProfile();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: userProfile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userProfile.data['photoUrl'] != null
                              ? NetworkImage(userProfile.data['photoUrl'])
                              : const AssetImage('assets/images/ngo_logo.png')
                                  as ImageProvider,
                          backgroundColor: Colors.grey[200],
                          child: userProfile.data['photoUrl'] == null
                              ? const Icon(Icons.camera_alt, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(userProfile.data['name'] ?? "User Name",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent)),
                      const SizedBox(height: 8),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.email, 'Email',
                                  userProfile.data['email'] ?? "Not specified"),
                              _buildInfoRow(Icons.phone, 'Phone',
                                  userProfile.data['phone'] ?? "Not specified"),
                              _buildInfoRow(Icons.cake, 'Date of Birth',
                                  userProfile.data['dob'] ?? "Not specified"),
                              _buildInfoRow(
                                  Icons.person,
                                  'User Type',
                                  userProfile.data['userType'] ??
                                      "Not specified"),
                              _buildInfoRow(
                                  Icons.message,
                                  'Preferred Communication',
                                  userProfile.data['preferredCommunication'] ??
                                      "Not specified"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            await AuthService().logout();
            UserController().clearUserProfile();
            Get.offAllNamed('/login');
          },
          label: const Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          )),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
              child: Text('$title: $value',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
