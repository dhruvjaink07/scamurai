import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scamurai/data/services/appwrite_service.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final UserController _userController = Get.find<UserController>();
      final user = _userController.getUser();
      if (user != null) {
        if (kIsWeb) {
          Uint8List webImage = await image.readAsBytes();
          await AppwriteService()
              .uploadProfileImage(user.$id, image.name, webImage: webImage);
        } else {
          await AppwriteService().uploadProfileImage(user.$id, image.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController _userController = Get.find<UserController>();
    final userProfile = _userController.getUserProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/profile-setup'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userProfile == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profile Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text("Name: ${userProfile.data['name'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Text("Email: ${userProfile.data['email'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Text("Phone: ${userProfile.data['phone'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Text("Date of Birth: ${userProfile.data['dob'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Text("User Type: ${userProfile.data['userType'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  Text(
                      "Preferred Communication: ${userProfile.data['preferredCommunication'] ?? 'N/A'}"),
                  const SizedBox(height: 10),
                  userProfile.data['photoUrl'] != null
                      ? Image.network(userProfile.data['photoUrl'])
                      : const Text("No profile image"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickAndUploadImage,
                    child: const Text("Upload Profile Image"),
                  ),
                ],
              ),
      ),
    );
  }
}
