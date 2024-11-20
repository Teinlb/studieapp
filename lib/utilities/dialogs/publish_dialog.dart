import 'package:flutter/material.dart';

Future<Map<String, String>?> showPublishDialog(BuildContext context) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) {
      final titleController = TextEditingController();
      final descriptionController = TextEditingController();

      return AlertDialog(
        title: const Text('Publiceren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Titel voor gepubliceerde woordenlijst',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isNotEmpty) {
                Navigator.of(context).pop({
                  'title': title,
                  'description': description,
                });
              }
            },
            child: const Text('Publiceren'),
          ),
        ],
      );
    },
  );
}
