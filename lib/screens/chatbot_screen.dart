// lib/screens/chatbot_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// A data class for chat messages
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final String _apiUrl = 'https://mry1412-cms-chatbot.hf.space/chat';

  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();
    _textController.clear();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': text}),
      );

      String modelResponse;
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        modelResponse = decodedResponse['answer'] ?? 'Sorry, no answer was returned.';
      } else {
        modelResponse = 'Error: Could not connect to the server. Please try again later.';
      }

      setState(() {
        _messages.add(ChatMessage(text: modelResponse, isUser: false));
      });

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: 'Oops! A network error occurred. Please check your connection and try again.',
            isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMS Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            // --- THIS IS THE KEY LOGIC CHANGE ---
            // If the message list is empty, show the intro view.
            // Otherwise, show the list of chat bubbles.
            child: _messages.isEmpty
                ? _buildIntroView(theme)
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 10),
                  Text("Assistant is typing...", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          _buildTextInput(theme),
        ],
      ),
    );
  }

  // --- NEW WIDGET: The introductory view shown when the chat is empty ---
  Widget _buildIntroView(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to the CMS Assistant!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'I can help you with questions about UAE health insurance and our services.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Text(
              'You can ask things like:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildExampleChip('How do I get health insurance?'),
            _buildExampleChip('Health insurance for resident expatriates'),
            _buildExampleChip('Can my family get insurance?'),
          ],
        ),
      ),
    );
  }

  // Helper widget to style the example question chips
  Widget _buildExampleChip(String text) {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // The rest of the file remains the same
  // ... _buildTextInput and _buildMessageBubble methods ...

  Widget _buildTextInput(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
            style: IconButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser ? theme.primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}