import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/data/services/default_app_settings_service.dart';
import 'package:scamurai/data/services/phishing_detection_service.dart';
import 'package:scamurai/data/services/link_opener_service.dart';

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
        if (response["prediction"] == "LEGITIMATE") {
          _verificationResult = "This website is safe.";

          // Open the website in the browser after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            LinkOpenerService().openLinkWithBrowserChooser(
              url,
              AppConstant.OPENING_BROWSER,
            );
          });
        } else {
          _verificationResult = "This website might be a scam.";
        }
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
                child: Text("Change default browser"),
                onTap: () {
                  DefaultAppSettingsService().openDefaultAppSettings();
                },
              ),
              PopupMenuItem(
                child: Text("Paste"),
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
              Text(
                _verificationResult!,
                style: TextStyle(
                  fontSize: 16,
                  color: _verificationResult == "This website is safe."
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
