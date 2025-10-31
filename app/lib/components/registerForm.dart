import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ChatPage.dart';
import 'package:app/models/user.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _registerUser() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final String username = _controller.text;
    try {
      final response = await http.post(
        // For a real device (or an emulator that shares the network) use your computer's LAN IP (192.168.x.x).
        Uri.parse('$apiBaseUrl:3000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        globals.currentUser = User.fromJson(userJson);
        // Check that the widget is still mounted before using context
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      } else {
        print('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
      ),
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      body: Center(
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Colors.white),
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.lightGreenAccent,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Color.fromARGB(255, 39, 39, 39),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
