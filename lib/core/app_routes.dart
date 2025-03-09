import 'package:get/get.dart';
import 'package:scamurai/presentation/screens/auth/login_screen.dart';
import 'package:scamurai/presentation/screens/auth/profile_setup_screen.dart';
import 'package:scamurai/presentation/screens/auth/register_screen.dart';
import 'package:scamurai/presentation/screens/home_screen.dart';
import 'package:scamurai/presentation/screens/profile_screen.dart';
import 'package:scamurai/presentation/screens/reports_screen.dart';
import 'package:scamurai/presentation/screens/website_verifier_screen.dart';
import 'package:scamurai/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String profileSetUpScreen = '/profile-setup';
  static const String homeScreen = '/home';
  static const String profileScreen = '/profile';
  static const String settingsScreen = '/settings';
  static const String splashScreen = '/splash-screen';
  static const String verifyWebsiteScreen = '/verify-website';
  static const String reportScamScreen = '/report-scam';
  static final List<GetPage> routes = [
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: registerScreen, page: () => const RegisterScreen()),
    GetPage(name: profileSetUpScreen, page: () => const ProfileSetupScreen()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: verifyWebsiteScreen, page: () => VerifyWebsiteScreen()),
    GetPage(name: reportScamScreen, page: () => const ReportScamScreen()),
  ];
}
