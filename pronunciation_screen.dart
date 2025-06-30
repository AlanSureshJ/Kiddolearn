import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class PronunciationCheckScreen extends StatefulWidget {
  @override
  _PronunciationCheckScreenState createState() =>
      _PronunciationCheckScreenState();
}

class _PronunciationCheckScreenState extends State<PronunciationCheckScreen> {
  late AudioPlayer player;
  String currentWord = '';
  String feedback = '';
  String recognized = '';
  List<String> mistakenPhonemes = [];
  bool isLoading = false;
  int wordCount = 0;
  String currentLevel = 'easy';
  bool isPracticeRound = false;
  int wordsPerLevel = 5;
  int currentLevelWordCount = 0;
  final levelOrder = ['easy', 'medium', 'hard'];
  int currentLevelIndex = 0;

  final recorder = AudioRecorder();

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    fetchNextWord(isPracticeRound: false, level: "easy");
  }

  Future<void> fetchNextWord(
      {required bool isPracticeRound, required String level}) async {
    setState(() => isLoading = true);

    final url = isPracticeRound
        ? 'http://192.168.0.141:5000/get_practice_words?level=$level'
        : 'http://192.168.0.141:5000/next_word?level=$level';

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        setState(() {
          if (isPracticeRound) {
            final practiceWords = json['words'];
            if (practiceWords != null && practiceWords.isNotEmpty) {
              currentWord = practiceWords[0];
            } else {
              currentWord = "say"; // fallback word
              feedback = "🎉 No common mistakes for '$level' yet!";
            }
          } else {
            currentWord = json['word'];
          }

          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch word');
      }
    } catch (e) {
      setState(() {
        currentWord = "error";
        feedback = "❌ Something went wrong while fetching the word.";
        isLoading = false;
      });
      print("fetchNextWord error: $e");
    }
  }

  Future<void> playWordAudio() async {
    final url = 'http://192.168.0.141:5000/play_word_audio?word=$currentWord';
    try {
      await player.setSourceUrl(url); // Step 1: Set the audio source
      await player.resume(); // Step 2: Start playback
      print("Playing: $url");
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  void handleNextWord() {
    setState(() {
      currentLevelWordCount++;

      // After 5 words, switch to practice
      if (!isPracticeRound && currentLevelWordCount >= wordsPerLevel) {
        isPracticeRound = true;
        currentLevelWordCount = 0;
      }
      // After practice round, go to next level
      else if (isPracticeRound) {
        isPracticeRound = false;
        currentLevelWordCount = 0;
        currentLevelIndex++;

        // End after 'hard' level
        if (currentLevelIndex >= levelOrder.length) {
          // Show summary or end screen here
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("You're done! 🎉"),
              content: Text("You've completed all levels!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
          return;
        } else {
          currentLevel = levelOrder[currentLevelIndex];
        }
      }
    });

    fetchNextWord(
      isPracticeRound: isPracticeRound,
      level: currentLevel,
    );
  }

  Future<void> playPhonemeAudio(String phoneme) async {
    final url = 'http://192.168.0.141:5000/play_phoneme_audio?phoneme=$phoneme';
    try {
      await player.setSourceUrl(url);
      await player.resume();
      print("Playing phoneme: $phoneme");
    } catch (e) {
      print("Phoneme playback error for $phoneme: $e");
    }
  }

  Future<void> recordAndSendAudio() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/recording.wav';

    bool hasPermission = await recorder.hasPermission();
    if (!hasPermission) {
      print('No mic permission!');
      return;
    }

    await recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: filePath,
    );

    await Future.delayed(Duration(seconds: 4));
    await recorder.stop();

    File audioFile = File(filePath);
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.0.141:5000/check_pronunciation'));
    request.fields['word'] = currentWord;
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));
    var response = await request.send();

    final responseString = await response.stream.bytesToString();
    final result = jsonDecode(responseString);

    setState(() {
      recognized = result['recognized_text'];
      mistakenPhonemes = List<String>.from(result['missing_phonemes']);
      feedback =
          "Accuracy: ${(result['similarity'] * 100).toStringAsFixed(1)}%";
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Widget buildPhonemeChips() {
    return Wrap(
      spacing: 8,
      children: mistakenPhonemes.map((phoneme) {
        return ActionChip(
          label: Text(phoneme.toUpperCase()),
          backgroundColor: Colors.redAccent,
          labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onPressed: () async {
            await playPhonemeAudio(phoneme);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - Pronunciation'),
        backgroundColor: Color(0xFFE27396), // Top bar pink
      ),
      backgroundColor: Color(0xFFEFCFE3), // Page background light pink
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFB3DEE2), // Blue block for the word
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      currentWord.toUpperCase(),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (recognized.isNotEmpty)
                    Text(
                      'You said: $recognized',
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 4),
                  if (feedback.isNotEmpty)
                    Text(
                      feedback,
                      style: TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 16),
                  if (mistakenPhonemes.isNotEmpty) ...[
                    Text(
                      'Tap to hear the phonemes you missed',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: mistakenPhonemes
                          .map((phoneme) => _buildPhonemeButton(phoneme))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton('Listen', playWordAudio),
                      _buildActionButton('Speak', recordAndSendAudio),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: handleNextWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE27396), // Next Word button
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Next Word',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

// Helper widget for phoneme buttons
  Widget _buildPhonemeButton(String phoneme) {
    return GestureDetector(
      onTap: () => playPhonemeAudio(phoneme),
      child: Container(
        padding: const EdgeInsets.all(20), // Increased padding
        constraints: BoxConstraints(minWidth: 60, minHeight: 60),
        decoration: BoxDecoration(
          color: Color(0xFFEAF2D7), // Greenish phoneme buttons
          shape: BoxShape.circle,
        ),
        child: Text(
          phoneme,
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }

// Helper widget for Listen/Speak buttons
  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEA9AB2), // Button pink
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
