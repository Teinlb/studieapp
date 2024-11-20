import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/publish_dialog.dart';

class PublishFileListView extends StatefulWidget {
  const PublishFileListView({super.key});

  @override
  State<PublishFileListView> createState() => _PublishFileListViewState();
}

class _PublishFileListViewState extends State<PublishFileListView> {
  late final LocalService _localService;
  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;

  List<File> _files = [];
  List<File> _filteredFiles = [];
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
        _files = fetchedFiles.toList();
        _filteredFiles = _files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching files: $e');
    }
  }

  void _filterFiles(String query) {
    setState(() {
      _filteredFiles = _files
          .where(
              (file) => file.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deel Jouw Bestanden'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Zoek bestanden...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterFiles,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFiles.isEmpty
                    ? const Center(child: Text('Geen bestanden gevonden'))
                    : ListView.builder(
                        itemCount: _filteredFiles.length,
                        itemBuilder: (context, index) {
                          final file = _filteredFiles[index];
                          return InkWell(
                            onTap: () {
                              _publishFile();
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.title,
                                            style: AppTheme
                                                .theme.textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            file.subject,
                                            style: AppTheme
                                                .theme.textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
