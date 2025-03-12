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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isWeb
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset('assets/images/logo.png', height: 300),
                    ),
                    const SizedBox(width: 50),
                    const Expanded(child: LoginForm()),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', height: 250),
                    const LoginForm(),
                  ],
                ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserController _userController = Get.find<UserController>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains('user_invalid_credentials')) {
      return 'Please check the email and password you entered and try again.';
    } else if (error.contains('general_argument_invalid')) {
      return 'Password must be between 8 and 256 characters long.';
    } else if (error.contains('user_session_already_exists')) {
      return 'Creation of a session is prohibited when a session is active.';
    } else {
      return 'Unknown error occurred. $error';
    }
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _authService.login(
            email: _emailController.text, password: _passwordController.text);

        final user = await _authService.getUserDetails();
        _userController.setUser(user);
        Get.snackbar(
          "Success",
          "Logged in successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(AppRoutes.homeScreen);
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
              _login();
            },
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 10),
          CustomButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text("Login"),
          ),
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
