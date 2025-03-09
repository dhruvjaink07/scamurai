import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onClick;
  const QuickActionButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onClick,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 5),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
