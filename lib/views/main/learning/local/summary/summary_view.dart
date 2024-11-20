import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/utilities/dialogs/publish_dialog.dart';

class SummaryView extends StatefulWidget {
  final File file;

  const SummaryView({
    super.key,
    required this.file,
  });

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  late final LocalService _localService;

  @override
  void initState() {
    super.initState();
    final updatedFile = widget.file.copyWith(
      lastOpened: DateTime.now(),
    );
    _localService = LocalService();
    _localService.updateFile(id: updatedFile.id, content: updatedFile.content);
  }

  // void _updateFile() {
  //   final updatedFile = widget.file.copyWith(
  //     content: ,
  //     lastOpened: DateTime.now(),
  //   );
  //   // widget.onFileUpdate(updatedFile.id, updatedFile.content);
  //   _localService.updateFile(id: updatedFile.id, content: updatedFile.content);
  // }

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
          const SizedBox(height: 8),

          // Words List with Editing Functionality
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.file.content,
                style: textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
