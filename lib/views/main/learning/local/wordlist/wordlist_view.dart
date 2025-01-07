import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/cloud/firebase_cloud_storage.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/utilities/dialogs/publish_dialog.dart';
import 'package:studieapp/views/main/learning/local/wordlist/games/flashcards_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studieapp/views/main/learning/local/wordlist/games/multiplechoice_view.dart';
// import 'dart:developer' as devtools show log;

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
  late final FirebaseCloudStorage _cloudService;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  late List<WordPair> _words;
  late List<WordPair> _filteredWords;
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void initState() {
    _words = WordPair.fromFileContent(widget.file.content);
    _filteredWords = List.from(_words);
    final updatedFile = widget.file.copyWith(
      lastOpened: DateTime.now(),
    );
    _localService = LocalService();
    _localService.updateFile(id: updatedFile.id, content: updatedFile.content);
    _cloudService = FirebaseCloudStorage();
    super.initState();
  }

  void _updateFile() {
    final updatedFile = widget.file.copyWith(
      content: WordPair.toFileContent(_words),
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
    final shouldPublish = await showPublishDialog(context);
    if (shouldPublish) {
      final updatedFile = widget.file.copyWith(
        content: WordPair.toFileContent(
            _words), // Gebruik de bijgewerkte woordenlijst
      );
      _cloudService.uploadOrUpdateFile(
          file: updatedFile); // Gebruik de geüpdatete file
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Woordenlijst gepubliceerd'),
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
          setState(() {
            _words[originalIndex] = newPair;
          });
        } else {
          // Add new word
          setState(() {
            _words.add(newPair);
          });
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
    return AspectRatio(
      aspectRatio: 1, // Zorgt ervoor dat de knoppen vierkant blijven
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.tertiaryBlue.withAlpha(220),
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
                  style: GoogleFonts.poppins(
                    // Vervang 'poppins' met jouw gewenste font
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
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
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
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
              PopupMenuItem<String>(
                value: 'publish',
                child: ListTile(
                  leading:
                      const Icon(Icons.public, color: AppTheme.accentOrange),
                  title: Text('Publiceren', style: textTheme.bodyLarge),
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                  title: Text(
                    'Verwijderen',
                    style:
                        textTheme.bodyLarge!.copyWith(color: AppTheme.errorRed),
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.file.title, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(widget.file.subject, style: textTheme.bodyLarge),
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

          // Game Buttons Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MultipleChoiceView(file: widget.file),
                    ),
                  );
                },
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
          TextField(
            controller: _searchController,
            onChanged: _filterWords,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.secondaryBlue,
              hintText: 'Zoek woorden...',
              hintStyle: textTheme.bodyMedium,
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.accentOrange),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppTheme.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _filterWords('');
                      },
                    )
                  : null,
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
              borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
            ),
            elevation: 4,
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
                        onPressed: () => _startEditing(_filteredWords.length),
                      ),
                    ],
                  ),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _wordController,
                              decoration: InputDecoration(
                                hintText: 'Woord',
                                filled: true,
                                fillColor:
                                    AppTheme.secondaryBlue.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadius),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _translationController,
                              decoration: InputDecoration(
                                hintText: 'Vertaling',
                                filled: true,
                                fillColor:
                                    AppTheme.secondaryBlue.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadius),
                                  borderSide: BorderSide.none,
                                ),
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
                  const SizedBox(height: 16),
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
                          separatorBuilder: (context, index) =>
                              const Divider(color: AppTheme.textSecondary),
                          itemBuilder: (context, index) {
                            final pair = _filteredWords[index];
                            return ListTile(
                              title:
                                  Text(pair.word, style: textTheme.bodyLarge),
                              subtitle: Text(pair.translation,
                                  style: textTheme.bodyMedium),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: AppTheme.accentOrange),
                                    onPressed: () => _startEditing(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: AppTheme.errorRed),
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
