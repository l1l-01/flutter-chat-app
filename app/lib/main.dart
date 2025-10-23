import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Public Chat', home: const ChatPage());
  }
}

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: const Center(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    print('send: $text'); // replace with your send logic
    _controller.clear();
    // optionally: Scroll list, update UI, etc.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Public Chat',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: Container(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: 250,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Username",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This is a message",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 39, 39, 39),
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
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
