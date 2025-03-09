import 'package:flutter/material.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/data/services/link_opener_service.dart';

class VerifyWebsiteScreen extends StatefulWidget {
  final String? receivedLink;
  VerifyWebsiteScreen({super.key, this.receivedLink});

  @override
  _VerifyWebsiteScreenState createState() => _VerifyWebsiteScreenState();
}

class _VerifyWebsiteScreenState extends State<VerifyWebsiteScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _verificationResult;

  void _verifyWebsite() async {
    setState(() {
      _isLoading = true;
      _verificationResult = null;
    });

    // Simulate a delay for the verification process
    await Future.delayed(const Duration(seconds: 2));

    // Implement your website verification logic here
    // For demonstration purposes, we'll assume that any URL containing "safe" is safe
    final url = _urlController.text;
    // if (url.contains("safe")) {
    // setState(() {
    //   _verificationResult = "This website is safe.";
    // });
    LinkOpenerService()
        .openLinkWithBrowserChooser(url, AppConstant.OPENING_BROWSER);
    // } else {
    // setState(() {
    // _verificationResult = "This website is potentially fraudulent.";
    // });
    // }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.receivedLink != null) {
      _urlController.text = widget.receivedLink!;
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
