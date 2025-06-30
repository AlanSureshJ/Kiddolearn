import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ShapesGameScreen extends StatefulWidget {
  const ShapesGameScreen({super.key});

  @override
  State<ShapesGameScreen> createState() => _ShapesGameScreenState();
}

class _ShapesGameScreenState extends State<ShapesGameScreen> {
  final List<Shape> allShapes = [
    Shape(name: 'Circle', imagePath: 'assets/drag/images/circle.png'),
    Shape(name: 'Square', imagePath: 'assets/drag/images/square.png'),
    Shape(name: 'Rectangle', imagePath: 'assets/drag/images/rectangle.png'),
    Shape(name: 'Triangle', imagePath: 'assets/drag/images/triangle.png'),
    Shape(name: 'Star', imagePath: 'assets/drag/images/star.png'),
    Shape(name: 'Oval', imagePath: 'assets/drag/images/oval.png'),
  ];

  late List<Shape> draggableShapes;
  late List<Shape> targetShapes;
  final Map<String, bool> matched = {};
  late ConfettiController _confettiController;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    draggableShapes = List.from(allShapes)..shuffle();
    targetShapes = List.from(allShapes)..shuffle();
    for (var shape in allShapes) {
      matched[shape.name] = false;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleDrop(Shape shape, Shape incoming) {
    if (shape.name == incoming.name) {
      setState(() {
        matched[shape.name] = true;
        score++;
        _confettiController.play();
      });
      _showMessage("🎉 Great job! You matched ${shape.name}!", Colors.green);

      if (score == allShapes.length) {
        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title:
                  const Text("🎉 Well Done!", style: TextStyle(fontSize: 24)),
              content: const Text("You matched all the shapes!",
                  style: TextStyle(fontSize: 18)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  child: const Text("Play Again"),
                )
              ],
            ),
          );
        });
      }
    } else {
      _showMessage("💡 Oops! Try again!", Colors.red);
    }
  }

  void _restartGame() {
    setState(() {
      score = 0;
      matched.clear();
      draggableShapes = List.from(allShapes)..shuffle();
      targetShapes = List.from(allShapes)..shuffle();
      for (var shape in allShapes) {
        matched[shape.name] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Match the Shapes!"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.purple.shade50,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: targetShapes.map((shape) {
                    return DragTarget<Shape>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: matched[shape.name]!
                                ? Colors.green[100]
                                : Colors.white,
                            border:
                                Border.all(color: Colors.deepPurple, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: matched[shape.name]!
                                ? Image.asset(shape.imagePath,
                                    width: 60, height: 60)
                                : Text(shape.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                      onWillAccept: (_) => true,
                      onAccept: (incoming) => _handleDrop(shape, incoming),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 2, color: Colors.black),
              Expanded(
                flex: 1,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  children: draggableShapes.map((shape) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: matched[shape.name]!
                          ? const SizedBox(width: 80)
                          : Draggable<Shape>(
                              data: shape,
                              feedback: Image.asset(shape.imagePath, width: 80),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Image.asset(shape.imagePath, width: 80),
                              ),
                              child: Image.asset(shape.imagePath, width: 80),
                            ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

class Shape {
  final String name;
  final String imagePath;

  Shape({required this.name, required this.imagePath});
}
