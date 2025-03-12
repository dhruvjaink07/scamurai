import 'package:flutter/material.dart';
import 'package:scamurai/data/services/chatbot_service.dart';
import 'package:scamurai/presentation/widgets/input_field.dart';
import '../widgets/message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String userMessage = _messageController.text;
      setState(() {
        _messages.add({"message": userMessage, "isSentByUser": true});
        _messageController.clear();
      });

      String? botResponse = await _chatbotService.getChatResponse(userMessage);
      if (botResponse != null) {
        setState(() {
          _messages.add({"message": botResponse, "isSentByUser": false});
        });
      }
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
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
                        controller: _messageController)),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
