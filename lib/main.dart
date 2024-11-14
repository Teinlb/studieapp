import 'package:flutter/material.dart';
import 'package:studieapp/layouts/main_layout.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/constants/routes.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/views/auth/login_view.dart';
import 'package:studieapp/views/main/learning/create/create_summary_view.dart';
import 'package:studieapp/views/main/learning/create/create_wordlist_view.dart';
import 'package:studieapp/views/main/learning/file_list_view.dart';
import 'package:studieapp/views/main/learning/learning_view.dart';
import 'package:studieapp/views/notes/create_update_note_view.dart';
import 'package:studieapp/views/notes/notes_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studieapp/views/auth/register_view.dart';
import 'package:studieapp/views/auth/verify_email_view.dart';
import 'package:studieapp/views/main/planning/planning_view.dart';
import 'package:studieapp/views/main/profile/profile_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Ideale Studie-App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
      routes: {
        // auth
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),

        // notes
        notesRoute: (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),

        // main
        mainLayoutRoute: (context) => const MainLayout(),

        // learning
        learningRoute: (context) => const LearningView(),
        fileListRoute: (context) => const FileListView(),
        createWordlistRoute: (context) => const CreateWordListView(),
        createSummaryRoute: (context) => const CreateSummaryView(),

        // planning
        planningRoute: (context) => const PlanningView(),

        // profile
        profileRoute: (context) => const ProfileView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const MainLayout();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
