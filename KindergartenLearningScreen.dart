import 'package:flutter/material.dart';

class KindergartenLearningScreen extends StatelessWidget {
  const KindergartenLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindergarten Learning'),
        backgroundColor: Colors.blue, // Customize color if needed
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/b9.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Select a Learning Topic:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color for readability
                  ),
                ),
                const SizedBox(height: 20),

                // Learn Numbers Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/learn_numbers_2');
                  },
                  child: const Text('Learn Numbers'),
                ),
                const SizedBox(height: 20),

                // Learn Words Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/learn_words');
                  },
                  child: const Text('Learn Words'),
                ),
                const SizedBox(height: 20),

                // Pronunciation Button (Fixed Route)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/pronunciation');
                  },
                  child: const Text('Pronunciation'),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/learn_time');
                  },
                  child: const Text('Time'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
