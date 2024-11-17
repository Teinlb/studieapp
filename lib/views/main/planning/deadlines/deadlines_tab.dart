import 'package:flutter/material.dart';
import 'package:studieapp/models/planning_models.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/planning/deadlines/deadlines_list_view.dart';
import 'package:studieapp/views/main/planning/empty_state.dart';

class DeadlinesTab extends StatefulWidget {
  const DeadlinesTab({Key? key}) : super(key: key);

  @override
  _DeadlinesViewState createState() => _DeadlinesViewState();
}

class _DeadlinesViewState extends State<DeadlinesTab> {
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
              stream: _localService.deadlinesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return buildEmptyState(
                    'Nog geen deadlines',
                    'Voeg deadlines toe om te beginnen',
                  );
                } else {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allDeadlines = snapshot.data as List<Deadline>;
                        return DeadlinesListView(
                          deadlines: allDeadlines,
                          onDeleteDeadline: (deadline) async {
                            await _localService.deleteDeadline(
                              id: deadline.id,
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
