import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/learning/file_item.dart';

class FileListView extends StatefulWidget {
  const FileListView({super.key});

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  final LocalService _localService = LocalService();
  String get userId => AuthService.firebase().currentUser!.id;
  List<File> _files = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    List<Map<String, dynamic>> fileData =
        await _localService.getAllFiles(userId);
    setState(
      () {
        _files = fileData.map((map) => File.fromMap(map)).toList();
      },
    );
  }

  Future<void> _deleteFile(File file) async {
    await _localService.deleteFile(file.id);
    setState(() {
      _files.remove(file);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.title} is verwijderd.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jouw Bestanden'),
        actions: [
          IconButton(
            onPressed: _toggleEditMode,
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return Dismissible(
            key: ValueKey(file.id),
            onDismissed: (_) => _deleteFile(file),
            background: _isEditing
                ? Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  )
                : null,
            child: FileItem(
              file: file,
              onDelete: _isEditing ? () => _deleteFile(file) : null,
            ),
          );
        },
      ),
    );
  }
}
