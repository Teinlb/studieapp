import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/utilities/dialogs/publish_dialog.dart';
import 'package:studieapp/views/main/learning/local/wordlist/games/flashcards_view.dart';

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

  const WordListView({
    super.key,
    required this.file,
  });

  @override
  State<WordListView> createState() => _WordListViewState();
}

class _WordListViewState extends State<WordListView> {
  late final LocalService _localService;
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
    final updatedFile = widget.file.copyWith(
      lastOpened: DateTime.now(),
    );
    _localService = LocalService();
    _localService.updateFile(id: updatedFile.id, content: updatedFile.content);
  }

  void _updateFile() {
    final updatedFile = widget.file.copyWith(
      content: WordPair.toFileContent(_words),
      lastOpened: DateTime.now(),
    );
    _localService.updateFile(id: updatedFile.id, content: updatedFile.content);
  }

  void _deleteFile() async {
    final shouldDelete = await showDeleteDialog(context);
    if (shouldDelete) {
      _localService.deleteFile(id: widget.file.id);

      // Navigeer terug naar het vorige scherm
      Navigator.of(context).pop();
    }
  }

  void _publishFile() async {
    final publishDetails = await showPublishDialog(context);
    if (publishDetails != null) {
      // TODO: Implementeer publicatie logica
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publiceren: ${publishDetails['title']}' +
                (publishDetails['description']!.isNotEmpty
                    ? ' - ${publishDetails['description']}'
                    : ''),
          ),
        ),
      );
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
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      if (index < _filteredWords.length) {
        _wordController.text = _filteredWords[index].word;
        _translationController.text = _filteredWords[index].translation;
      } else {
        _wordController.clear();
        _translationController.clear();
      }
    });
  }

  void _saveEdit() {
    if (_wordController.text.isNotEmpty &&
        _translationController.text.isNotEmpty) {
      setState(() {
        final newPair = WordPair(
          word: _wordController.text.trim(),
          translation: _translationController.text.trim(),
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

  Widget _buildGameButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1, // Make buttons square
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.tertiaryBlue.withAlpha(
                220), // Gebruik withAlpha in plaats van niet-bestaande methode
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 0, 0, 0),
                offset: Offset(0, 8),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Schyler',
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
        title: Text('Woordenlijst', style: textTheme.displayMedium),
        backgroundColor: AppTheme.secondaryBlue,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String choice) {
              switch (choice) {
                case 'publish':
                  _publishFile();
                  break;
                case 'delete':
                  _deleteFile();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'publish',
                child: ListTile(
                  leading: Icon(Icons.public),
                  title: Text('Publiceren'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title:
                      Text('Verwijderen', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Details Card
          Card(
            color: AppTheme.secondaryBlue,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.file.title,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.file.subject,
                    style: textTheme.bodyLarge,
                  ),
                  if (widget.file.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.file.description,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Game Buttons (Redesigned Grid)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1, // Make buttons square
            children: [
              _buildGameButton(
                title: 'Flashcards',
                icon: Icons.menu_book_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardsView(file: widget.file),
                    ),
                  );
                },
              ),
              _buildGameButton(
                title: 'Multiple Choice',
                icon: Icons.check_box_outlined,
                onPressed: () {/* TODO: Navigate to Multiple Choice */},
              ),
              _buildGameButton(
                title: 'Word Link',
                icon: Icons.link_rounded,
                onPressed: () {/* TODO: Navigate to Word Link */},
              ),
              _buildGameButton(
                title: 'Catch the Word',
                icon: Icons.sports_esports_rounded,
                onPressed: () {/* TODO: Navigate to Catch the Word */},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar

          Padding(
            padding: const EdgeInsets.all(4),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWords,
              decoration: InputDecoration(
                hintText: 'Zoek woorden...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterWords('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Words List with Editing Functionality
          Card(
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
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _startEditing(_filteredWords.length),
                      ),
                    ],
                  ),

                  // Editing Row
                  if (_isEditing)
                    Card(
                      color: AppTheme.secondaryBlue.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _wordController,
                                decoration: const InputDecoration(
                                  hintText: 'Woord',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _translationController,
                                decoration: const InputDecoration(
                                  hintText: 'Vertaling',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: _saveEdit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: _cancelEdit,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Word List
                  _filteredWords.isEmpty
                      ? Center(
                          child: Text(
                            'Geen woorden gevonden',
                            style: textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredWords.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final pair = _filteredWords[index];
                            return ListTile(
                              title: Text(pair.word),
                              subtitle: Text(pair.translation),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.orange),
                                    onPressed: () => _startEditing(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
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
