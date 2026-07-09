import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final List<String> _messages = [];

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add('You: $text'));
    _controller.clear();

    // Try to call Gemini endpoint if API key provided in .env as GP_API_KEY
    final apiKey = dotenv.env['GP_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      setState(
        () => _messages.add(
          'Assistant: (offline stub) Stay calm; move to well-lit area.',
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$apiKey',
      );
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body:
            '{"contents":[{"parts":[{"text":"$text"}]}],"systemInstruction":{"parts":[{"text":"You are a concise safety assistant."}]}}',
      );
      if (resp.statusCode == 200) {
        setState(() => _messages.add('Assistant: (live) Response received'));
      } else {
        setState(() => _messages.add('Assistant: (error ${resp.statusCode})'));
      }
    } catch (e) {
      setState(() => _messages.add('Assistant: (request failed)'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_messages[i]),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask the Safety Assistant...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
