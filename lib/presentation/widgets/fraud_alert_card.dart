import 'package:flutter/material.dart';

class FraudAlertCard extends StatelessWidget {
  final String title;

  const FraudAlertCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
