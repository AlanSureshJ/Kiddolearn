import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColorGame(),
    );
  }
}

class ColorGame extends StatefulWidget {
  const ColorGame({super.key});

  @override
  ColorGameState createState() => ColorGameState();
}

class ColorGameState extends State<ColorGame>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int questionNumber = 0;
  final int totalQuestions = 10;
  late ConfettiController _confettiController;
  late AnimationController _buttonController;

  late AudioPlayer _audioPlayer;
  bool showWrongIcon = false;

  final List<Color> allColors = [
    const Color(0xFFF61808),
    Colors.blue,
    Colors.yellow,
    const Color(0xFF46ED4B),
    Colors.orange,
    Colors.pink,
    const Color(0xFF6D4131),
    Colors.black,
    Colors.white,
    Colors.grey
  ];

  final List<String> colorNames = [
    "RED",
    "BLUE",
    "YELLOW",
    "GREEN",
    "ORANGE",
    "PINK",
    "BROWN",
    "BLACK",
    "WHITE",
    "GREY"
  ];

  List<int> usedIndexes = [];
  int targetIndex = 0;
  List<int> choices = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);
    generateNewQuestion();
  }

  void generateNewQuestion() {
    if (usedIndexes.length >= totalQuestions) {
      showFinalScore();
      return;
    }

    setState(() {
      int newTarget;
      do {
        newTarget = Random().nextInt(allColors.length);
      } while (usedIndexes.contains(newTarget));

      usedIndexes.add(newTarget);
      targetIndex = newTarget;
      choices = generateRandomChoices(targetIndex);
      showWrongIcon = false;
    });
  }

  List<int> generateRandomChoices(int correctIndex) {
    List<int> tempChoices = [correctIndex];
    while (tempChoices.length < 4) {
      int randomIndex = Random().nextInt(allColors.length);
      if (!tempChoices.contains(randomIndex)) {
        tempChoices.add(randomIndex);
      }
    }
    tempChoices.shuffle();
    return tempChoices;
  }

  void checkAnswer(int index) {
    if (index == targetIndex) {
      _confettiController.play();
      setState(() {
        score += 10;
        showWrongIcon = false;
      });
      nextQuestion();
    } else {
      setState(() {
        score = max(0, score - 1);
        showWrongIcon = true;
      });
    }
  }

  void nextQuestion() {
    if (questionNumber < totalQuestions - 1) {
      setState(() {
        questionNumber++;
        generateNewQuestion();
      });
    } else {
      showFinalScore();
    }
  }

  void showFinalScore() {
    String resultMessage;
    if (score >= 90) {
      resultMessage = "Superstar! 🌟 You're a Color Genius!";
    } else if (score >= 70) {
      resultMessage = "Awesome Job! 🎨 Keep Practicing!";
    } else if (score >= 50) {
      resultMessage = "Great Try! 💪 Let's Play Again!";
    } else {
      resultMessage = "Don't Worry! 🌈 Try Again and Have Fun!";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Your Score: $score / 100\n\n$resultMessage"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                score = 0;
                questionNumber = 0;
                usedIndexes.clear();
                generateNewQuestion();
              });
              Navigator.of(context).pop();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void disposee() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - Learn Colors'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.deepPurple, // Optional: customize as you like
      ),
      body: Stack(
        children: [
          // Gradient Background with Animated Circles
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 66, 194, 254), // soft blue
                  Color.fromARGB(255, 244, 182, 84), // soft orange
                  Color.fromARGB(255, 252, 128, 172), // soft pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ...List.generate(8, (index) {
            final size = 20.0 + Random().nextDouble() * 20;
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            double left, top;

            do {
              left = Random().nextDouble() * screenWidth;
              top = Random().nextDouble() * screenHeight;
            } while (left > screenWidth * 0.3 &&
                left < screenWidth * 0.7 &&
                top > screenHeight * 0.3 &&
                top < screenHeight * 0.7);

            final opacity = 0.15 + Random().nextDouble() * 0.1;

            return AnimatedPositioned(
              duration: Duration(seconds: 10 + index),
              curve: Curves.easeInOut,
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                ),
              ),
            );
          }),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎨 Find the colour Kiddo!',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                      color: Color.fromARGB(255, 79, 7, 7)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Score: $score / 100',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 87, 115)),
                ),
                const SizedBox(height: 10),
                Text(
                  'Question: ${questionNumber + 1} / $totalQuestions',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 173, 0, 132)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pick the color: ${colorNames[targetIndex]}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 72, 28, 56)),
                  ),
                ),
                if (showWrongIcon)
                  const Text(
                    'Wrong Attempt! Please Try again...❌',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 188, 34, 34)),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  children: choices.map((index) {
                    return ScaleTransition(
                      scale: _buttonController,
                      child: GestureDetector(
                        onTap: () => checkAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: allColors[index],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  spreadRadius: 2),
                            ],
                          ),
                          width: 80,
                          height: 80,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 8,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: allColors,
            ),
          ),
        ],
      ),
    );
  }
}
