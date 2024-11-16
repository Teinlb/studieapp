import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/theme/app_theme.dart';

typedef DeadlineCallback = void Function(Deadline deadline);

class DeadlinesListView extends StatelessWidget {
  final Iterable<Deadline> deadlines;
  final DeadlineCallback onDeleteDeadline;

  const DeadlinesListView({
    super.key,
    required this.deadlines,
    required this.onDeleteDeadline,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: deadlines.length,
      itemBuilder: (context, index) {
        final deadline = deadlines.elementAt(index);
        final daysLeft = deadline.date.difference(DateTime.now()).inDays;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getDeadlineColor(daysLeft),
              child: Text(
                daysLeft.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              deadline.title,
              style: AppTheme.getOrbitronStyle(size: 16),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(deadline.date),
              style: AppTheme.getOrbitronStyle(
                size: 12,
                color: AppTheme.textTertiary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDeleteDeadline(deadline);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color _getDeadlineColor(int daysLeft) {
  if (daysLeft < 0) return AppTheme.errorRed;
  if (daysLeft < 7) return Colors.orange;
  return Colors.green;
}
