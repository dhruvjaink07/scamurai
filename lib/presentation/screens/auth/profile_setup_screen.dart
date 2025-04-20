import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';
import 'package:scamurai/presentation/widgets/custom_date_picker.dart';
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
  bool isUpdateMode = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final UserController userController = Get.find<UserController>();
    final userProfile = userController.getUserProfile();
    if (Get.arguments != null && Get.arguments['update'] == true) {
      isUpdateMode = true;
      if (userProfile != null) {
        phoneController.text = userProfile.data['phone'] ?? '';
        dobController.text = userProfile.data['dob'] ?? '';
        securityAnswerController.text =
            userProfile.data['securityAnswer'] ?? '';
        selectedUserType = userProfile.data['userType'];
        selectedCommunication = userProfile.data['preferredCommunication'];
      }
    }
  }

  void submitProfileData() async {
    final UserController userController = Get.find<UserController>();
    final user = userController.getUser();

    if (phoneController.text.isEmpty ||
        dobController.text.isEmpty ||
        selectedUserType == null) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (isUpdateMode) {
      await AppwriteService().updateUserDocument(
        userId: user?.$id ?? '',
        data: {
          'phone': phoneController.text,
          'dob': dobController.text,
          'userType': selectedUserType!,
          'securityAnswer': securityAnswerController.text,
          'preferredCommunication': selectedCommunication ?? "Email",
        },
      );
    } else {
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
    Get.snackbar(
      "Success",
      "Profile ${isUpdateMode ? 'Updated' : 'Created'} Successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed('/home'); // Redirect to Home Page
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final user = userController.getUser();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: Text(
          isUpdateMode ? "Update Your Profile" : "Complete Your Profile",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 1) {
                setState(() {
                  _currentStep++;
                });
              } else {
                submitProfileData();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              }
            },
            steps: [
              Step(
                title: const Text('Personal Details'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Enter your details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Name
                    CustomTextField(
                      controller: TextEditingController(text: user?.name ?? ''),
                      hintText: "Name (Required)",
                      enable: false,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    CustomTextField(
                      controller:
                          TextEditingController(text: user?.email ?? ''),
                      hintText: "Email (Required)",
                      enable: false,
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    CustomTextField(
                        isPhone: true,
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        hintText: "Phone Number (Required)"),
                    const SizedBox(height: 12),

                    // DOB
                    CustomDatePicker(
                      hintText: "Date of Birth (Required)",
                      controller: dobController,
                    ),
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
                  ],
                ),
              ),
              Step(
                title: const Text('Additional Details'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        child: Text(
                          isUpdateMode ? "Update" : "Submit",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // // Skip Button
                    // if (!isUpdateMode)
                    //   Center(
                    //     child: TextButton(
                    //       onPressed: () => submitProfileData(),
                    //       child: const Text("Skip for Now",
                    //           style:
                    //               TextStyle(fontSize: 16, color: Colors.blue)),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
