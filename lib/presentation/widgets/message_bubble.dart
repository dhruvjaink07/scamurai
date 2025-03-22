import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    return GestureDetector(
      onLongPress: () {
        if (!isSentByUser) {
          Clipboard.setData(ClipboardData(text: message));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Response copied to clipboard!"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Align(
        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSentByUser ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: isSentByUser ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
