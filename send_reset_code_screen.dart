import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendResetCodeScreen extends StatefulWidget {
  final String email;
  static const routeName = '/send-reset-code';

  const SendResetCodeScreen({super.key, required this.email});

  @override
  State<SendResetCodeScreen> createState() => _SendResetCodeScreenState();
}

class _SendResetCodeScreenState extends State<SendResetCodeScreen> {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.email); // ✅ Pre-fill email
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await http.post(
      Uri.parse('http://192.168.0.141:5000/send-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text.trim()}),
    );

    setState(() {
      _isLoading = false;
    });

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset code sent to your email!')),
      );
      Navigator.pushNamed(
        context,
        '/reset-password',
        arguments: {'email': _emailController.text.trim()}, // ✅ Pass as a Map
      );
    } else {
      setState(() {
        _errorMessage = responseData['error'] ?? "Failed to send reset code.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.pink.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(24),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.lock_outline,
                        size: 60, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Enter your email to receive a reset code:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sendResetCode,
                            icon: Icon(Icons.send),
                            label: Text("Send Code",
                                style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
