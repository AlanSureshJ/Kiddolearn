import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import './login_screen.dart';
import './preschool_home_screen.dart';
import './kindergarten_home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedLevel;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  int generateRandomId() {
    return Random().nextInt(900000) + 100000;
  }

  Future<void> _register() async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    int userId = generateRandomId();
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.141:5000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": userId,
          "name": name,
          "age": age,
          "email": email,
          "password": password,
          "level": selectedLevel!,
          "face_encoding": null, // No face encoding by default
        }),
      );

      final responseData = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration Successful!'),
              backgroundColor: Colors.green),
        );

        if (selectedLevel == 'Preschool') {
          Navigator.pushReplacementNamed(
              context, PreschoolHomeScreen.routeName);
        } else if (selectedLevel == 'Kindergarten') {
          Navigator.pushReplacementNamed(
              context, KindergartenHomeScreen.routeName);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect. Please try again.')),
      );
    }
  }

  Future<void> _registerWithFaceID() async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    int userId = Random().nextInt(900000) + 100000; // Generate random user ID
    setState(() => isLoading = true);

    try {
      // ✅ Step 1: Register user details
      final registerResponse = await http.post(
        Uri.parse('http://192.168.0.141:5000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": userId,
          "name": name,
          "age": age,
          "email": email,
          "password": password,
          "level": selectedLevel!,
          "face_encoding": null, // Initially no face encoding
        }),
      );

      final registerData = jsonDecode(registerResponse.body);

      if (registerResponse.statusCode != 200) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(registerData['error'] ?? 'Registration failed')),
        );
        return;
      }

      // ✅ Step 2: Capture Face
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() => isLoading = false);
        return;
      }

      File file = File(image.path);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.141:5000/face_register'),
      );
      request.fields['email'] = email; // Send the same email
      request.files.add(await http.MultipartFile.fromPath('face', file.path));

      var faceResponse = await request.send();
      var faceResponseData = await faceResponse.stream.bytesToString();
      var faceJsonResponse = jsonDecode(faceResponseData);

      setState(() => isLoading = false);

      if (faceResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Face Registration Successful!'),
              backgroundColor: Colors.green),
        );

        // Navigate based on user level
        if (selectedLevel == 'Kindergarten') {
          Navigator.pushReplacementNamed(context, '/kindergarten_home',
              arguments: email);
        } else {
          Navigator.pushReplacementNamed(context, '/preschool_home',
              arguments: email);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(faceJsonResponse['error'] ?? 'Face registration failed'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to register with Face ID: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - Registeration'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.deepPurple, // Optional: customize as you like
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/b1.jpg'), // Background image
            fit: BoxFit.cover, // To cover the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 16),
              TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age')),
              const SizedBox(height: 16),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                items: ['Preschool', 'Kindergarten']
                    .map((level) =>
                        DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Select Level'),
                onChanged: (value) => setState(() => selectedLevel = value),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _registerWithFaceID,
                            icon: const Icon(Icons.face),
                            label: const Text('Register with Face ID'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, LoginScreen.routeName),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
