import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'package:scamurai/presentation/widgets/custom_button.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';
import 'package:scamurai/state_management/user_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset('assets/images/auth_side_card.png',
                          height: 300),
                    ),
                    const SizedBox(width: 50),
                    Expanded(child: LoginForm()),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/auth_side_card.png',
                        height: 100),
                    const SizedBox(height: 20),
                    LoginForm(),
                  ],
                ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  LoginForm({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserController _userController = Get.find<UserController>();

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Create a session
        await _authService.login(
            email: _emailController.text, password: _passwordController.text);

        // Fetch user details
        final user = await _authService.getUserDetails();

        // Set user details in UserController
        _userController.setUser(user);

        // Navigate to the home screen
        Get.toNamed(AppRoutes.homeScreen);
      } catch (e) {
        // Handle login error
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome Back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Please login to your account",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          CustomTextField(
            hintText: "Email",
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: "Password",
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomButton(text: "Login", onPressed: _login),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.registerScreen);
              },
              child: const Text("New user? Register yourself",
                  style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }
}
