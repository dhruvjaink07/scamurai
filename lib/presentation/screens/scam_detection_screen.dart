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
      setState(() => sharedText = initialMedia!.content);
    }

    // Listen for shared content while app is running
    _streamSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      if (media.content != null) {
        setState(() => sharedText = media.content);
      }
    });

    // Get shared content from navigation arguments
    final String? sharedContent = Get.arguments;
    if (sharedContent != null) {
      setState(() => sharedText = sharedContent);
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cleanup
    super.dispose();
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
            const Text("Shared Content:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              sharedText ?? "No text received",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
