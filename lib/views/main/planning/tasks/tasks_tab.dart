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
  String _currentFilter = 'all'; // Track current filter state

  @override
  void initState() {
    _localService = LocalService();
    super.initState();
  }

  // New method to filter tasks based on selected segment
  List<Task> _filterTasks(List<Task> tasks) {
    final now = DateTime.now();

    switch (_currentFilter) {
      case 'today':
        return tasks
            .where(
                (task) => task.dueDate != null && isSameDay(task.dueDate!, now))
            .toList();

      case 'week':
        return tasks
            .where((task) =>
                task.dueDate != null && isWithinWeek(task.dueDate!, now))
            .toList();

      case 'all':
      default:
        return tasks;
    }
  }

  // Utility method to check if two dates are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Utility method to check if a date is within the current week
  bool isWithinWeek(DateTime date, DateTime now) {
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd);
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
                              final filteredTasks = _filterTasks(allTasks);

                              return filteredTasks.isEmpty
                                  ? buildEmptyState('Geen taken',
                                      'Geen taken gevonden voor deze periode')
                                  : TasksListView(
                                      tasks: filteredTasks,
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
              selected: {_currentFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _currentFilter = newSelection.first;
                });
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
}
