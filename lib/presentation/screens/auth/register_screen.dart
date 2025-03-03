import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'package:scamurai/presentation/widgets/custom_button.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                    const Expanded(child: RegisterForm()),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/auth_side_card.png',
                        height: 200),
                    const SizedBox(height: 20),
                    const RegisterForm(),
                  ],
                ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String? _passwordError;

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordError = "Passwords do not match";
        });
      } else {
        setState(() {
          _passwordError = null;
        });
        try {
          final user = await _authService.register(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
          Get.toNamed(AppRoutes.homeScreen, arguments: user);
          // Navigate to the login screen or another screen
        } catch (e) {
          // Handle registration error
          print(e);
        }
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
          const Text("Join Us!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Create your account",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          CustomTextField(
            hintText: "Name",
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          CustomTextField(
            hintText: "Confirm Password",
            obscureText: true,
            controller: _confirmPasswordController,
            errorText: _passwordError,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomButton(text: "Register", onPressed: _register),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.loginScreen);
              },
              child: const Text("Already have an account? Login",
                  style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }
}
