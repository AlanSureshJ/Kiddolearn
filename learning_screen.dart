import 'package:flutter/material.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - PreSchool Learning'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepPurple,
      ),
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
              padding: EdgeInsets.all(24),
              margin: EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Icon(Icons.smart_display_rounded,
                        size: 60, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Select a Learning Video:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Buttons
                  _buildVideoButton(context, 'Learn Shapes', '/learn_shapes',
                      Colors.orangeAccent),
                  SizedBox(height: 16),
                  _buildVideoButton(context, 'Learn Colors', '/learn_colors',
                      Colors.lightBlueAccent),
                  SizedBox(height: 16),
                  _buildVideoButton(context, 'Learn Numbers', '/learn_numbers',
                      Colors.greenAccent),
                  SizedBox(height: 16),
                  _buildVideoButton(context, 'Learn Alphabets',
                      '/learn_alphabets', Colors.pinkAccent),
                  SizedBox(height: 16),
                  _buildVideoButton(
                      context,
                      'Nursery Rhymes',
                      '/nursery_rhymes',
                      const Color.fromARGB(255, 255, 251, 0)),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoButton(
      BuildContext context, String label, String route, Color color) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(Icons.play_circle_fill, size: 28),
      label: Text(label, style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
