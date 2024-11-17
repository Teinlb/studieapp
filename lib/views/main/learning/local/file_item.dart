import 'package:flutter/material.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/views/main/learning/local/wordlist/wordlist_view.dart';

class FileItem extends StatelessWidget {
  final File file;
  final VoidCallback? onDelete;
  final Function(File)? onFileUpdate;

  const FileItem({
    super.key,
    required this.file,
    this.onDelete,
    this.onFileUpdate,
  });

  void _handleTap(BuildContext context) {
    if (file.type == 'wordlist') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordListView(
            file: file,
            onFileUpdate: onFileUpdate != null
                ? (updatedFile) {
                    onFileUpdate!(updatedFile);
                  }
                : null,
          ),
        ),
      );
    } else {
      // Handle summary type files here
      // TODO: Navigate to summary view when implemented
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Samenvattingen worden nog niet ondersteund'),
        ),
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
      ),
    );
  }
}
