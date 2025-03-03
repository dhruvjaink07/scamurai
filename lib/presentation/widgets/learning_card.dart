import 'package:flutter/material.dart';

class LearningCard extends StatelessWidget {
  final String title;

  const LearningCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
