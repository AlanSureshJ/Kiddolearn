import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class LearnWordsScreen extends StatelessWidget {
  const LearnWordsScreen({super.key});

  final List<Map<String, String>> words = const [
    {'word': 'Apple', 'image': 'assets/apple.png'},
    {'word': 'Ball', 'image': 'assets/ball.png'},
    {'word': 'Cat', 'image': 'assets/cat.png'},
    {'word': 'Dog', 'image': 'assets/dog.png'},
    {'word': 'Elephant', 'image': 'assets/elephant.png'},
    {'word': 'Fish', 'image': 'assets/fish.png'},
    {'word': 'Bat', 'image': 'assets/bat.png'},
    {'word': 'Umbrella', 'image': 'assets/umbrella.png'},
    {'word': 'Tiger', 'image': 'assets/tiger.png'},
    {'word': 'Octopus', 'image': 'assets/octopus.png'},
    {'word': 'Ice', 'image': 'assets/ice.png'},
    {'word': 'Banana', 'image': 'assets/banana.png'},
    {'word': 'Rainbow', 'image': 'assets/rainbow.png'},
  ];

  Future<void> _playWordAudio(String word) async {
    final player = AudioPlayer();
    final url =
        'http://192.168.0.141:5000/audio/pronounce/${word.toLowerCase()}.mp3';

    try {
      await player.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing audio for $word: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiddoLearn - Learn Words'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: words.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final item = words[index];
            return GestureDetector(
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🔊 Say "${item['word']}"')),
                );
                await _playWordAudio(item['word']!);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item['image']!,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['word']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
