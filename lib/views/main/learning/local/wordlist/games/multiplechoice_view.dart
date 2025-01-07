import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';

class MultipleChoiceView extends StatefulWidget {
  final File file;

  const MultipleChoiceView({super.key, required this.file});

  @override
  State<MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<MultipleChoiceView> {
  late LocalService _localService;
  late List<Map<String, dynamic>> _words;
  late List<bool> _answeredCorrectly;
  int _currentIndex = 0;
  late List<String> _currentOptions;
  bool _hasAnswered = false;
  bool _hasCompletedSet = false;
  int? _selectedOptionIndex;

  // Constants
  static const int _numOptions = 4;
  static const Duration _answerDelay = Duration(milliseconds: 1000);

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    _initializeWords();
    _generateOptions();
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

      if (parsedWords.length < _numOptions) {
        throw Exception(
            'Niet genoeg woorden voor multiple choice (minimaal $_numOptions nodig)');
      }

      _words = parsedWords;
      _answeredCorrectly = List<bool>.filled(_words.length, false);
    } catch (e) {
      _words = [];
      _answeredCorrectly = [];
    }
  }

  void _generateOptions() {
    if (_words.isEmpty) return;

    // Correct answer is always included
    final correctAnswer = _words[_currentIndex]['translation'];

    // Get all possible translations except the current word
    final possibleOptions = _words
        .where((word) => word['translation'] != correctAnswer)
        .map((word) => word['translation'])
        .toList();

    // Shuffle and take first (_numOptions - 1) items
    possibleOptions.shuffle();
    final wrongOptions = possibleOptions.take(_numOptions - 1).toList();

    // Combine correct answer with wrong options and shuffle
    _currentOptions = [...wrongOptions, correctAnswer];
    _currentOptions.shuffle();
  }

  void _handleAnswer(int optionIndex) {
    if (_hasAnswered) return;

    final isCorrect =
        _currentOptions[optionIndex] == _words[_currentIndex]['translation'];

    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = optionIndex;
      _answeredCorrectly[_currentIndex] = isCorrect;
    });

    Future.delayed(_answerDelay, () {
      if (!mounted) return;

      setState(() {
        if (_currentIndex < _words.length - 1) {
          _currentIndex++;
          _generateOptions();
          _hasAnswered = false;
          _selectedOptionIndex = null;
        } else {
          _showResultsDialog();
        }
      });
    });
  }

  void _handleCompletion() {
    setState(() {
      _hasCompletedSet = true;
    });

    final int xpEarned = _answeredCorrectly.where((correct) => correct).length;
    _localService.completedFile(userId, xpEarned);

    _showCompletionDialog(xpEarned);
  }

  void _restartLearning({bool onlyIncorrect = false}) {
    setState(() {
      if (onlyIncorrect) {
        final incorrectWords = _words
            .asMap()
            .entries
            .where((entry) => !_answeredCorrectly[entry.key])
            .map((entry) => entry.value)
            .toList();

        if (incorrectWords.isEmpty) {
          Navigator.pop(context);
          if (!_hasCompletedSet) {
            _handleCompletion();
          } else {
            _showAlreadyCompletedDialog();
          }
          return;
        }

        _words = incorrectWords;
        _answeredCorrectly = List<bool>.filled(_words.length, false);
      } else {
        _answeredCorrectly = List<bool>.filled(_words.length, false);
      }

      _currentIndex = 0;
      _hasAnswered = false;
      _selectedOptionIndex = null;
      _generateOptions();
    });
    Navigator.pop(context);
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
              "Geweldig! Je hebt $xpEarned van de ${_words.length} woorden goed!",
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
    final correctCount = _answeredCorrectly.where((correct) => correct).length;
    final percentage = (correctCount / _words.length * 100).round();
    final allWordsLearned = correctCount == _words.length;

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
              "Je had $correctCount van de ${_words.length} woorden goed.",
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
            onPressed: () => _restartLearning(onlyIncorrect: true),
            child: const Text("Oefen foute woorden"),
          ),
        ],
      ),
    );
  }

  // Rest of the widgets and build method remain the same...

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

  Color _getOptionBackgroundColor(int index) {
    if (!_hasAnswered) {
      return AppTheme.tertiaryBlue.withOpacity(0.1);
    }

    final isCorrectAnswer =
        _currentOptions[index] == _words[_currentIndex]['translation'];

    if (index == _selectedOptionIndex) {
      return isCorrectAnswer
          ? Colors.green.withOpacity(0.3)
          : Colors.red.withOpacity(0.3);
    }

    if (isCorrectAnswer) {
      return Colors.green.withOpacity(0.3);
    }

    return AppTheme.tertiaryBlue.withOpacity(0.1);
  }

  Widget _buildOptionButton(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasAnswered &&
                    _currentOptions[index] ==
                        _words[_currentIndex]['translation']
                ? Colors.green
                : AppTheme.tertiaryBlue.withOpacity(0.2),
            width: 2,
          ),
          color: _getOptionBackgroundColor(index),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _hasAnswered ? null : () => _handleAnswer(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentOptions[index],
                      style: AppTheme.getOrbitronStyle(
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_hasAnswered)
                    Icon(
                      _currentOptions[index] ==
                              _words[_currentIndex]['translation']
                          ? Icons.check_circle
                          : (_selectedOptionIndex == index
                              ? Icons.cancel
                              : null),
                      color: _currentOptions[index] ==
                              _words[_currentIndex]['translation']
                          ? Colors.green
                          : Colors.red,
                    ),
                ],
              ),
            ),
          ),
        ),
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
                  "Er zijn minimaal $_numOptions woorden nodig voor multiple choice vragen.",
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.tertiaryBlue.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Text(
                _words[_currentIndex]['word'],
                style: AppTheme.getOrbitronStyle(
                  size: 28,
                  weight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kies de juiste vertaling:',
              style: AppTheme.getOrbitronStyle(
                size: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _currentOptions.length,
                itemBuilder: (context, index) => _buildOptionButton(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
