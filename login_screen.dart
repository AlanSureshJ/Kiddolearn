import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kiddolearn/screens/registration_screen.dart';
import 'package:kiddolearn/screens/send_reset_code_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Connecting State class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  // ignore: unused_field

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the standard login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'http://192.168.0.141:5000/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim().toLowerCase(),
          "password": _passwordController.text.trim(),
        }),
      );
      print("🔄 Sending request to: $apiUrl");

      setState(() {
        _isLoading = false;
      });

      final responseData = jsonDecode(response.body);
      print('🔹 API Response: $responseData');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login Successful!'),
              backgroundColor: Colors.green),
        );

        String userLevel =
            responseData['level']?.toString().toLowerCase() ?? 'guest';
        print('✅ User Level: $userLevel');

        if (userLevel == 'kindergarten') {
          Navigator.pushReplacementNamed(
            context,
            '/kindergarten_home',
            arguments: {
              "email": _emailController.text.trim(),
              "name": responseData['name'] ?? 'Unknown',
            },
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/preschool_home',
            arguments: {
              "email": _emailController.text.trim(),
              "name": responseData['name'] ?? 'Unknown',
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error'] ?? 'Login failed'),
              backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to connect. Check your internet and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithFace() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No image selected"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'http://192.168.0.141:5000/face_login';
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..files.add(await http.MultipartFile.fromPath('face', image.path));
    print("🔄 Sending request to: $apiUrl");

    try {
      final response = await request.send();
      final responseData = jsonDecode(await response.stream.bytesToString());

      setState(() {
        _isLoading = false;
      });

      print('🔹 Face Login API Response: $responseData');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Face Login Successful!'),
              backgroundColor: Colors.green),
        );

        String userEmail = responseData['email'];
        String userName = responseData['name'] ?? 'Unknown';
        String userLevel = responseData['level']?.toLowerCase() ?? 'guest';

        print('✅ Logged in as: $userEmail');

        Navigator.pushReplacementNamed(
          context,
          userLevel == 'kindergarten'
              ? '/kindergarten_home'
              : '/preschool_home',
          arguments: {"email": userEmail, "name": userName},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error'] ?? 'Face login failed'),
              backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to connect. Try again.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/b3.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/kid_logo.png',
                    height: 200), // Kid-friendly logo
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.85),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.85),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your password' : null,
                  onEditingComplete: _login,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 201, 82, 122),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Sign In',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loginWithFace,
                              icon: const Icon(Icons.face),
                              label: const Text('Login with Face'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 91, 190, 91),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SendResetCodeScreen.routeName);
                  },
                  child: const Text('Forgot Password?',
                      style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegistrationScreen.routeName);
                  },
                  child: const Text('Create New Account',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
