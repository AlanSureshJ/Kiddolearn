import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LearnTimeScreen extends StatefulWidget {
  const LearnTimeScreen({super.key});

  @override
  State<LearnTimeScreen> createState() => _LearnTimeScreenState();
}

class _LearnTimeScreenState extends State<LearnTimeScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/time.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('KiddoLearn - Learn Time'),
        backgroundColor: Colors.indigo.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _controller.value.isInitialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton.icon(
                        key: ValueKey<bool>(_isPlaying),
                        onPressed: _togglePlayback,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 30,
                        ),
                        label: Text(
                          _isPlaying ? 'Pause Video' : 'Play Video',
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          shadowColor: Colors.deepOrange,
                          elevation: 10,
                        ),
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  color: Colors.deepPurple,
                  strokeWidth: 4,
                ),
        ),
      ),
    );
  }
}
