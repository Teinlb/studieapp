import 'package:flutter/material.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/views/main/planning/empty_state.dart';
import 'package:studieapp/views/main/planning/tasks/tasks_list_view.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksTab> {
  late final LocalService _localService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _localService = LocalService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTaskFilters(),
        Expanded(
          child: FutureBuilder(
            future: _localService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: _localService.tasksStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return buildEmptyState(
                          'Nog geen taken',
                          'Voeg taken toe om te beginnen',
                        );
                      } else {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final allTasks = snapshot.data as List<Task>;
                              return TasksListView(
                                tasks: allTasks,
                                onDeleteTask: (task) async {
                                  await _localService.deleteTask(
                                    id: task.id,
                                  );
                                },
                                onToggleTask: (task, value) async {
                                  await _localService.updateTask(
                                    id: task.id,
                                    isCompleted: value,
                                  );
                                },
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          default:
                            return const CircularProgressIndicator();
                        }
                      }
                    },
                  );
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildTaskFilters() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('Alles')),
              ButtonSegment(value: 'today', label: Text('Vandaag')),
              ButtonSegment(value: 'week', label: Text('Week')),
            ],
            selected: const {'all'},
            onSelectionChanged: (Set<String> newSelection) {
              // Implement filter logic
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.accentOrange;
                  }
                  return AppTheme.secondaryBlue;
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
