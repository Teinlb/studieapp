import 'package:flutter/material.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/services/local/subs/task_service.dart';
import 'package:studieapp/services/local/subs/user_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/views/main/planning/deadlines/deadlines_tab.dart';
import 'package:studieapp/utilities/dialogs/planning_dialog.dart';
import 'package:studieapp/views/main/planning/projects/projects_tab.dart';
import 'package:studieapp/views/main/planning/tasks/tasks_tab.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({super.key});

  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView>
    with SingleTickerProviderStateMixin {
  late final LocalService _localService;
  late final UserService _userService;
  late final TaskService _taskService;

  late TabController _tabController;

  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _localService = LocalService();
    _userService = UserService();
    _taskService = TaskService();
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        children: const [
          TasksTab(),
          DeadlinesTab(),
          ProjectsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
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
  }

  void _showAddTaskDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Use StatefulBuilder
        builder: (context, setState) => Form(
          key: formKey,
          child: PlanningDialog(
            title: 'Nieuwe Taak',
            onCancel: () => Navigator.pop(context),
            onSubmit: () async {
              if (formKey.currentState?.validate() ?? false) {
                final owner =
                    await _userService.getOrCreateUser(email: userEmail);
                _taskService.createTask(
                  owner: owner,
                  title: title,
                  dueDate: dueDate,
                  isCompleted: false,
                );
                Navigator.pop(context);
              }
            },
            children: [
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
              DatePickerField(
                label: 'Deadline',
                selectedDate: dueDate,
                onDateSelected: (date) => setState(() => dueDate = date),
                hintText: 'Kies een deadline (optioneel)',
              ),
            ],
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: PlanningDialog(
              title: 'Nieuwe Deadline',
              onCancel: () => Navigator.pop(context),
              isSubmitEnabled: date != null,
              onSubmit: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final owner =
                      await _localService.getOrCreateUser(email: userEmail);
                  _localService.createDeadline(
                    owner: owner,
                    title: title,
                    date: date!,
                  );
                  Navigator.pop(context);
                }
              },
              children: [
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
                DatePickerField(
                  label: 'Datum',
                  selectedDate: date,
                  onDateSelected: (selectedDate) {
                    setState(() {
                      date = selectedDate;
                    });
                  },
                ),
              ],
            ),
          );
        },
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
      builder: (context) => StatefulBuilder(
        // Use StatefulBuilder
        builder: (context, setState) => Form(
          key: formKey,
          child: PlanningDialog(
            title: 'Nieuw Project',
            onCancel: () => Navigator.pop(context),
            isSubmitEnabled: startDate != null && endDate != null,
            onSubmit: () async {
              if (formKey.currentState?.validate() ?? false) {
                final owner =
                    await _localService.getOrCreateUser(email: userEmail);
                _localService.createProject(
                  owner: owner,
                  title: title,
                  startDate: startDate!,
                  endDate: endDate!,
                );
                Navigator.pop(context);
              }
            },
            children: [
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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 32,
                    child: DatePickerField(
                      label: 'Start',
                      selectedDate: startDate,
                      onDateSelected: (date) {
                        setState(() {
                          startDate = date;
                          if (endDate != null && endDate!.isBefore(date)) {
                            endDate = null;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 32,
                    child: DatePickerField(
                      label: 'Eind',
                      selectedDate: endDate,
                      firstDate: startDate ?? DateTime.now(),
                      onDateSelected: (date) => setState(() => endDate = date),
                      hintText: startDate == null
                          ? 'Kies eerst startdatum'
                          : 'Kies einddatum',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
