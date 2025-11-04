import 'registerForm.dart';
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _msgs = [];
  bool _isSending = false;
  bool _isLoading = true;

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _fetchMsgs();
    _connectSocket();
  }

  void _connectSocket() {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];

    socket = IO.io(
      '$apiBaseUrl:3000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) => print('Connected to socket server'));
    socket.onDisconnect((_) => print('Disconnected from socket'));

    socket.on('newMsg', (data) {
      print('New message received: $data');
      if (mounted) {
        setState(() {
          _msgs.add({
            'id': data['id'],
            'content': data['content'],
            'username': data['user']['username'],
          });
        });
      }
    });
  }

  Future<void> _fetchMsgs() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    if (apiBaseUrl == null) {
      print('Missing API_BASE_URL');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl:3000/api/msgs/last-20'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        setState(() {
          _msgs = data
              .map(
                (msg) => {
                  'id': msg['id'],
                  'content': msg['content'],
                  'username': msg['user']['username'],
                },
              )
              .toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

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
    if (id == null) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _msgs.length,
              itemBuilder: (context, index) {
                final msg = _msgs[index];
                final isCurrentUser =
                    msg['username'] == globals.currentUser?.username;
                return Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.lightGreen
                          : const Color.fromARGB(255, 218, 218, 218),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['username'],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 31, 31, 31),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          msg['content'],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 31, 31, 31),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                  backgroundColor: _isSending ? Colors.grey : Colors.lightGreen,
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
