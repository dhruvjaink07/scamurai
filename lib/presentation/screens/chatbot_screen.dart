import 'package:flutter/material.dart';
import 'package:scamurai/data/services/chatbot_service.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';
import 'package:scamurai/presentation/widgets/loading_animation.dart';
import '../widgets/message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  bool _isLoading = false; // Track loading state

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String userMessage = _messageController.text;
      setState(() {
        _messages.add({"message": userMessage, "isSentByUser": true});
        _messageController.clear();
        _isLoading = true; // Start loading animation
      });

      String? botResponse = await _chatbotService.getChatResponse(userMessage);
      setState(() {
        _isLoading = false; // Stop loading animation
        if (botResponse != null) {
          _messages.add({"message": botResponse, "isSentByUser": false});
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount:
                  _messages.length + (_isLoading ? 1 : 0), // Add 1 for loading
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  // Show loading animation at the end
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LoadingAnimation(),
                  );
                }
                return MessageBubble(
                  message: _messages[index]["message"],
                  isSentByUser: _messages[index]["isSentByUser"],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "Enter Your Query",
                    controller: _messageController,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
