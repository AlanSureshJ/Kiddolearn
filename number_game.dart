import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class NumberMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Matching Game',
      home: GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum Difficulty { Easy, Medium, Hard }

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<ImageItem> images = [
    ImageItem('assets/1-pencil.png', 1),
    ImageItem('assets/2-cars.png', 2),
    ImageItem('assets/3-apple.png', 3),
    ImageItem('assets/4-banana.png', 4),
    ImageItem('assets/5-stars.png', 5),
    ImageItem('assets/6-kids.png', 6),
    ImageItem('assets/7-mangoes.png', 7),
    ImageItem('assets/8-strawberries.png', 8),
    ImageItem('assets/9-carrots.png', 9),
  ];

  int correctCount = 0;
  int score = 0;
  int rounds = 0;
  final int maxRounds = 5;
  String message = '';
  Color messageColor = Colors.blue;
  bool gameOver = false;
  List<ImageItem> displayedImages = [];

  late ConfettiController _confettiController;
  Timer? _timer;
  int remainingTime = 10;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    startGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startGame() {
    if (rounds >= maxRounds) {
      setState(() {
        gameOver = true;
      });
      return;
    }

    _timer?.cancel();

    final random = Random();
    final correctImage = images[random.nextInt(images.length)];
    correctCount = correctImage.count;

    // Get 5 more images that do NOT have the same count
    final distractors =
        images.where((img) => img.count != correctCount).toList()..shuffle();

    // Final displayed images (1 correct + 5 distractors)
    displayedImages = [correctImage, ...distractors.take(5)]..shuffle();

    setState(() {
      message = '';
      gameOver = false;
      remainingTime = getTimeForDifficulty();
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
      });
      if (remainingTime <= 0) {
        _timer?.cancel();
        setState(() {
          message = '⏰ Time’s up!';
          messageColor = Colors.red;
          rounds++;
        });
        Future.delayed(Duration(seconds: 2), startGame);
      }
    });
  }

  Difficulty currentDifficulty = Difficulty.Medium;

  int getTimeForDifficulty() {
    switch (currentDifficulty) {
      case Difficulty.Easy:
        return 15;
      case Difficulty.Medium:
        return 10;
      case Difficulty.Hard:
        return 5;
    }
  }

  void checkAnswer(int selectedCount) {
    _timer?.cancel();

    setState(() {
      if (selectedCount == correctCount) {
        message = '✅ Correct! Great job!';
        messageColor = Colors.green;
        score++;
        _confettiController.play();
      } else {
        message = '❌ Oops! Try again.';
        messageColor = Colors.red;
      }
      rounds++;
    });

    Future.delayed(Duration(seconds: 2), () {
      startGame();
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      rounds = 0;
      message = '';
      gameOver = false;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Matching Game'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          DropdownButton<Difficulty>(
            value: currentDifficulty,
            dropdownColor: Colors.orange.shade100,
            underline: SizedBox(),
            icon: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.settings, color: Colors.white),
            ),
            items: Difficulty.values.map((Difficulty level) {
              return DropdownMenuItem<Difficulty>(
                value: level,
                child: Text(
                  level.toString().split('.').last,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (Difficulty? newLevel) {
              if (newLevel != null) {
                setState(() {
                  currentDifficulty = newLevel;
                });
                restartGame();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/p2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: gameOver
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉 Game Over!',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your final score is: $score',
                            style: TextStyle(fontSize: 24, color: Colors.green),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: restartGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('Restart Game',
                                style: TextStyle(fontSize: 20)),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉 Match the Number with the Picture! 🎨',
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.orange,
                                fontFamily: 'ComicSans'),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Click on the image that has $correctCount objects!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '⏱ Time left: $remainingTime s',
                            style: TextStyle(
                              fontSize: 18,
                              color: remainingTime <= 3
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: displayedImages
                                .take(6)
                                .map((img) => GestureDetector(
                                      onTap: () => checkAnswer(img.count),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child:
                                            Image.asset(img.path, width: 100),
                                      ),
                                    ))
                                .toList(),
                          ),
                          SizedBox(height: 20),
                          Text(
                            message,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: messageColor),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Score: $score',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 20,
              maxBlastForce: 15,
              minBlastForce: 8,
              gravity: 0.3,
            ),
          )
        ],
      ),
    );
  }
}

class ImageItem {
  final String path;
  final int count;

  ImageItem(this.path, this.count);
}
