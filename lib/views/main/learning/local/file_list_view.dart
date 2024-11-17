import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/learning/local/file_item.dart';

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

  @override
  void initState() {
    _localService = LocalService();
    super.initState();
  }

  // Future<void> _loadFiles() async {
  //   List<Map<String, dynamic>> fileData = await _localService.getAllFiles();
  //   setState(
  //     () {
  //       _files = fileData.map((map) => File.fromMap(map)).toList();
  //     },
  //   );
  // }

  // Future<void> _deleteFile(File file) async {
  //   await _localService.deleteFile(id: file.id);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${file.title} is verwijderd.'),
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }

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
      // body: ListView.builder(
      //   itemCount: _files.length,
      //   itemBuilder: (context, index) {
      //     final file = _files[index];
      //     return Dismissible(
      //       key: ValueKey(file.id),
      //       onDismissed: (_) => _deleteFile(file),
      //       background: _isEditing
      //           ? Container(
      //               color: Colors.red,
      //               alignment: Alignment.centerRight,
      //               padding: const EdgeInsets.only(right: 16),
      //               child: const Icon(Icons.delete, color: Colors.white),
      //             )
      //           : null,
      //       child: FileItem(
      //         file: file,
      //         onDelete: _isEditing ? () => _deleteFile(file) : null,
      //       ),
      //     );
      //   },
      // ),
      body: FutureBuilder(
        future: _localService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _localService
                    .filesStream, // Zorg ervoor dat dit de juiste stream is voor je nieuwe backend
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allFiles = snapshot.data as List<
                            File>; // Zorg ervoor dat 'File' het juiste type is
                        return ListView.builder(
                          itemCount: allFiles.length,
                          itemBuilder: (context, index) {
                            final file = allFiles[index];
                            return Dismissible(
                              key: ValueKey(file.id),
                              onDismissed: (_) async {
                                await _localService.deleteFile(
                                    id: file
                                        .id); // Verwijder het bestand via de service
                              },
                              background: _isEditing
                                  ? Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 16),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    )
                                  : null,
                              child: FileItem(
                                file: file,
                                onDelete: _isEditing
                                    ? () async {
                                        await _localService.deleteFile(
                                            id: file
                                                .id); // Verwijder via de service als 'isEditing' waar is
                                      }
                                    : null, // Verbind onDelete met je backend
                              ),
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
