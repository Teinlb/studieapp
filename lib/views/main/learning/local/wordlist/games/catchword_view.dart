import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'dart:async';
import 'dart:math';

class CatchTheWordView extends StatefulWidget {
  final File file;

  const CatchTheWordView({super.key, required this.file});

  @override
  State<CatchTheWordView> createState() => _CatchTheWordViewState();
}

class _CatchTheWordViewState extends State<CatchTheWordView> {
  late LocalService _localService;
  late List<Map<String, dynamic>> _words;
  late TextEditingController _inputController;
  final int _maxLives = 3;
  int _currentLives = 3;
  int _score = 0;
  bool _gameActive = false;
  bool _hasCompletedSet = false;
  double _wordPosition = 0;
  String _currentWord = '';
  String _currentTranslation = '';
  Timer? _gameTimer;
  final _formKey = GlobalKey<FormState>();

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    _inputController = TextEditingController();
    _initializeWords();
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
        throw Exception('Geen woorden gevonden in het bestand');
      }

      _words = parsedWords;
      _words.shuffle();
    } catch (e) {
      _words = [];
    }
  }

  void _startGame() {
    if (_words.isEmpty) return;

    setState(() {
      _gameActive = true;
      _currentLives = _maxLives;
      _score = 0;
      _wordPosition = 0;
      _nextWord();
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        _wordPosition += 0.002; // Snelheid van vallende woorden
        if (_wordPosition >= 1) {
          _missedWord();
        }
      });
    });
  }

  void _nextWord() {
    if (_words.isEmpty) return;

    setState(() {
      final wordData = _words[Random().nextInt(_words.length)];
      _currentWord = wordData['word'];
      _currentTranslation = wordData['translation'];
      _wordPosition = 0;
      _inputController.clear();
    });
  }

  void _checkAnswer(String input) {
    if (input.trim().toLowerCase() == _currentTranslation.toLowerCase()) {
      setState(() {
        _score++;
        _showSuccessAnimation();
      });
    }
  }

  void _showSuccessAnimation() {
    // Animatie logica hier
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _nextWord();
      }
    });
  }

  void _missedWord() {
    setState(() {
      _currentLives--;
      if (_currentLives <= 0) {
        _endGame();
      } else {
        _nextWord();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() {
      _gameActive = false;
    });

    if (!_hasCompletedSet && _score >= _words.length ~/ 2) {
      _handleCompletion();
    } else {
      _showGameOverDialog();
    }
  }

  void _handleCompletion() {
    setState(() {
      _hasCompletedSet = true;
    });

    final int xpEarned = _score;
    _localService.completedFile(userId, xpEarned);
    _showCompletionDialog(xpEarned);
  }

  void _showGameOverDialog() {
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
              _score >= _words.length ~/ 2
                  ? Icons.emoji_events
                  : Icons.sports_score,
              size: 48,
              color: _score >= _words.length ~/ 2 ? Colors.amber : Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              "Game Over!",
              style:
                  AppTheme.getOrbitronStyle(size: 24, weight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Score: $_score",
              style: AppTheme.getOrbitronStyle(
                size: 32,
                weight: FontWeight.bold,
                color:
                    _score >= _words.length ~/ 2 ? Colors.green : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Je hebt $_score woorden goed vertaald!",
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
              _startGame();
            },
            child: const Text("Opnieuw proberen"),
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
              "Geweldig! Je hebt $xpEarned woorden goed vertaald!",
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
              _startGame();
            },
            child: const Text("Nog een ronde"),
          ),
        ],
      ),
    );
  }

  Widget _buildLivesIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_maxLives, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.favorite,
            color: index < _currentLives ? Colors.red : Colors.grey,
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildLivesIndicator(),
        const SizedBox(height: 16),
        Text(
          'Score: $_score',
          style: AppTheme.getOrbitronStyle(size: 24, weight: FontWeight.bold),
        ),
        Expanded(
          child: Stack(
            children: [
              if (_gameActive)
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height * _wordPosition * 0.7,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _wordPosition >= 1 ? 0 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBlue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.tertiaryBlue.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.tertiaryBlue.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentWord,
                        style: AppTheme.getOrbitronStyle(
                          size: 28,
                          weight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: TextFormField(
              controller: _inputController,
              enabled: _gameActive,
              autofocus: true,
              textAlign: TextAlign.center,
              style: AppTheme.getOrbitronStyle(size: 18),
              decoration: InputDecoration(
                hintText: 'Type de vertaling...',
                filled: true,
                fillColor: AppTheme.tertiaryBlue.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.tertiaryBlue.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.tertiaryBlue.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.tertiaryBlue,
                  ),
                ),
              ),
              onChanged: _checkAnswer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.keyboard,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            'Catch the Word',
            style: AppTheme.getOrbitronStyle(
              size: 32,
              weight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Type de juiste vertaling voordat het woord de bodem raakt!',
              style: AppTheme.getOrbitronStyle(size: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Game'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _inputController.dispose();
    super.dispose();
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
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  "Geen woorden gevonden",
                  style: AppTheme.getOrbitronStyle(
                    size: 24,
                    weight: FontWeight.bold,
                  ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.title),
      ),
      body: SafeArea(
        child: _gameActive ? _buildGameScreen() : _buildStartScreen(),
      ),
    );
  }
}
