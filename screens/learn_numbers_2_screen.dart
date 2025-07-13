import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class LearnNumbers2Screen extends StatefulWidget {
  const LearnNumbers2Screen({super.key});

  @override
  State<LearnNumbers2Screen> createState() => _LearnNumbers2ScreenState();
}

class _LearnNumbers2ScreenState extends State<LearnNumbers2Screen> {
  final List<int> numbersToTrace = List.generate(9, (index) => index + 1);
  int currentIndex = 0;
  List<Offset> userPath = [];

  void clearPath() {
    setState(() {
      userPath.clear();
    });
  }

  void nextNumber() {
    if (currentIndex < numbersToTrace.length - 1) {
      setState(() {
        currentIndex++;
        userPath.clear();
      });
    }
  }

  Future<void> giveFeedback() async {
    if (userPath.isEmpty) return;

    const canvasSize = Size(300, 300);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawColor(Colors.white, BlendMode.src);

    for (int i = 0; i < userPath.length - 1; i++) {
      canvas.drawLine(userPath[i], userPath[i + 1], paint);
    }

    final picture = recorder.endRecording();
    final userImage = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
    final byteData = await userImage.toByteData(format: ui.ImageByteFormat.png);
    final userImageBytes = byteData!.buffer.asUint8List();
    final userImg = img.decodePng(userImageBytes)!;

    final refBytes = await rootBundle
        .load('assets/numbers/${numbersToTrace[currentIndex]}.png');
    final refImgRaw = img.decodePng(refBytes.buffer.asUint8List())!;
    final refImg =
        img.copyResize(refImgRaw, width: userImg.width, height: userImg.height);

    final result = compareImages(userImg, refImg);
    double accuracy = 100 - result.clamp(0, 100);

    // Custom accuracy thresholds for numbers 1–9
    const thresholds = {
      1: 91.9,
      2: 90.8,
      3: 91.2,
      4: 94.9,
      5: 94.9,
      6: 93.3,
      7: 90.4,
      8: 91.5,
      9: 87.6,
    };

    int number = numbersToTrace[currentIndex];
    double requiredAccuracy = thresholds[number]!;

    String message;
    if (accuracy >= requiredAccuracy) {
      message = "✅ Correct! WELL DONE! 💕";
    } else {
      message = "❌ SO CLOSE KEEP TRYING!! ❤️";
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 18)),
      backgroundColor: Colors.deepPurple,
      duration: const Duration(seconds: 2),
    ));
  }

  double compareImages(img.Image a, img.Image b) {
    int totalPixels = a.width * a.height;
    int diffPixels = 0;

    for (int y = 0; y < a.height; y++) {
      for (int x = 0; x < a.width; x++) {
        final luminanceA = img.getLuminance(a.getPixel(x, y));
        final luminanceB = img.getLuminance(b.getPixel(x, y));

        if ((luminanceA - luminanceB).abs() > 35) {
          // Was 40
          diffPixels++;
        }
      }
    }

    return (diffPixels / totalPixels) * 100;
  }

  @override
  Widget build(BuildContext context) {
    int number = numbersToTrace[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("KiddoLearn - KG Trace Numbers"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("Trace the number $number",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/numbers/$number.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final local = box.globalToLocal(details.globalPosition);
                        userPath.add(local -
                            Offset(
                                (MediaQuery.of(context).size.width - 300) / 2,
                                170));
                      });
                    },
                    child: CustomPaint(
                      painter: TracePainter(userPath),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: clearPath,
                icon: const Icon(Icons.refresh),
                label: const Text("Clear"),
              ),
              ElevatedButton.icon(
                onPressed: giveFeedback,
                icon: const Icon(Icons.check),
                label: const Text("Check"),
              ),
              ElevatedButton.icon(
                onPressed: nextNumber,
                icon: const Icon(Icons.navigate_next),
                label: const Text("Next"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TracePainter extends CustomPainter {
  final List<Offset> points;

  TracePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
