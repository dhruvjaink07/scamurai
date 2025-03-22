import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:scamurai/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(UserController()); // Initialize UserController

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scamurai',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      getPages: AppRoutes.routes,
      initialRoute: AppRoutes.splashScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
