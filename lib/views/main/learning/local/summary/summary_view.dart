import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/cloud/firebase_cloud_storage.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/utilities/dialogs/publish_dialog.dart';

class SummaryView extends StatefulWidget {
  final int id;

  const SummaryView({
    super.key,
    required this.id,
  });

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  late final LocalService _localService;
  late final FirebaseCloudStorage _cloudService;

  late File _file;

  late TextEditingController _contentController;

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _localService = LocalService();
    _cloudService = FirebaseCloudStorage();

    _file = await _localService.getFile(id: widget.id);
    _file = _file.copyWith(
      lastOpened: DateTime.now(),
    );

    _contentController = TextEditingController(text: _file.content);

    setState(() {
      _isLoading = false;
    });
  }

  void _updateFile() {
    _localService.updateFile(id: _file.id, content: _contentController.text);
  }

  void _deleteFile() async {
    final shouldDelete = await showDeleteDialog(context);
    if (shouldDelete) {
      _localService.deleteFile(id: _file.id);

      // Navigeer terug naar het vorige scherm
      Navigator.of(context).pop();
    }
  }

  void _publishFile() async {
    final shouldPublish = await showPublishDialog(context);
    if (shouldPublish) {
      _cloudService.uploadOrUpdateFile(file: _file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Samenvatting gepubliceerd'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text('Samenvatting', style: textTheme.displayMedium),
        backgroundColor: AppTheme.secondaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _updateFile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          // Popup menu button
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
      body: _isLoading
          ? FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 500), () {}),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Container();
              },
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppTheme.secondaryBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _file.title,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _file.subject,
                          style: textTheme.bodyLarge,
                        ),
                        if (_file.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _file.description,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Content Card - toggle between TextField and Text based on _isEditing
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isEditing
                        ? TextField(
                            controller: _contentController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText:
                                  'Bewerk de inhoud van de samenvatting...',
                            ),
                            onChanged: (text) {
                              setState(() {
                                _file = _file.copyWith(content: text);
                              });
                            },
                          )
                        : Text(
                            _file.content,
                            style: textTheme.bodyMedium,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
