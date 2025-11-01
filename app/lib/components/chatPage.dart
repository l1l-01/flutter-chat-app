import 'registerForm.dart';
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _send() async {
    if (_isSending) {
      print("We're still sending your previous message");
      return;
    }
    final String message = _controller.text.trim();
    final num? id = globals.currentUser?.id;
    if (message.isEmpty) {
      print("Message is empty");
      return;
    }
    if (id == null || id is! num) {
      print("Id is not a number");
      return;
    }
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    if (apiBaseUrl == null) {
      print('Missing API_BASE_URL');
      return;
    }
    setState(() {
      _isSending = true;
    });
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl:3000/api/send-msg/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': message}),
      );

      if (response.statusCode == 201) {
        print("Your message was sent successfully");
      } else {
        print("Unexpected Error");
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isSending = false);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deregister() async {
    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final userId = globals.currentUser?.id;

      final response = await http.delete(
        Uri.parse('$apiBaseUrl:3000/api/deregister/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        globals.currentUser = null;
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Register()),
        );
      } else {
        print('Failed to deregister: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = globals.currentUser?.username ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
        actions: [
          IconButton(
            onPressed: _deregister,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: SizedBox(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: 250,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.lightGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Username",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 31, 31, 31),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This is a message",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 31, 31, 31),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 31, 31, 31),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Color.fromARGB(255, 58, 58, 58),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Icon(
                  Icons.send,
                  color: Color.fromARGB(255, 31, 31, 31),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
