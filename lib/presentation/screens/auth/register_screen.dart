import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'package:scamurai/presentation/widgets/custom_button.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';
import 'package:scamurai/state_management/user_controller.dart';

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
              : SingleChildScrollView(
                  child: Column(
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserController _userController = Get.find<UserController>();

  bool _isLoading = false;
  String? _passwordError;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains('user_already_exists')) {
      return 'This email is already in use. Please use a different email.';
    } else if (error.contains('general_argument_invalid')) {
      return 'Password must be between 8 and 265 characters long, and should not be one of the commonly used password. ';
    } else {
      return 'Unexpected Error: $error';
    }
  }

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _passwordError = "Passwords do not match";
        });
      } else {
        setState(() {
          _isLoading = true;
          _passwordError = null;
          _errorMessage = null;
        });

        try {
          final user = await _authService.register(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
          );
          _userController.setUser(user);
          Get.snackbar(
            "Success",
            "Account created successfully! Please complete your profile setup.",
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.toNamed(AppRoutes.profileSetUpScreen);
        } catch (e) {
          setState(() {
            _errorMessage = _getFriendlyErrorMessage(e.toString());
          });
          print(e.toString());
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
              focusNode: _nameFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "Email",
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              errorText: _passwordError,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                _register();
              },
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            CustomButton(
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text("Register"),
              onPressed: _isLoading ? null : _register,
            ),
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
      ),
    );
  }
}
