// _localService.completedFile(userId, xp);

import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
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
  late LocalService _localService;
  late List<Map<String, dynamic>> _words;
  late List<bool> _knewWord;
  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  late Animation<double> _frontOpacity;
  late Animation<double> _backOpacity;

  String get userId => AuthService.firebase().currentUser!.id;

  int _currentIndex = 0;
  bool _showTranslation = false;
  bool _hasCompletedSet = false;

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    _initializeWords();
    _setupAnimations();
  }

  void _initializeWords() {
    try {
      final List<Map<String, dynamic>> parsedWords = widget.file.content
          .split('\n')
          .where((line) => line.trim().isNotEmpty && line.contains('|'))
          .map((line) {
        final parts = line.split('|');
        return {
          'word': parts[0].trim(),
          'translation': parts[1].trim(),
        };
      }).toList();

      if (parsedWords.isEmpty) {
        throw Exception('No valid words found in the file');
      }

      _words = parsedWords;
      _knewWord = List<bool>.filled(_words.length, false);
    } catch (e) {
      // We'll handle this in build() method
      _words = [];
      _knewWord = [];
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _frontRotation = Tween<double>(begin: 0, end: math.pi / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _backRotation = Tween<double>(begin: -math.pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _frontOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _backOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
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
      if (_showTranslation) {
        _flipCard();
      }
      if (_currentIndex < _words.length - 1) {
        _currentIndex++;
      } else {
        _showResultsDialog();
      }
    });
  }

  Future<void> _flipCard() async {
    if (_controller.status == AnimationStatus.dismissed) {
      await _controller.forward();
    } else if (_controller.status == AnimationStatus.completed) {
      await _controller.reverse();
    }
    if (mounted) {
      setState(() {
        _showTranslation = !_showTranslation;
      });
    }
  }

  void _restartLearning({bool onlyUnknown = false}) {
    setState(() {
      if (onlyUnknown) {
        final unknownWords = _words
            .asMap()
            .entries
            .where((entry) => !_knewWord[entry.key])
            .map((entry) => entry.value)
            .toList();

        if (unknownWords.isEmpty) {
          Navigator.pop(context);
          if (!_hasCompletedSet) {
            _handleCompletion();
          } else {
            _showAlreadyCompletedDialog();
          }
          return;
        }

        _words = unknownWords;
        _knewWord = List<bool>.filled(_words.length, false);
      } else {
        _knewWord = List<bool>.filled(_words.length, false);
      }
      _currentIndex = 0;
      _showTranslation = false;
    });
    Navigator.pop(context);
  }

  void _handleCompletion() {
    setState(() {
      _hasCompletedSet = true;
    });

    final int xpEarned = _words.length;
    _localService.completedFile(userId, xpEarned);

    _showCompletionDialog(xpEarned);
  }

  void _showAlreadyCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              "Al voltooid",
              style:
                  AppTheme.getOrbitronStyle(size: 24, weight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "Je hebt deze woordenset al voltooid! Je kunt de woorden nog wel oefenen, maar je verdient er geen extra XP meer mee.",
          style: AppTheme.getOrbitronStyle(size: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Sluit de dialog
              Navigator.pop(context); // Gaat terug naar het overzicht
            },
            child: const Text("Terug naar overzicht"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartLearning();
            },
            child: const Text("Toch oefenen"),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(int xpEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              "Set voltooid! 🎉",
              style:
                  AppTheme.getOrbitronStyle(size: 24, weight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "+$xpEarned XP",
                    style: AppTheme.getOrbitronStyle(
                      size: 24,
                      weight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Geweldig! Je hebt alle ${_words.length} woorden geleerd!",
              style: AppTheme.getOrbitronStyle(size: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Terug naar overzicht"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartLearning();
            },
            child: const Text("Opnieuw oefenen"),
          ),
        ],
      ),
    );
  }

  void _showResultsDialog() {
    final knownCount = _knewWord.where((knew) => knew).length;
    final percentage = (knownCount / _words.length * 100).round();
    final allWordsLearned = knownCount == _words.length;

    if (allWordsLearned && !_hasCompletedSet) {
      _handleCompletion();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        title: Column(
          children: [
            Icon(
              percentage >= 80 ? Icons.emoji_events : Icons.bar_chart,
              size: 48,
              color: percentage >= 80 ? Colors.amber : Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              "Resultaat",
              style:
                  AppTheme.getOrbitronStyle(size: 24, weight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$percentage% correct",
              style: AppTheme.getOrbitronStyle(
                size: 32,
                weight: FontWeight.bold,
                color: percentage >= 80 ? Colors.green : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Je kende $knownCount van de ${_words.length} woorden.",
              style: AppTheme.getOrbitronStyle(size: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _restartLearning(),
            child: const Text("Alles opnieuw"),
          ),
          ElevatedButton(
            onPressed: () => _restartLearning(onlyUnknown: true),
            child: const Text("Oefen onbekende woorden"),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      String text, Animation<double> rotation, Animation<double> opacity) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation.value),
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity.value,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppTheme.tertiaryBlue.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.secondaryBlue.withOpacity(0.9),
                      AppTheme.secondaryBlue.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: AppTheme.getOrbitronStyle(
                        size: 28,
                        weight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tik om om te draaien',
                      style: AppTheme.getOrbitronStyle(
                        size: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _words.length,
            backgroundColor: AppTheme.tertiaryBlue.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tertiaryBlue),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text(
            'Woord ${_currentIndex + 1} van ${_words.length}',
            style: AppTheme.getOrbitronStyle(size: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              onPressed: () => _nextWord(false),
              text: "Ken ik niet",
              icon: Icons.close,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionButton(
              onPressed: () => _nextWord(true),
              text: "Ken ik wel",
              icon: Icons.check,
              color: Colors.green.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.file.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  "Geen geldige woorden gevonden",
                  style: AppTheme.getOrbitronStyle(
                      size: 24, weight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Controleer of het bestand het juiste formaat heeft (woord|vertaling).",
                  style: AppTheme.getOrbitronStyle(size: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final word = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildCard(
                        word['word'],
                        _frontRotation,
                        _frontOpacity,
                      ),
                      _buildCard(
                        word['translation'],
                        _backRotation,
                        _backOpacity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTheme.getOrbitronStyle(
                    size: 16,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
