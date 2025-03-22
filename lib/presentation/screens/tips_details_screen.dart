import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scamurai/state_management/tips_controller.dart';

class TipDetailsScreen extends StatelessWidget {
  final TipsController tipsController = Get.find<TipsController>();

  TipDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? tip = Get.arguments as Map<String, dynamic>?;

    if (tip == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tip Details'),
        ),
        body: const Center(
          child: Text('No tip details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tip['title'] ?? 'Tip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip['title'] ?? 'No Title',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                tip['description'] ?? 'No Description',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
