import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/data/services/auth_service.dart';
import 'package:scamurai/state_management/user_controller.dart';
import '../widgets/fraud_alert_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/learning_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController _userController = Get.find<UserController>();
    final user = _userController.getUser();
    final AuthService _authService = AuthService();
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scamurai"),
        actions: [
          IconButton(
              onPressed: () async {
                await _authService.logout();
                _userController.clearUser();
                Get.offAllNamed(AppRoutes.loginScreen);
              },
              icon: const Icon(Icons.notifications)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Text(
                "👋 Welcome Back, ${user?.name ?? 'User'}!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),

              // Fraud Alerts Section
              const Text("🚨 Latest Scam Alerts"),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    FraudAlertCard(title: "Phishing Attack Detected"),
                    FraudAlertCard(title: "Fake UPI Payment Alert"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions
              const Text("⚡ Quick Actions"),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: isWeb ? 4 : 2,
                childAspectRatio: 1.5,
                children: const [
                  QuickActionButton(icon: Icons.report, label: "Report Scam"),
                  QuickActionButton(
                      icon: Icons.search, label: "Verify Website"),
                  QuickActionButton(icon: Icons.lock, label: "Secure Account"),
                  QuickActionButton(icon: Icons.book, label: "Learn More"),
                ],
              ),

              const SizedBox(height: 20),

              // Learning Hub
              const Text("📚 Fraud Prevention Tips"),
              const SizedBox(height: 10),
              const LearningCard(title: "How to spot phishing emails?"),
              const LearningCard(title: "Best security practices for banking"),

              const SizedBox(height: 20),

              // Recent Scams List
              const Text("🔥 Recent Scam Reports"),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text("Fake Paytm KYC Verification Scam"),
                subtitle: const Text("Reported: 2 hours ago"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text("WhatsApp Loan Fraud"),
                subtitle: const Text("Reported: 1 day ago"),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
