import 'package:flutter/material.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';

class CreateSummaryView extends StatefulWidget {
  const CreateSummaryView({super.key});
  @override
  State<CreateSummaryView> createState() => _CreateSummaryViewState();
}

class _CreateSummaryViewState extends State<CreateSummaryView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedSubject;
  final TextEditingController _otherSubjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _otherSubjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveSummary() async {
    if (_formKey.currentState!.validate() &&
        _contentController.text.isNotEmpty &&
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
        content: _contentController.text,
        type: 'summary',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Samenvatting opgeslagen!'),
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
          'Nieuwe Samenvatting',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.secondaryBlue,
        elevation: 0,
      ),
      body: Form(
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
                      'Samenvatting',
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
                              color: AppTheme.textTertiary.withOpacity(0.5)),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.accentOrange),
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
                        'Engels',
                        'Frans',
                        'Duits',
                        'Biologie',
                        'Scheikunde',
                        'Geschiedenis',
                        'Aardrijkskunde',
                        'Natuurkunde',
                        'Wiskunde',
                        'Overig',
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
                              color: AppTheme.textTertiary.withOpacity(0.5)),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.accentOrange),
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
                                color: AppTheme.textTertiary.withOpacity(0.5)),
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: AppTheme.accentOrange),
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                          ),
                        ),
                        validator: (value) {
                          if (_selectedSubject == 'Overig' && value == null) {
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
                              color: AppTheme.textTertiary.withOpacity(0.5)),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.accentOrange),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      style: AppTheme.getOrbitronStyle(),
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Inhoud van de Samenvatting',
                        labelStyle: AppTheme.getOrbitronStyle(
                            color: AppTheme.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppTheme.textTertiary.withOpacity(0.5)),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.accentOrange),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Voer de inhoud van de samenvatting in';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveSummary,
              icon: const Icon(Icons.save),
              label: const Text('Samenvatting opslaan'),
            ),
          ],
        ),
      ),
    );
  }
}
