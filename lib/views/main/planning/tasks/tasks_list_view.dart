import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Voor datumformatting
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/utilities/dialogs/delete_dialog.dart';
import 'package:studieapp/theme/app_theme.dart';

typedef TaskCallback = void Function(Task task);
typedef TaskToggleCallback = Future<void> Function(Task task, bool isCompleted);

class TasksListView extends StatelessWidget {
  final Iterable<Task> tasks;
  final TaskCallback onDeleteTask;
  final TaskToggleCallback onToggleTask;

  const TasksListView({
    super.key,
    required this.tasks,
    required this.onDeleteTask,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                onToggleTask(task, value!);
                task.isCompleted = value;
              },
              activeColor: AppTheme.accentOrange,
            ),
            title: Text(
              task.title,
              style: AppTheme.getOrbitronStyle(
                size: 16,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              task.dueDate != null
                  ? DateFormat('dd/MM/yyyy').format(task.dueDate!)
                  : 'Geen deadline',
              style: AppTheme.getOrbitronStyle(
                size: 12,
                color: AppTheme.textTertiary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteTask(task);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
