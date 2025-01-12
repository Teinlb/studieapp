import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/theme/app_theme.dart';

typedef ProjectCallback = void Function(Project project);

class ProjectsListView extends StatelessWidget {
  final Iterable<Project> projects;
  final ProjectCallback onDeleteProject;

  const ProjectsListView({
    super.key,
    required this.projects,
    required this.onDeleteProject,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  int _calculateDaysLeft(DateTime endDate) {
    return endDate.difference(DateTime.now()).inDays;
  }

  Color _getProgressColor(DateTime startDate, DateTime endDate) {
    final totalDays = endDate.difference(startDate).inDays;
    final daysLeft = _calculateDaysLeft(endDate);
    final progress = (totalDays - daysLeft) / totalDays;

    if (progress >= 0.8) return AppTheme.errorRed;
    if (progress >= 0.5) return AppTheme.accentOrange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects.elementAt(index);
        final daysLeft = _calculateDaysLeft(project.endDate);
        final progressColor =
            _getProgressColor(project.startDate, project.endDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // Verwijder de witte lijn
              splashColor:
                  Colors.transparent, // Voorkom kleurflits bij interactie
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor:
                  Colors.transparent, // Zorg voor een consistente achtergrond
              title: Text(
                project.title,
                style: AppTheme.getOrbitronStyle(
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
                    style: AppTheme.getOrbitronStyle(
                      size: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: progressColor, width: 1),
                ),
                child: Text(
                  '$daysLeft dagen',
                  style: AppTheme.getOrbitronStyle(
                    size: 12,
                    color: progressColor,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                  child: TextButton.icon(
                    onPressed: () => onDeleteProject(project),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Verwijderen'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
