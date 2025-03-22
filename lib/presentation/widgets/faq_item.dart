import 'package:flutter/material.dart';

class FAQItem extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const FAQItem({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
