import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NurseryRhymesScreen extends StatefulWidget {
  const NurseryRhymesScreen({super.key});

  @override
  _NurseryRhymesScreenState createState() => _NurseryRhymesScreenState();
}

class _NurseryRhymesScreenState extends State<NurseryRhymesScreen> {
  late VideoPlayerController _controller;
  String currentVideo = 'assets/Twinkle.mp4'; // Default video

  @override
  void initState() {
    super.initState();
    _initializeVideo(currentVideo);
  }

  void _initializeVideo(String videoPath) {
    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      })
      ..setLooping(true);
  }

  void _switchVideo(String newVideo) {
    _controller.pause();
    _controller.dispose();
    setState(() {
      currentVideo = newVideo;
      _initializeVideo(currentVideo);
    });
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
        title: const Text(
          'KiddoLearn - Nursery Rhymes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const CircularProgressIndicator(),

            const SizedBox(height: 30),

            // Play/Pause Button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 28,
              ),
              label: Text(
                _controller.value.isPlaying ? "Pause" : "Play",
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Song Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => _switchVideo('assets/Twinkle.mp4'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Twinkle Twinkle",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _switchVideo('assets/JOHNY.mp4'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Johny Johny",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
