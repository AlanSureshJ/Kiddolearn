import 'package:flutter/material.dart';
import 'package:kiddolearn/screens/profile_screen.dart';

class KindergartenHomeScreen extends StatelessWidget {
  static const routeName = '/kindergarten_home';

  final String email;

  const KindergartenHomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - KG Home'),
        backgroundColor: Colors.deepPurple, // Optional: customize as you like
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/b7.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Welcome to the Kindergarten Home Page!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/learning'),
                  child: const Text('Learning'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/games_kindergarten'),
                  child: const Text('Games'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    ProfileScreen.routeName,
                    arguments: email,
                  ),
                  child: const Text('Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
