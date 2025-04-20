import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';
import 'package:scamurai/data/services/default_app_settings_service.dart';
import 'package:scamurai/data/services/phishing_detection_service.dart';
import 'package:scamurai/data/services/link_opener_service.dart';
import 'package:scamurai/state_management/user_controller.dart';

class VerifyWebsiteScreen extends StatefulWidget {
  final String? receivedLink;
  const VerifyWebsiteScreen({super.key, this.receivedLink});

  @override
  _VerifyWebsiteScreenState createState() => _VerifyWebsiteScreenState();
}

class _VerifyWebsiteScreenState extends State<VerifyWebsiteScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ScamDetectionService _scamDetectionService = ScamDetectionService();
  bool _isLoading = false;
  String? _verificationResult;
  Map<String, dynamic>? _apiResponse;

  void _verifyWebsite() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _verificationResult = "Please enter a valid URL.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationResult = null;
    });

    final response = await _scamDetectionService.detectScam(url);

    setState(() {
      _isLoading = false;
      if (response != null) {
        final UserController userController = Get.find<UserController>();
        final user = userController.getUser();
        if (response["prediction"] == "LEGITIMATE") {
          _verificationResult = "This website is safe.";

          // Update user-specific statistics for not phishy URLs
          AppwriteService()
              .updateUserStatistics(userId: user?.$id ?? '', isPhishy: false);

          // Open the website in the browser after 3 seconds
          // Future.delayed(const Duration(seconds: 3), () {
          //   LinkOpenerService().openLinkWithBrowserChooser(
          //     url,
          //     AppConstant.OPENING_BROWSER,
          //   );
          // });
        } else {
          _verificationResult = "This website might be a scam.";

          // Update user-specific statistics for phishy URLs
          AppwriteService()
              .updateUserStatistics(userId: user?.$id ?? '', isPhishy: true);

          // Show alert dialog for phishy websites
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Warning: Phishy Website"),
                content: const Text(
                    "This website might be a scam. Are you sure you want to open it?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("Go Back"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      LinkOpenerService().openLinkWithBrowserChooser(
                        url,
                        AppConstant.OPENING_BROWSER,
                      );
                    },
                    child: const Text("Open Anyway"),
                  ),
                ],
              );
            },
          );
        }

        // Store the full API response
        _apiResponse = response;
      } else {
        _verificationResult = "Failed to verify the website. Please try again.";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final receivedLink = Get.arguments as String?;
    if (receivedLink != null) {
      _urlController.text = receivedLink;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Website"),
        actions: [
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: const Text("Change default browser"),
                onTap: () {
                  DefaultAppSettingsService().openDefaultAppSettings();
                },
              ),
              PopupMenuItem(
                child: const Text("Paste"),
                onTap: () async {
                  final clipboardData =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  if (clipboardData != null && clipboardData.text != null) {
                    _urlController.text = clipboardData.text!;
                  }
                },
              ),
            ];
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter the website URL to verify:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "https://example.com",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyWebsite,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Verify"),
              ),
              const SizedBox(height: 20),
              if (_verificationResult != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _verificationResult!,
                      style: TextStyle(
                        fontSize: 16,
                        color: _verificationResult == "This website is safe."
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_verificationResult == "This website is safe." &&
                        _apiResponse?["url"] != null)
                      ElevatedButton(
                        onPressed: () {
                          LinkOpenerService().openLinkWithBrowserChooser(
                            _apiResponse!["url"],
                            AppConstant.OPENING_BROWSER,
                          );
                        },
                        child: const Text("Open in Browser"),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              if (_apiResponse != null)
                ExpansionTile(
                  title: const Text(
                    "Detailed Response",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _apiResponse!.entries
                            .where(
                                (entry) => entry.key != "url") // Exclude "url"
                            .map((entry) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${entry.key}: ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(
                                        child: Text(entry.value.toString()),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
