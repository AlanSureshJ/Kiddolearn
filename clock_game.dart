import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LearnClock extends StatefulWidget {
  const LearnClock({super.key});

  @override
  _LearnClockState createState() => _LearnClockState();
}

class _LearnClockState extends State<LearnClock>
    with SingleTickerProviderStateMixin {
  final List<Map<String, int>> questions = [
    {'hour': 3, 'minute': 15},
    {'hour': 6, 'minute': 30},
    {'hour': 9, 'minute': 45},
    {'hour': 10, 'minute': 45},
    {'hour': 1, 'minute': 45},
  ];

  int currentQuestionIndex = 0;
  int score = 0;
  double hourAngle = 0.0;
  double minuteAngle = 0.0;
  bool isSettingHour = true; // Start by setting the hour
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  String getCurrentQuestionText() {
    final question = questions[currentQuestionIndex];
    return "Set the clock to ${question['hour']} : ${question['minute']}";
  }

  void resetClock() {
    setState(() {
      hourAngle = 0.0;
      minuteAngle = 0.0;
      isSettingHour = true;
    });
  }

  void checkAnswer() {
    final question = questions[currentQuestionIndex];
    final targetHour = question['hour']! % 12;
    final targetMinute = question['minute']!;

    final currentHour = (hourAngle / (pi / 6)).round() % 12;
    final currentMinute = (minuteAngle / (pi / 30)).round() % 60;

    if (currentHour == targetHour && currentMinute == targetMinute) {
      setState(() {
        score++;
        nextQuestion();
      });
      showMessage("Correct! Well done!", true);
    } else {
      showMessage("Wrong! Try again.", false);
    }
  }

  void nextQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex + 1) % questions.length;
      resetClock();
    });
  }

  void showMessage(String message, bool isCorrect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(message),
        content: Lottie.asset(
          isCorrect ? 'assets/success.json' : 'assets/try_again.json',
          height: 150,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clockSize = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: Text('Time Game'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Takes you back to the previous screen
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.pink.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getCurrentQuestionText(),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Score: $score/${questions.length}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onPanUpdate: (details) {
                    final offset = details.localPosition -
                        Offset(clockSize / 2, clockSize / 2);
                    final angle = atan2(offset.dy, offset.dx) + pi / 2;

                    setState(() {
                      if (isSettingHour) {
                        hourAngle = angle;
                      } else {
                        minuteAngle = angle;
                      }
                    });
                  },
                  onPanEnd: (_) {
                    if (isSettingHour) {
                      setState(() {
                        isSettingHour = false;
                      });
                    }
                  },
                  child: CustomPaint(
                    size: Size(clockSize, clockSize),
                    painter: ClockPainter(
                        hourAngle: hourAngle, minuteAngle: minuteAngle),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: checkAnswer, child: Text("Submit")),
                    ElevatedButton(onPressed: resetClock, child: Text("Reset")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  ClockPainter({required this.hourAngle, required this.minuteAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintCircle);

    final paintBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paintBorder);

    final paintHourHand = Paint()
      ..color = Colors.black
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    final paintMinuteHand = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final hourHandLength = radius * 0.5;
    final minuteHandLength = radius * 0.7;

    canvas.drawLine(
      center,
      Offset(center.dx + hourHandLength * cos(hourAngle - pi / 2),
          center.dy + hourHandLength * sin(hourAngle - pi / 2)),
      paintHourHand,
    );

    canvas.drawLine(
      center,
      Offset(center.dx + minuteHandLength * cos(minuteAngle - pi / 2),
          center.dy + minuteHandLength * sin(minuteAngle - pi / 2)),
      paintMinuteHand,
    );

    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 1; i <= 12; i++) {
      final angle = i * pi / 6;
      final x = center.dx + (radius * 0.85) * cos(angle - pi / 2);
      final y = center.dy + (radius * 0.85) * sin(angle - pi / 2);

      textPainter.text = TextSpan(
          text: '$i', style: TextStyle(color: Colors.black, fontSize: 16));
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, y - 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
