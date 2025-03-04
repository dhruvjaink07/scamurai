import 'package:get/get.dart';
import 'package:scamurai/presentation/screens/auth/login_screen.dart';
import 'package:scamurai/presentation/screens/auth/profile_setup_screen.dart';
import 'package:scamurai/presentation/screens/auth/register_screen.dart';
import 'package:scamurai/presentation/screens/home_screen.dart';
import 'package:scamurai/presentation/screens/profile_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String profileSetUpScreen = '/profile-setup';
  static const String homeScreen = '/home';
  static const String profileScreen = '/profile';
  static const String settingsScreen = '/settings';

  static final List<GetPage> routes = [
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: registerScreen, page: () => const RegisterScreen()),
    GetPage(name: profileSetUpScreen, page: () => const ProfileSetupScreen()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
  ];
}
