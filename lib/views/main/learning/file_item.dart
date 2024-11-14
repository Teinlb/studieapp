import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';

class FileItem extends StatelessWidget {
  final File file;
  final VoidCallback? onDelete;

  const FileItem({
    super.key,
    required this.file,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
