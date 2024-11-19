import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/learning/local/file_item.dart';
import 'dart:developer' as d show log;

class FileListView extends StatefulWidget {
  const FileListView({super.key});

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  late final LocalService _localService;
  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;
  bool _isEditing = false;
  List<File> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    _localService = LocalService();
    _fetchFiles();
    super.initState();
  }

  Future<void> _fetchFiles() async {
    try {
      final fetchedFiles = await _localService.getAllFiles();

      setState(() {
        _files = fetchedFiles.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally show an error dialog or snackbar
      print('Error fetching files: $e');
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return Dismissible(
                  key: ValueKey(file.id),
                  onDismissed: (_) async {
                    await _localService.deleteFile(id: file.id);
                    setState(() {
                      _files.removeAt(index);
                    });
                  },
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
                    onDelete: () async {
                      await _localService.deleteFile(id: file.id);
                      setState(() {
                        _files.removeAt(index);
                      });
                    },
                    onFileUpdate: (id, content) async {
                      await _localService.updateFile(id: id, content: content);
                      // Optionally refresh the list or update the specific file
                      _fetchFiles();
                    },
                  ),
                );
              },
            ),
    );
  }
}
