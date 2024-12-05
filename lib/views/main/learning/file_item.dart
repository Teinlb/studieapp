import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/views/main/learning/local/summary/summary_view.dart';
import 'package:studieapp/views/main/learning/local/wordlist/wordlist_view.dart';

class FileItem extends StatelessWidget {
  final File file;

  const FileItem({
    super.key,
    required this.file,
  });

  Future<void> _handleTap(BuildContext context) async {
    final localService = LocalService();

    try {
      // Haal het meest recente bestand op via de service
      final updatedFile = await localService.getFile(id: file.id);

      // Navigeer naar de juiste view met het bijgewerkte bestand
      if (updatedFile.type == 'wordlist') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WordListView(file: updatedFile)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SummaryView(file: updatedFile)),
        );
      }
    } catch (e) {
      // Toon een foutmelding als er iets misgaat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kon het bestand niet bijwerken: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: AppTheme.theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      file.subject,
                      style: AppTheme.theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      file.type == 'wordlist' ? 'Woordenlijst' : 'Samenvatting',
                      style: AppTheme.theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
