import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/data/services/phishing_detection_service.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:share_handler/share_handler.dart';

class ScamDetectionScreen extends StatefulWidget {
  @override
  _ScamDetectionScreenState createState() => _ScamDetectionScreenState();
}

class _ScamDetectionScreenState extends State<ScamDetectionScreen> {
  final ScamDetectionService _scamDetectionService = ScamDetectionService();
  StreamSubscription<SharedMedia>? _streamSubscription;
  TextEditingController _messageController = TextEditingController();
  String? sharedText;
  Map<String, dynamic>? _apiResponse; // To store the API response
  bool _isLoading = false; // To track loading state

  @override
  void initState() {
    super.initState();
    _handleSharedData();
  }

  Future<void> _handleSharedData() async {
    final handler = ShareHandlerPlatform.instance;

    // Get initial shared content when app is opened via sharing intent
    SharedMedia? initialMedia = await handler.getInitialSharedMedia();
    if (initialMedia?.content != null) {
      setState(() {
        sharedText = initialMedia!.content;
        _messageController.text = sharedText!;
      });
    }

    // Listen for shared content while app is running
    _streamSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      if (media.content != null) {
        setState(() {
          sharedText = media.content;
          _messageController.text = sharedText!;
        });
      }
    });

    // Get shared content from navigation arguments
    final String? sharedContent = Get.arguments;
    if (sharedContent != null) {
      setState(() {
        sharedText = sharedContent;
        _messageController.text = sharedText!;
      });
    }
  }

  void _verifyMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar("Error", "Please enter a message to verify.");
      return;
    }

    setState(() {
      _isLoading = true;
      _apiResponse = null;
    });

    final response = await _scamDetectionService.detectScam(message);

    setState(() {
      _isLoading = false;
      if (response != null) {
        _apiResponse = response;

        final UserController _userController = Get.find<UserController>();
        final userId = _userController.getUser()?.$id;
        // Replace with the correct user ID property
        if (userId != null) {
          AppwriteService().updateUserStatistics(
            userId: userId,
            isPhishy: response["prediction"] == "PHISHING",
          );
        }
      } else {
        Get.snackbar(
            "Error", "Failed to verify the message. Please try again.");
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cleanup
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scam Detection")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter the message to verify:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Paste the message here...",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyMessage,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Verify Message"),
              ),
              const SizedBox(height: 20),
              if (_apiResponse != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _apiResponse!["prediction"] == "PHISHING"
                          ? "This message is Phishy."
                          : "This message is Not Phishy.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _apiResponse!["prediction"] == "PHISHING"
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ExpansionTile(
                      title: const Text(
                        "Advanced Report",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _apiResponse!.entries
                                .where((entry) =>
                                    entry.key != "message" &&
                                    entry.key != "url" &&
                                    entry.key !=
                                        "status") // Exclude "message" and "url"
                                .map((entry) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
