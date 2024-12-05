import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/learning/file_item.dart';

class PublishedFileListView extends StatefulWidget {
  const PublishedFileListView({super.key});

  @override
  State<PublishedFileListView> createState() => _PublishedFileListViewState();
}

class _PublishedFileListViewState extends State<PublishedFileListView> {
  late final LocalService _localService;
  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;

  List<File> _files = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
        _files = fetchedFiles.where((file) => file.cloudId != null).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching files: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gepubliceerde Bestanden'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _files.isEmpty
                    ? const Center(child: Text('Geen bestanden gevonden'))
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return FileItem(file: file);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
