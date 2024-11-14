import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/theme/app_theme.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({super.key});

  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView>
    with SingleTickerProviderStateMixin {
  // Mock data - replace with actual data from your backend
  final List<Task> tasks = [];
  final List<Deadline> deadlines = [];
  final List<Project> projects = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: AppTheme.secondaryBlue,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Taken'),
              Tab(text: 'Deadlines'),
              Tab(text: 'Projecten'),
              Tab(text: 'Rooster'),
            ],
            labelStyle: const TextStyle(fontFamily: 'Orbitron'),
            indicatorColor: AppTheme.accentOrange,
            labelColor: AppTheme.accentOrange,
            unselectedLabelColor: AppTheme.textSecondary,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksTab(),
          _buildDeadlinesTab(),
          _buildProjectsTab(),
          _buildScheduleTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index != 3) {
      return FloatingActionButton(
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _showAddTaskDialog();
              break;
            case 1:
              _showAddDeadlineDialog();
              break;
            case 2:
              _showAddProjectDialog();
              break;
          }
        },
      );
    } else {
      return null;
    }
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
    return const Card(
      color: AppTheme.secondaryBlue,
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
    final formKey = GlobalKey<FormState>();
    String title = '';
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nieuwe Taak',
                  style: AppTheme.getOrbitronStyle(
                    size: 24,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    prefixIcon: Icon(Icons.task_outlined),
                  ),
                  style: AppTheme.getOrbitronStyle(size: 16),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Vul een titel in' : null,
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppTheme.accentOrange,
                                  onPrimary: Colors.black,
                                  surface: AppTheme.secondaryBlue,
                                  onSurface: AppTheme.textPrimary,
                                ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => dueDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBlue,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppTheme.accentOrange),
                        const SizedBox(width: 16),
                        Text(
                          dueDate != null
                              ? DateFormat('dd/MM/yyyy').format(dueDate!)
                              : 'Kies een deadline (optioneel)',
                          style: AppTheme.getOrbitronStyle(size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() {
                            tasks.add(Task(
                              title: title,
                              dueDate: dueDate,
                              isCompleted: false,
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Toevoegen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDeadlineDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    DateTime? date;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nieuwe Deadline',
                  style: AppTheme.getOrbitronStyle(
                    size: 24,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  style: AppTheme.getOrbitronStyle(size: 16),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Vul een titel in' : null,
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: AppTheme.accentOrange,
                                  onPrimary: Colors.black,
                                  surface: AppTheme.secondaryBlue,
                                  onSurface: AppTheme.textPrimary,
                                ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (selectedDate != null) {
                      setState(() => date = selectedDate);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBlue,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppTheme.accentOrange),
                        const SizedBox(width: 16),
                        Text(
                          date != null
                              ? DateFormat('dd/MM/yyyy').format(date!)
                              : 'Kies een datum',
                          style: AppTheme.getOrbitronStyle(size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (date == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecteer een datum'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                          return;
                        }
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() {
                            deadlines.add(Deadline(
                              title: title,
                              date: date!,
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Toevoegen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProjectDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nieuw Project',
                  style: AppTheme.getOrbitronStyle(
                    size: 24,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Projectnaam',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  style: AppTheme.getOrbitronStyle(size: 16),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Vul een projectnaam in' : null,
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme:
                                      Theme.of(context).colorScheme.copyWith(
                                            primary: AppTheme.accentOrange,
                                            onPrimary: Colors.black,
                                            surface: AppTheme.secondaryBlue,
                                            onSurface: AppTheme.textPrimary,
                                          ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                              // Reset endDate if it's before the new startDate
                              if (endDate != null && endDate!.isBefore(date)) {
                                endDate = null;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlue,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start',
                                style: AppTheme.getOrbitronStyle(
                                  size: 14,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: AppTheme.accentOrange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    startDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(startDate!)
                                        : 'Start',
                                    style: AppTheme.getOrbitronStyle(size: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (startDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecteer eerst een startdatum'),
                                backgroundColor: AppTheme.errorRed,
                              ),
                            );
                            return;
                          }
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                startDate!.add(const Duration(days: 1)),
                            firstDate: startDate!.add(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme:
                                      Theme.of(context).colorScheme.copyWith(
                                            primary: AppTheme.accentOrange,
                                            onPrimary: Colors.black,
                                            surface: AppTheme.secondaryBlue,
                                            onSurface: AppTheme.textPrimary,
                                          ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlue,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Eind',
                                style: AppTheme.getOrbitronStyle(
                                  size: 14,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: AppTheme.accentOrange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    endDate != null
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(endDate!)
                                        : 'Eind',
                                    style: AppTheme.getOrbitronStyle(size: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecteer start- en einddatum'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                          return;
                        }
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() {
                            projects.add(Project(
                              title: title,
                              startDate: startDate!,
                              endDate: endDate!,
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Toevoegen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
