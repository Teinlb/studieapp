import 'package:flutter/material.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/planning/Projects/Projects_list_view.dart';
import 'package:studieapp/views/main/planning/empty_state.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({Key? key}) : super(key: key);

  @override
  _ProjectsViewState createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsTab> {
  late final LocalService _localService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _localService = LocalService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _localService.getOrCreateUser(email: userEmail),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
              stream: _localService.projectsStream,
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
                        final allProjects = snapshot.data as List<Project>;
                        return ProjectsListView(
                          projects: allProjects,
                          onDeleteProject: (project) async {
                            await _localService.deleteProject(
                              id: project.id,
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
    );
  }
}
