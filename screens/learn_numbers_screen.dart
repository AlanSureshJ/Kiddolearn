import 'package:flutter/material.dart';

class LearnNumbersScreen extends StatefulWidget {
  const LearnNumbersScreen({super.key});

  @override
  _LearnNumbersScreenState createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends State<LearnNumbersScreen> {
  final List<Offset?> _points = [];
  int _currentNumber = 1;

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  void _nextNumber() {
    setState(() {
      _currentNumber = (_currentNumber < 10) ? _currentNumber + 1 : 1;
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiddoLearn - Learn Numbers'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Centered Big Number to trace
          Center(
            child: Text(
              _currentNumber.toString(),
              style: TextStyle(
                fontSize: 280,
                color: Colors.grey.withOpacity(0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Drawing Area
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                _points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) => _points.add(null),
            child: CustomPaint(
              painter: TracePainter(points: _points),
              size: Size.infinite,
            ),
          ),

          // Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _clearDrawing,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                ),
                ElevatedButton.icon(
                  onPressed: _nextNumber,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TracePainter extends CustomPainter {
  final List<Offset?> points;
  TracePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(TracePainter oldDelegate) => true;
}
