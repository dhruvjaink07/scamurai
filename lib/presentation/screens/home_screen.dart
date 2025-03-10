import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/presentation/screens/website_verifier_screen.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_handler/share_handler.dart';
import '../widgets/fraud_alert_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/learning_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel(AppConstant.LINK_CHANNEL);
  static const defaultBrowserChannel =
      MethodChannel(AppConstant.BROWSER_CHANNEL);

  String? _latestLink;
  bool _isInitialized = false; // Ensures we check the link only once.
  bool _isDefaultBrowser = false;
  StreamSubscription<SharedMedia>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _receiveLinkFromNative();
    _checkIfDefaultBrowser();
    _handleSharedData();
  }

  Future<void> _handleSharedData() async {
    final handler = ShareHandlerPlatform.instance;

    // Get initial shared content when app is opened via sharing intent
    SharedMedia? initialMedia = await handler.getInitialSharedMedia();
    if (initialMedia?.content != null) {
      Get.toNamed(AppRoutes.scamDetection, arguments: initialMedia!.content);
    }

    // Listen for shared content while app is running
    _streamSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      if (media.content != null) {
        Get.toNamed(AppRoutes.scamDetection, arguments: media.content);
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cleanup
    super.dispose();
  }

  /// Receives the link when the app is opened via a link
  Future<void> _receiveLinkFromNative() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == "receivedLink") {
        setState(() {
          _latestLink = call.arguments;
          _isInitialized = true; // Mark initialization as done
        });
      }
    });
  }

  /// Checks if the app is set as the default browser
  Future<void> _checkIfDefaultBrowser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool hasPrompted =
          prefs.getBool('hasPromptedDefaultBrowser') ?? false;

      if (!hasPrompted) {
        final bool result =
            await defaultBrowserChannel.invokeMethod("isDefaultBrowser");
        setState(() {
          _isDefaultBrowser = result;
        });

        if (!result) {
          _showDefaultBrowserPrompt();
        }

        // Set the flag to true after showing the prompt
        await prefs.setBool('hasPromptedDefaultBrowser', true);
      }
    } on PlatformException catch (e) {
      print("Failed to check default browser: ${e.message}");
    }
  }

  /// Shows a dialog prompting the user to set this app as the default browser
  void _showDefaultBrowserPrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Set as Default Browser"),
          content: const Text(
              "To enhance the experience, set this app as the default browser."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openDefaultAppSettings();
              },
              child: const Text("Set Now"),
            ),
          ],
        ),
      );
    });
  }

  /// Opens the Default Apps settings to allow the user to set this app as the default browser
  void _openDefaultAppSettings() {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      intent.launch();
    }
  }

  /// Opens the received link in an external browser
  void _openInExternalBrowser() async {
    if (_latestLink != null && await canLaunchUrl(Uri.parse(_latestLink!))) {
      await launchUrl(Uri.parse(_latestLink!),
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open the link")),
      );
    }
  }

  void verifyWebsite() {
    Get.toNamed(AppRoutes.verifyWebsiteScreen);
  }

  void reportScam() {
    Get.toNamed(AppRoutes.reportScamScreen);
  }

  void detectScamInText() {
    Get.toNamed(AppRoutes.scamDetection);
  }

  @override
  Widget build(BuildContext context) {
    final UserController _userController = Get.find<UserController>();
    final user = _userController.getUser();
    bool isWeb = MediaQuery.of(context).size.width > 600;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        _userController.fetchUserProfile(user.$id);
      }
    });

    return Builder(builder: (context) {
      if (_latestLink != null && _isInitialized) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scamurai"),
            actions: [
              IconButton(
                onPressed: _openInExternalBrowser,
                icon: const Icon(Icons.open_in_browser),
                tooltip: "Open in Browser",
              ),
            ],
          ),
          body: VerifyWebsiteScreen(receivedLink: _latestLink!),
        );
      } else {
        return homeScreen(user, context, isWeb);
      }
    });
  }

  Scaffold homeScreen(User? user, BuildContext context, bool isWeb) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scamurai"),
        actions: [
          IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.profileScreen);
              },
              icon: const Icon(Icons.person_4_rounded)),
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
                children: [
                  QuickActionButton(
                    icon: Icons.report,
                    label: "Report Scam",
                    onClick: reportScam,
                  ),
                  QuickActionButton(
                    icon: Icons.search,
                    label: "Verify Website",
                    onClick: verifyWebsite,
                  ),
                  QuickActionButton(
                    icon: Icons.lock,
                    label: "Secure Account",
                    onClick: detectScamInText,
                  ),
                  QuickActionButton(
                    icon: Icons.book,
                    label: "Learn More",
                    onClick: verifyWebsite,
                  ),
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
