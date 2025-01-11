// wordlink_view.dart
import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';

class WordLinkView extends StatefulWidget {
  final File file;

  const WordLinkView({super.key, required this.file});

  @override
  State<WordLinkView> createState() => _WordLinkViewState();
}

class _WordLinkViewState extends State<WordLinkView> {
  late LocalService _localService;
  late List<Map<String, dynamic>> _words;
  late List<bool> _matchedPairs;
  late List<int> _selectedIndices;
  int _score = 0;
  bool _hasCompletedSet = false;
  final int _wordsPerRound = 8;
  late Stopwatch _stopwatch;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    _selectedIndices = [];
    _stopwatch = Stopwatch()..start();
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

      if (parsedWords.length < _wordsPerRound) {
        throw Exception(
            'Niet genoeg woorden voor WordLink (minimaal $_wordsPerRound nodig)');
      }

      // Neem eerste 8 woorden voor deze ronde
      _words = parsedWords.take(_wordsPerRound).toList();
      _matchedPairs = List<bool>.filled(_words.length, false);
    } catch (e) {
      _words = [];
      _matchedPairs = [];
    }
  }

  void _handleTileTap(int index, bool isWord) {
    if (_matchedPairs[index % _words.length]) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
        if (_selectedIndices.length == 2) {
          _checkMatch();
        }
      }
    });
  }

  void _checkMatch() {
    final firstIndex = _selectedIndices[0];
    final secondIndex = _selectedIndices[1];
    final isFirstWord = firstIndex < _words.length;
    final isSecondWord = secondIndex < _words.length;

    if (isFirstWord == isSecondWord) {
      // Reset als twee woorden of twee vertalingen zijn geselecteerd
      _selectedIndices.clear();
      return;
    }

    final wordIndex = isFirstWord ? firstIndex : secondIndex;
    final translationIndex =
        isFirstWord ? secondIndex - _words.length : firstIndex - _words.length;

    if (wordIndex == translationIndex) {
      // Correcte match!
      setState(() {
        _matchedPairs[wordIndex] = true;
        _score++;
        _selectedIndices.clear();
      });

      if (_score == _words.length) {
        _stopwatch.stop();
        if (!_hasCompletedSet) {
          _handleCompletion();
        } else {
          _showAlreadyCompletedDialog();
        }
      }
    } else {
      // Incorrecte match
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _selectedIndices.clear();
          });
        }
      });
    }
  }

  void _handleCompletion() {
    setState(() {
      _hasCompletedSet = true;
    });

    // XP berekening gebaseerd op tijd en aantal woorden
    final timeInSeconds = _stopwatch.elapsed.inSeconds;
    final baseXP = _words.length;
    final timeBonus =
        (60 - timeInSeconds).clamp(0, 30); // Max 30 bonus punten voor snelheid
    final totalXP = baseXP + timeBonus;

    _localService.completedFile(userId, totalXP);
    _showCompletionDialog(totalXP, timeInSeconds);
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
          "Je hebt deze woordenset al voltooid! Je kunt de woorden nog wel matchen, maar je verdient er geen extra XP meer mee.",
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
              _initializeWords();
            },
            child: const Text("Toch spelen"),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(int xpEarned, int timeInSeconds) {
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
              "Perfect! 🎉",
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
              "Je hebt alle ${_words.length} woorden gematcht in $timeInSeconds seconden!",
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
              _initializeWords();
            },
            child: const Text("Nog een ronde"),
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
                  "Niet genoeg woorden gevonden",
                  style: AppTheme.getOrbitronStyle(
                      size: 24, weight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Er zijn minimaal $_wordsPerRound woorden nodig voor WordLink.",
                  style: AppTheme.getOrbitronStyle(size: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Maak een lijst van alle tiles (woorden en vertalingen)
    final List<Widget> wordTiles = _words.asMap().entries.map((entry) {
      return _buildTile(entry.key, entry.value['word'], true);
    }).toList();

    final List<Widget> translationTiles = _words.asMap().entries.map((entry) {
      return _buildTile(
          entry.key + _words.length, entry.value['translation'], false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Koppel de juiste woorden',
                    style: AppTheme.getOrbitronStyle(size: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tijd: ${(_stopwatch.elapsed.inSeconds)} seconden',
                    style: AppTheme.getOrbitronStyle(
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [...wordTiles, ...translationTiles]..shuffle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int index, String text, bool isWord) {
    final isSelected = _selectedIndices.contains(index);
    final isMatched = _matchedPairs[index % _words.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.green.withOpacity(0.3)
            : isSelected
                ? AppTheme.tertiaryBlue.withOpacity(0.3)
                : AppTheme.secondaryBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched
              ? Colors.green
              : isSelected
                  ? AppTheme.tertiaryBlue
                  : AppTheme.tertiaryBlue.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTileTap(index, isWord),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: AppTheme.getOrbitronStyle(
                  size: 16,
                  weight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
