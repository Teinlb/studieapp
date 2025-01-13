import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/views/main/learning/local/summary/summary_view.dart';
import 'package:studieapp/views/main/learning/local/wordlist/wordlist_view.dart';

class FileItem extends StatelessWidget {
  final File file;

  const FileItem({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (file.type == 'wordlist') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WordListView(id: file.id)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SummaryView(id: file.id)),
          );
        }
      },
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
