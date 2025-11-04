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
  final ScrollController _scrollController = ScrollController();
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
      if (mounted) {
        setState(() {
          _msgs.add({
            'id': data['id'],
            'content': data['content'],
            'username': data['user']['username'],
          });
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _fetchMsgs() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    if (apiBaseUrl == null) return;

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
        _scrollToBottom();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _send() async {
    if (_isSending) return;
    final message = _controller.text.trim();
    final id = globals.currentUser?.id;
    if (message.isEmpty || id == null) return;

    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    if (apiBaseUrl == null) return;

    setState(() => _isSending = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl:3000/api/send-msg/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': message}),
      );
      if (response.statusCode == 201) {
        _controller.clear();
        _scrollToBottom();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _deregister() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final userId = globals.currentUser?.id;
    if (apiBaseUrl == null || userId == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl:3000/api/deregister/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 && mounted) {
        globals.currentUser = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Register()),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = globals.currentUser?.username ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        title: Text(
          "Public Chat",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _deregister,
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 255, 73, 73),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(213, 100, 255, 219),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D0D0D),
                    Color(0xFF151515),
                    Color(0xFF0D0D0D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
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
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrentUser
                              ? const Color.fromARGB(110, 100, 255, 219)
                              : Colors.white10,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['username'],
                            style: TextStyle(
                              color: isCurrentUser
                                  ? const Color.fromARGB(207, 100, 255, 219)
                                  : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['content'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF151515),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color.fromARGB(188, 100, 255, 219),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: "Message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isSending ? null : _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isSending
                        ? Colors.grey
                        : Color.fromARGB(188, 100, 255, 219),
                  ),
                  child: const Icon(Icons.send, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
