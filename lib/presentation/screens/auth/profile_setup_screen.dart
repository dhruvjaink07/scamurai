import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/data/services/appwrite_service.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';
import 'package:scamurai/state_management/user_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController securityAnswerController =
      TextEditingController();
  String? selectedUserType;
  String? selectedCommunication;
  final List<String> userTypes = ["Individual", "Bank Employee"];
  final List<String> communicationMethods = [
    "Email",
    "SMS",
    "In-App Notifications"
  ];

  void submitProfileData({bool isSkipped = false}) async {
    final UserController _userController = Get.find<UserController>();
    final user = _userController.getUser();

    if (!isSkipped) {
      if (phoneController.text.isEmpty ||
          dobController.text.isEmpty ||
          selectedUserType == null) {
        Get.snackbar("Error", "Please fill all required fields",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      await AppwriteService().saveUserDetails(
        userId: user?.$id ?? '',
        name: user?.name ?? '',
        email: user?.email ?? '',
        phone: phoneController.text,
        dob: dobController.text,
        userType: selectedUserType!,
        securityAnswer: securityAnswerController.text,
        preferredCommunication: selectedCommunication ?? "Email",
      );
    }

    Get.offAllNamed('/home'); // Redirect to Home Page
  }

  @override
  Widget build(BuildContext context) {
    final UserController _userController = Get.find<UserController>();
    final user = _userController.getUser();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: const Text("Complete Your Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter your details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Name
                  CustomTextField(
                    controller: TextEditingController(text: user?.name ?? ''),
                    hintText: "Name (Required)",
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  CustomTextField(
                    controller: TextEditingController(text: user?.email ?? ''),
                    hintText: "Email (Required)",
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  CustomTextField(
                      controller: phoneController,
                      hintText: "Phone Number (Required)"),
                  const SizedBox(height: 12),

                  // DOB
                  CustomTextField(
                      controller: dobController,
                      hintText: "Date of Birth (Required)"),
                  const SizedBox(height: 12),

                  // User Type Dropdown
                  const Text("Select User Type (Required)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedUserType,
                    items: userTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedUserType = value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Security Answer (Optional)
                  CustomTextField(
                      controller: securityAnswerController,
                      hintText: "Security Question Answer (Optional)"),
                  const SizedBox(height: 12),

                  // Preferred Communication Method
                  const Text("Preferred Communication Method (Optional)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<String>(
                    value: selectedCommunication,
                    items: communicationMethods
                        .map((method) => DropdownMenuItem(
                            value: method, child: Text(method)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCommunication = value),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => submitProfileData(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("Submit",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Skip Button
                  Center(
                    child: TextButton(
                      onPressed: () => submitProfileData(isSkipped: true),
                      child: const Text("Skip for Now",
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
