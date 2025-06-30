import 'package:flutter/material.dart';

class PreschoolHomeScreen extends StatelessWidget {
  static const routeName = '/preschool_home';

  final String email;

  const PreschoolHomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - PreSchool'),
        backgroundColor: Colors.deepPurple, // Optional: customize as you like
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/b4.jpg', // Ensure this image exists in your assets folder
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.7), // Soft overlay
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to KiddoLearn!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildButton(context, 'Learn', '/learn', Colors.blue),
                const SizedBox(height: 15),
                _buildButton(context, 'Play Games', '/games', Colors.orange),
                const SizedBox(height: 15),
                _buildButton(context, 'Profile', '/profile', Colors.green,
                    arguments: email),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, String route, Color color,
      {dynamic arguments}) {
    return ElevatedButton(
      onPressed: () =>
          Navigator.pushNamed(context, route, arguments: arguments),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
