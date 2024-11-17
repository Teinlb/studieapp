import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';

class WordPair {
  String word;
  String translation;

  WordPair({required this.word, required this.translation});

  static List<WordPair> fromFileContent(String content) {
    if (content.isEmpty) return [];
    return content.split('\n').map((line) {
      final parts = line.split('|');
      return WordPair(
        word: parts[0],
        translation: parts[1],
      );
    }).toList();
  }

  static String toFileContent(List<WordPair> words) {
    return words.map((pair) => '${pair.word}|${pair.translation}').join('\n');
  }
}

class WordListView extends StatefulWidget {
  final File file;
  final Function(File updatedFile)? onFileUpdate;

  const WordListView({
    super.key,
    required this.file,
    this.onFileUpdate,
  });

  @override
  State<WordListView> createState() => _WordListViewState();
}

class _WordListViewState extends State<WordListView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  late List<WordPair> _words;
  late List<WordPair> _filteredWords;
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _words = WordPair.fromFileContent(widget.file.content);
    _filteredWords = List.from(_words);
  }

  void _updateFile() {
    if (widget.onFileUpdate != null) {
      final updatedFile = widget.file.copyWith(
        content: WordPair.toFileContent(_words),
        lastOpened: DateTime.now(),
      );
      widget.onFileUpdate!(updatedFile);
    }
  }

  void _filterWords(String query) {
    setState(() {
      _filteredWords = _words
          .where((pair) =>
              pair.word.toLowerCase().contains(query.toLowerCase()) ||
              pair.translation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _startEditing(int index) {
    final word = index < _filteredWords.length
        ? _filteredWords[index]
        : WordPair(word: '', translation: '');
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _wordController.text = word.word;
      _translationController.text = word.translation;
    });
  }

  void _saveEdit() {
    if (_wordController.text.isNotEmpty &&
        _translationController.text.isNotEmpty) {
      setState(() {
        final newPair = WordPair(
          word: _wordController.text,
          translation: _translationController.text,
        );

        if (_editingIndex != null && _editingIndex! < _filteredWords.length) {
          // Edit existing word
          final originalIndex = _words.indexOf(_filteredWords[_editingIndex!]);
          _words[originalIndex] = newPair;
        } else {
          // Add new word
          _words.add(newPair);
        }

        _updateFile();
        _filterWords(_searchController.text); // Refresh filtered list
        _isEditing = false;
        _editingIndex = null;
        _wordController.clear();
        _translationController.clear();
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingIndex = null;
      _wordController.clear();
      _translationController.clear();
    });
  }

  void _deleteWord(int index) {
    setState(() {
      final originalWord = _filteredWords[index];
      _words.remove(originalWord);
      _filteredWords.removeAt(index);
      _updateFile();
    });
  }

  Widget _buildGameButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(widget.file.title, style: textTheme.displayMedium),
        backgroundColor: AppTheme.secondaryBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Details Card
          Card(
            color: AppTheme.secondaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vak: ${widget.file.subject}',
                    style: textTheme.displayMedium,
                  ),
                  if (widget.file.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.file.description,
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Game Buttons
          Row(
            children: [
              _buildGameButton(
                'Flashcards',
                Icons.flip,
                AppTheme.accentOrange,
                () {/* TODO: Navigate to Flashcards */},
              ),
              _buildGameButton(
                'Multiple\nChoice',
                Icons.quiz,
                const Color(0xFF4CAF50),
                () {/* TODO: Navigate to Multiple Choice */},
              ),
            ],
          ),
          Row(
            children: [
              _buildGameButton(
                'Word\nLink',
                Icons.link,
                const Color(0xFF2196F3),
                () {/* TODO: Navigate to Word Link */},
              ),
              _buildGameButton(
                'Catch the\nWord',
                Icons.catching_pokemon,
                const Color(0xFFE91E63),
                () {/* TODO: Navigate to Catch the Word */},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            style: textTheme.bodyLarge,
            onChanged: _filterWords,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.secondaryBlue,
              hintText: 'Zoek woorden...',
              hintStyle: textTheme.bodyMedium,
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.accentOrange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Words List
          Card(
            color: AppTheme.secondaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Woorden', style: textTheme.displayMedium),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: AppTheme.accentOrange),
                        onPressed: () {
                          _startEditing(_filteredWords.length);
                        },
                      ),
                    ],
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _wordController,
                            style: textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Woord',
                              labelStyle: textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _translationController,
                            style: textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Vertaling',
                              labelStyle: textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          onPressed: _saveEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.red),
                          onPressed: _cancelEdit,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredWords.length,
                    itemBuilder: (context, index) {
                      final pair = _filteredWords[index];
                      return ListTile(
                        title: Text(pair.word, style: textTheme.bodyLarge),
                        subtitle: Text(
                          pair.translation,
                          style: textTheme.bodyMedium,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppTheme.accentOrange),
                              onPressed: () => _startEditing(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteWord(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }
}
