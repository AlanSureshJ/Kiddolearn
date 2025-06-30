import 'package:flutter/material.dart';

class SpellItGameScreen extends StatefulWidget {
  const SpellItGameScreen({super.key});

  @override
  _SpellItGameScreenState createState() => _SpellItGameScreenState();
}

class _SpellItGameScreenState extends State<SpellItGameScreen> {
  final Map<String, List<String>> _words = {
    "Easy": [
      "CAT",
      "DOG",
      "SUN",
      "BUS",
      "RUN",
      "LOG",
      "POT",
      "ELK",
      "BAT",
      "HAT",
      "MAP",
      "RAT",
      "FOX",
      "CUP",
      "JAM",
      "NET",
      "PIN",
      "TOP",
      "CAR",
      "BAG",
      "BED",
      "RED",
      "HEN",
      "FIG"
    ],
    "Medium": [
      "FISH",
      "TREE",
      "BIRD",
      "SAND",
      "BOOK",
      "FROG",
      "COIN",
      "FIRE",
      "LION",
      "DUCK",
      "COLD",
      "WARM",
      "WIND",
      "RAIN",
      "LEAF",
      "SHIP",
      "BEAR",
      "STAR",
      "JUMP",
      "PLAY",
      "GOAT",
      "BALL",
      "MILK",
      "FACE"
    ],
    "Hard": [
      "MOUSE",
      "ORANGE",
      "CANDY",
      "APPLE",
      "HEART",
      "HAPPY",
      "RIGHT",
      "TABLE",
      "SUGAR",
      "BRUSH",
      "CLOUD",
      "PLANE",
      "SHEEP",
      "GRAPE",
      "TIGER",
      "ZEBRA",
      "WATER",
      "HOUSE",
      "GREEN",
      "LIGHT",
      "SNAKE",
      "CHAIR",
      "BREAD",
      "SCOOT"
    ]
  };

  late String _currentWord;
  late List<String> _shuffledLetters;
  List<String> _userInput = [];
  int _score = 0;
  int _round = 0;
  final List<String> _incorrectWords = [];
  final List<String> _usedWords = [];
  String _selectedDifficulty = "Easy";
  Set<int> _usedLetterIndices = {};

  @override
  void initState() {
    super.initState();
    _generateNewWord();
  }

  void _generateNewWord() {
    if (_round >= 5) {
      _showFinalScore();
      return;
    }

    final words = [..._words[_selectedDifficulty]!]; // Clone list
    words.shuffle();
    final newWord = words.first;

    setState(() {
      _currentWord = newWord;
      _shuffledLetters = [..._currentWord.split('')]..shuffle();
      _userInput = List.filled(_currentWord.length, "");
      _usedLetterIndices.clear();
      _round++;
    });
  }

  void _checkAnswer() {
    if (!_userInput.contains("")) {
      if (_userInput.join() == _currentWord) {
        _showMessage("Great Job!", Colors.green);
        _score++;
      } else {
        _showMessage("Try Again!", Colors.red);
        _incorrectWords.add(_currentWord);
      }
      Future.delayed(const Duration(seconds: 1), _generateNewWord);
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Game Over!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your Final Score: $_score/5"),
            if (_incorrectWords.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Practice These Words:"),
                  ..._incorrectWords.map((word) => Text("• $word")),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _round = 0;
                _incorrectWords.clear();
                _usedWords.clear();
              });
              Navigator.of(context).pop();
              _generateNewWord();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bool canCheck = !_userInput.contains("");

    return Scaffold(
      appBar: AppBar(
        title: const Text('KiddoLearn - Spell It'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedDifficulty,
            dropdownColor: Colors.deepPurple.shade200,
            iconEnabledColor: Colors.white,
            underline: const SizedBox(),
            items: ["Easy", "Medium", "Hard"].map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value!;
                _score = 0;
                _round = 0;
                _incorrectWords.clear();
                _usedLetterIndices.clear();
                _generateNewWord();
              });
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text("Round: $_round / 5",
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: List.generate(_currentWord.length, (index) {
                return DragTarget<Map<String, dynamic>>(
                  onAcceptWithDetails: (details) {
                    final letter = details.data['letter'];
                    final indexInList = details.data['index'];
                    setState(() {
                      _userInput[index] = letter;
                      _usedLetterIndices.add(indexInList);
                    });
                    _checkAnswer();
                  },
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _userInput[index] == ""
                            ? Colors.white.withOpacity(0.6)
                            : Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        _userInput[index],
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: List.generate(_shuffledLetters.length, (i) {
                final letter = _shuffledLetters[i];
                final isUsed = _usedLetterIndices.contains(i);
                return Draggable<Map<String, dynamic>>(
                  data: {'letter': letter, 'index': i},
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(letter,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white)),
                    ),
                  ),
                  childWhenDragging: const SizedBox(width: 60, height: 60),
                  maxSimultaneousDrags: isUsed ? 0 : 1,
                  child: isUsed
                      ? const SizedBox(width: 60, height: 60)
                      : Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(letter,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white)),
                        ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (!canCheck)
              ElevatedButton(
                onPressed: _generateNewWord,
                child: const Text("New Word"),
              ),
          ],
        ),
      ),
    );
  }
}
