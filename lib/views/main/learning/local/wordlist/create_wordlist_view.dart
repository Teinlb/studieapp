import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:csv/csv.dart';

class WordPair {
  String word;
  String translation;

  WordPair({required this.word, required this.translation});
}

class CreateWordListView extends StatefulWidget {
  const CreateWordListView({super.key});
  @override
  State<CreateWordListView> createState() => _CreateWordListViewState();
}

class _CreateWordListViewState extends State<CreateWordListView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedSubject;
  final TextEditingController _otherSubjectController = TextEditingController();
  final List<WordPair> _words = [];

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _otherSubjectController.dispose();
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  void _addWord() {
    if (_wordController.text.isNotEmpty &&
        _translationController.text.isNotEmpty) {
      setState(() {
        _words.add(WordPair(
          word: _wordController.text,
          translation: _translationController.text,
        ));
        _wordController.clear();
        _translationController.clear();
      });
    }
  }

  void _removeWord(int index) {
    setState(() {
      _words.removeAt(index);
    });
  }

  Future<void> _importWordList() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
      );

      if (result != null) {
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

        if (fileBytes == null) return;

        if (fileName.endsWith('.csv')) {
          final csvString = utf8.decode(fileBytes);
          final rows = const CsvToListConverter().convert(csvString);

          for (var row in rows) {
            if (row.length >= 2) {
              _words.add(WordPair(
                  word: row[0].toString(), translation: row[1].toString()));
            }
          }
        } else if (fileName.endsWith('.json')) {
          final jsonString = utf8.decode(fileBytes);
          final jsonData = jsonDecode(jsonString) as List<dynamic>;

          for (var item in jsonData) {
            if (item['word'] != null && item['translation'] != null) {
              _words.add(WordPair(
                word: item['word'],
                translation: item['translation'],
              ));
            }
          }
        }

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Woordenlijst geïmporteerd!'),
            backgroundColor: AppTheme.accentOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fout bij het importeren van bestand'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveWordList() async {
    if (_formKey.currentState!.validate() &&
        _words.isNotEmpty &&
        (_selectedSubject != null || _otherSubjectController.text.isNotEmpty)) {
      final subject = _selectedSubject == 'Overig'
          ? _otherSubjectController.text
          : _selectedSubject;

      final currentUser =
          await LocalService().getOrCreateUser(email: userEmail);

      await LocalService().createFile(
        owner: currentUser,
        title: _titleController.text,
        subject: subject!,
        description: _descriptionController.text,
        content:
            _words.map((pair) => '${pair.word}|${pair.translation}').join('\n'),
        type: 'wordlist',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Woordenlijst opgeslagen!'),
          backgroundColor: AppTheme.accentOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text(
          'Nieuwe Woordenlijst',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.secondaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWordList,
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                          'Woordenlijst Gegevens',
                          style: AppTheme.getOrbitronStyle(
                            size: 18,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          style: AppTheme.getOrbitronStyle(),
                          decoration: InputDecoration(
                            labelText: 'Titel',
                            labelStyle: AppTheme.getOrbitronStyle(
                                color: AppTheme.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      AppTheme.textTertiary.withOpacity(0.5)),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppTheme.accentOrange),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Voer een titel in';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          items: [
                            'Wiskunde',
                            'Natuurkunde',
                            'Geschiedenis',
                            'Literatuur',
                            'Overig'
                          ]
                              .map((subject) => DropdownMenuItem(
                                    value: subject,
                                    child: Text(
                                      subject,
                                      style: AppTheme.getOrbitronStyle(),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubject = value;
                              _otherSubjectController.clear();
                            });
                          },
                          style: AppTheme.getOrbitronStyle(),
                          dropdownColor: AppTheme.secondaryBlue,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Vak',
                            labelStyle: AppTheme.getOrbitronStyle(
                                color: AppTheme.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      AppTheme.textTertiary.withOpacity(0.5)),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppTheme.accentOrange),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                          ),
                          validator: (value) {
                            if (value == null &&
                                _otherSubjectController.text.isEmpty) {
                              return 'Selecteer een vak of vul er een in';
                            }
                            return null;
                          },
                        ),
                        if (_selectedSubject == 'Overig') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otherSubjectController,
                            style: AppTheme.getOrbitronStyle(),
                            decoration: InputDecoration(
                              labelText: 'Overig Vak',
                              labelStyle: AppTheme.getOrbitronStyle(
                                  color: AppTheme.textSecondary),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        AppTheme.textTertiary.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppTheme.accentOrange),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                              ),
                            ),
                            validator: (value) {
                              if (_selectedSubject == 'Overig' &&
                                  value == null) {
                                return 'Vul het overige vak in';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          style: AppTheme.getOrbitronStyle(),
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Omschrijving (optioneel)',
                            labelStyle: AppTheme.getOrbitronStyle(
                                color: AppTheme.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      AppTheme.textTertiary.withOpacity(0.5)),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppTheme.accentOrange),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.borderRadius),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                          'Voeg Woorden Toe',
                          style: AppTheme.getOrbitronStyle(
                            size: 18,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _wordController,
                                style: AppTheme.getOrbitronStyle(),
                                decoration: InputDecoration(
                                  labelText: 'Woord',
                                  labelStyle: AppTheme.getOrbitronStyle(
                                      color: AppTheme.textSecondary),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.textTertiary
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadius),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppTheme.accentOrange),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadius),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _translationController,
                                style: AppTheme.getOrbitronStyle(),
                                decoration: InputDecoration(
                                  labelText: 'Vertaling',
                                  labelStyle: AppTheme.getOrbitronStyle(
                                      color: AppTheme.textSecondary),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppTheme.textTertiary
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadius),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppTheme.accentOrange),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.borderRadius),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _addWord,
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppTheme.accentOrange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _words.length,
                          itemBuilder: (context, index) {
                            final pair = _words[index];
                            return ListTile(
                              title: Text(
                                '${pair.word} - ${pair.translation}',
                                style: AppTheme.getOrbitronStyle(),
                              ),
                              trailing: IconButton(
                                onPressed: () => _removeWord(index),
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _importWordList,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importeer woordenlijst'),
                ),
                const SizedBox(height: 16),
                Card(
                  color: AppTheme.secondaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Je kunt een CSV-bestand met de kolommen "Woord" en "Vertaling", of een JSON-bestand importeren.',
                            style: AppTheme.getOrbitronStyle(
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
