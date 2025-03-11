import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_handler/share_handler.dart';

class ScamDetectionScreen extends StatefulWidget {
  @override
  _ScamDetectionScreenState createState() => _ScamDetectionScreenState();
}

class _ScamDetectionScreenState extends State<ScamDetectionScreen> {
  StreamSubscription<SharedMedia>? _streamSubscription;
  TextEditingController _messageController = TextEditingController();
  String? sharedText;

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

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cleanup
    _messageController.dispose();
    super.dispose();
  }

  void _verifyMessage() {
    // Implement your message verification logic here
    Get.snackbar("Verification", "Message verification logic goes here.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scam Detection")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              onPressed: _verifyMessage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Verify Message"),
            ),
          ],
        ),
      ),
    );
  }
}
