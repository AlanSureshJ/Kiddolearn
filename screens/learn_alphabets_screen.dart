import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LearnAlphabetsScreen extends StatefulWidget {
  const LearnAlphabetsScreen({super.key});

  @override
  _LearnAlphabetsScreenState createState() => _LearnAlphabetsScreenState();
}

class _LearnAlphabetsScreenState extends State<LearnAlphabetsScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/Alphabets.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - Learn Alphabets'),
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/b10.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Text(_controller.value.isPlaying ? "Pause" : "Play"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
