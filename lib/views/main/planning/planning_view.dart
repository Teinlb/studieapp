import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/theme/app_theme.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({super.key});

  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView> {
  // Mock data - replace with actual data from your backend
  final List<Task> tasks = [];
  final List<Deadline> deadlines = [];
  final List<Project> projects = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: AppTheme.secondaryBlue,
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Taken'),
                Tab(text: 'Deadlines'),
                Tab(text: 'Projecten'),
                Tab(text: 'Rooster'),
              ],
              labelStyle: TextStyle(fontFamily: 'Orbitron'),
              indicatorColor: AppTheme.accentOrange,
              labelColor: AppTheme.accentOrange,
              unselectedLabelColor: AppTheme.textSecondary,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasksTab(),
            _buildDeadlinesTab(),
            _buildProjectsTab(),
            _buildScheduleTab(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.accentOrange,
      child: const Icon(Icons.add, color: Colors.black),
      onPressed: () {
        final currentIndex = DefaultTabController.of(context).index;
        switch (currentIndex) {
          case 0:
            _showAddTaskDialog();
            break;
          case 1:
            _showAddDeadlineDialog();
            break;
          case 2:
            _showAddProjectDialog();
            break;
          case 3:
            _showAddScheduleItemDialog();
            break;
        }
      },
    );
  }

  // Tasks Tab
  Widget _buildTasksTab() {
    return Column(
      children: [
        _buildTaskFilters(),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState(
                  'Nog geen taken', 'Voeg taken toe om te beginnen')
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskItem(tasks[index]);
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

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            setState(() {
              task.isCompleted = value ?? false;
            });
          },
          activeColor: AppTheme.accentOrange,
        ),
        title: Text(
          task.title,
          style: AppTheme.getOrbitronStyle(
            size: 16,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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
          onPressed: () {
            setState(() {
              tasks.remove(task);
            });
          },
        ),
      ),
    );
  }

  // Deadlines Tab
  Widget _buildDeadlinesTab() {
    return deadlines.isEmpty
        ? _buildEmptyState('Geen deadlines', 'Voeg belangrijke data toe')
        : ListView.builder(
            itemCount: deadlines.length,
            itemBuilder: (context, index) {
              return _buildDeadlineItem(deadlines[index]);
            },
          );
  }

  Widget _buildDeadlineItem(Deadline deadline) {
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
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDeadlineDialog(deadline),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  deadlines.remove(deadline);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getDeadlineColor(int daysLeft) {
    if (daysLeft < 0) return AppTheme.errorRed;
    if (daysLeft < 7) return Colors.orange;
    return Colors.green;
  }

  // Projects Tab
  Widget _buildProjectsTab() {
    return projects.isEmpty
        ? _buildEmptyState('Geen projecten', 'Begin een nieuw project')
        : ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _buildProjectItem(projects[index]);
            },
          );
  }

  Widget _buildProjectItem(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          project.title,
          style: AppTheme.getOrbitronStyle(size: 16),
        ),
        subtitle: Text(
          '${project.completedTasks}/${project.totalTasks} taken afgerond',
          style: AppTheme.getOrbitronStyle(
            size: 12,
            color: AppTheme.textTertiary,
          ),
        ),
        leading: CircularProgressIndicator(
          value: project.totalTasks > 0
              ? project.completedTasks / project.totalTasks
              : 0,
          backgroundColor: AppTheme.secondaryBlue,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.description,
                  style: AppTheme.getOrbitronStyle(size: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Bewerken'),
                      onPressed: () => _showEditProjectDialog(project),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Verwijderen'),
                      onPressed: () {
                        setState(() {
                          projects.remove(project);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Schedule Tab
  Widget _buildScheduleTab() {
    return Column(
      children: [
        _buildWeekSelector(),
        Expanded(
          child: _buildScheduleGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              // Previous week
            },
          ),
          Text(
            'Week 1',
            style: AppTheme.getOrbitronStyle(
              size: 18,
              weight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // Next week
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 35, // 7 days * 5 time slots
      itemBuilder: (context, index) {
        return _buildScheduleCell(index);
      },
    );
  }

  Widget _buildScheduleCell(int index) {
    return Card(
      color: AppTheme.secondaryBlue,
      child: InkWell(
        onTap: () => _showAddScheduleItemDialog(),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '9:00',
                style: AppTheme.getOrbitronStyle(
                  size: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  'Wiskunde',
                  style: AppTheme.getOrbitronStyle(size: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.getOrbitronStyle(
              size: 20,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.getOrbitronStyle(
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddTaskDialog() {
    // Implement task dialog
  }

  void _showAddDeadlineDialog() {
    // Implement deadline dialog
  }

  void _showEditDeadlineDialog(Deadline deadline) {
    // Implement edit deadline dialog
  }

  void _showAddProjectDialog() {
    // Implement project dialog
  }

  void _showEditProjectDialog(Project project) {
    // Implement edit project dialog
  }

  void _showAddScheduleItemDialog() {
    // Implement schedule item dialog
  }
}

// Models
class Task {
  String title;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.title,
    this.dueDate,
    this.isCompleted = false,
  });
}

class Deadline {
  String title;
  DateTime date;

  Deadline({
    required this.title,
    required this.date,
  });
}

class Project {
  String title;
  String description;
  int completedTasks;
  int totalTasks;

  Project({
    required this.title,
    required this.description,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });
}
