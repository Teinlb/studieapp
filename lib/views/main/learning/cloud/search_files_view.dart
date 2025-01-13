import 'package:flutter/material.dart';
import 'package:studieapp/services/cloud/cloud_file.dart';
import 'package:studieapp/services/cloud/firebase_cloud_storage.dart';
import 'package:studieapp/theme/app_theme.dart';

class SearchFilesView extends StatefulWidget {
  const SearchFilesView({super.key});

  @override
  State<SearchFilesView> createState() => _SearchFilesViewState();
}

class _SearchFilesViewState extends State<SearchFilesView> {
  List<CloudFile> _files = [];
  String? selectedSubject;
  String? selectedFileType;

  final List<String> subjects = [
    'Engels',
    'Frans',
    'Duits',
    'Biologie',
    'Scheikunde',
    'Geschiedenis',
    'Aardrijkskunde',
    'Natuurkunde',
    'Wiskunde',
  ];

  final List<String> fileTypes = ['Samenvatting', 'Woordenlijst'];

  void _fetchFiles() async {
    try {
      final cloudStorage = FirebaseCloudStorage();

      final fileType = selectedFileType == null
          ? null
          : (selectedFileType == 'Samenvatting' ? 'summary' : 'wordlist');

      final files = await cloudStorage.fetchFilteredFiles(
        subject: selectedSubject,
        fileType: fileType,
      );

      setState(() {
        _files = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fout bij ophalen bestanden')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Studiebestanden',
          style: AppTheme.theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Vak',
                      filled: true,
                      fillColor: AppTheme.secondaryBlue,
                    ),
                    value: selectedSubject,
                    onChanged: (value) {
                      setState(() => selectedSubject = value);
                      _fetchFiles(); // Update bestanden na selectie
                    },
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(
                          subject,
                          style: AppTheme.theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type bestand',
                      filled: true,
                      fillColor: AppTheme.secondaryBlue,
                    ),
                    value: selectedFileType,
                    onChanged: (value) {
                      setState(() => selectedFileType = value);
                      _fetchFiles(); // Update bestanden na selectie
                    },
                    items: fileTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: AppTheme.theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Resultaten
            Expanded(
              child: _files.isEmpty
                  ? const Center(
                      child: Text('Geen bestanden gevonden'),
                    )
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              file.title,
                              style: AppTheme.theme.textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              file.description,
                              style: AppTheme.theme.textTheme.bodyMedium,
                            ),
                            trailing: const Icon(Icons.arrow_forward,
                                color: AppTheme.accentOrange),
                            onTap: () {
                              // Open detailpagina
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
