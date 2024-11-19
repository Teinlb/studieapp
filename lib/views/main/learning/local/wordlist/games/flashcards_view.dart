import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';

class FlashcardsView extends StatefulWidget {
  final File file;

  const FlashcardsView({Key? key, required this.file}) : super(key: key);

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView> {
  late List<Map<String, dynamic>> _words;
  late List<bool> _knewWord;
  int _currentIndex = 0;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _words = widget.file.content.split('\n').map((line) {
      final parts = line.split('|');
      return {'word': parts[0], 'translation': parts[1]};
    }).toList();
    _knewWord = List<bool>.filled(_words.length, false);
  }

  void _nextWord(bool knew) {
    setState(() {
      _knewWord[_currentIndex] = knew;
      _showTranslation = false;
      if (_currentIndex < _words.length - 1) {
        _currentIndex++;
      } else {
        _showResultsDialog();
      }
    });
  }

  void _restartLearning({bool onlyUnknown = false}) {
    setState(() {
      if (onlyUnknown) {
        _words = _words
            .asMap()
            .entries
            .where((entry) => !_knewWord[entry.key])
            .map((entry) => entry.value)
            .toList();
        _knewWord = List<bool>.filled(_words.length, false);
      }
      _currentIndex = 0;
      _showTranslation = false;
    });
    Navigator.pop(context);
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        title: Text(
          "Resultaten",
          style: AppTheme.getOrbitronStyle(size: 20, weight: FontWeight.bold),
        ),
        content: Text(
          "Je kende ${_knewWord.where((knew) => knew).length} van de ${_words.length} woorden.",
          style: AppTheme.getOrbitronStyle(size: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => _restartLearning(),
            child: Text("Alles opnieuw leren"),
          ),
          TextButton(
            onPressed: () => _restartLearning(onlyUnknown: true),
            child: Text("Alleen onbekende woorden leren"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.center,
                    child: Text(
                      _showTranslation ? word['translation'] : word['word'],
                      style: AppTheme.getOrbitronStyle(size: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _nextWord(false),
                    child: const Text("Niet gekend"),
                  ),
                  ElevatedButton(
                    onPressed: () => _nextWord(true),
                    child: const Text("Gekend"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
