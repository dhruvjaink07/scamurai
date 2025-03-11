import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style: TextStyle(color: isSentByUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
