import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'dart:math' as math;

class FlashcardsView extends StatefulWidget {
  final File file;

  const FlashcardsView({super.key, required this.file});

  @override
  State<FlashcardsView> createState() => _FlashcardsViewState();
}

class _FlashcardsViewState extends State<FlashcardsView>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> _words;
  late List<bool> _knewWord;
  late AnimationController _controller;
  late Animation<double> _animation;
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

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _flipCard() {
    if (_animation.status == AnimationStatus.dismissed) {
      _controller.forward().then((_) {
        setState(() {
          _showTranslation = !_showTranslation;
        });
        _controller.reset();
      });
    }
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
            child: const Text("Alles opnieuw leren"),
          ),
          TextButton(
            onPressed: () => _restartLearning(onlyUnknown: true),
            child: const Text("Alleen onbekende woorden leren"),
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
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_animation.value * math.pi),
                      alignment: Alignment.center,
                      child: Card(
                        elevation: 10,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            _showTranslation
                                ? word['translation']
                                : word['word'],
                            style: AppTheme.getOrbitronStyle(size: 24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryBlue.withAlpha(220),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 123, 0),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _nextWord(false),
                        child: const Text("Ken ik nog niet"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryBlue.withAlpha(220),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 255, 123, 0),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _nextWord(true),
                        child: const Text("Ken ik al"),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
