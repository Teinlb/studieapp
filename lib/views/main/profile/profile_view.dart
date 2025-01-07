import 'package:flutter/material.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/constants/routes.dart';
import 'package:studieapp/services/local/crud_constants.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/logout_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late LocalService _localService;
  late Future<Map<String, dynamic>> userDataFuture;
  final TextEditingController _usernameController = TextEditingController();

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    userDataFuture = _localService.fetchUserData(userId: userId);
  }

  // main widget
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userData = snapshot.data!;
          final username = userData[usernameColumn] as String;
          final streak = userData[streakColumn] as int? ?? 0;
          final xp = userData[experienceColumn] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(username, streak, xp),
                const SizedBox(height: 24),
                _buildPomodoroSection(),
                const SizedBox(height: 24),
                _buildSettingsSection(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data found'));
        }
      },
    );
  }

  Widget _buildProfileCard(String username, int streak, int xp) {
    bool isEditing = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.accentOrange,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                if (isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController..text = username,
                          decoration: const InputDecoration(
                            labelText: 'Nieuwe gebruikersnaam',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 20,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check,
                            color: AppTheme.accentOrange),
                        onPressed: () {
                          if (_usernameController.text.length <= 20) {
                            setState(() {
                              isEditing = false;
                            });
                            _updateUsername(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Username must be 20 characters or less')),
                            );
                          }
                        },
                      ),
                    ],
                  )
                else
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          username,
                          style: AppTheme.getOrbitronStyle(
                            size: 24,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.accentOrange,
                          ),
                          onPressed: () {
                            setState(() {
                              isEditing = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      icon: Icons.local_fire_department,
                      value: streak.toString(),
                      label: 'Streak',
                    ),
                    _buildStatColumn(
                      icon: Icons.star,
                      value: xp.toString(),
                      label: 'XP',
                    ),
                    _buildLeaderboardButton(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUsername(BuildContext context) async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isNotEmpty) {
      try {
        await _localService.changeUsername(userId, newUsername);
        setState(() {
          userDataFuture = _localService.fetchUserData(userId: userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating username: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty!')),
      );
    }
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.accentOrange,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.getOrbitronStyle(
            size: 20,
            weight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.getOrbitronStyle(
            size: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardButton() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(
            Icons.leaderboard,
            color: AppTheme.accentOrange,
            size: 28,
          ),
          onPressed: () {
            // Navigate to leaderboard
            // Navigator.of(context).pushNamed(leaderboardRoute);
          },
        ),
        Text(
          'Ranglijst',
          style: AppTheme.getOrbitronStyle(
            size: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pomodoro Timer',
                  style: AppTheme.getOrbitronStyle(
                    size: 22,
                    weight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(
                        16), // Optioneel: meer ruimte rondom het icoon
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(pomodoroRoute);
                  },
                  child: const Icon(Icons.timer, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPomodoroStatColumn(
                  icon: Icons.check_circle_outline,
                  value: '0',
                  label: 'Sessies',
                ),
                _buildPomodoroStatColumn(
                  icon: Icons.schedule,
                  value: '25 min',
                  label: 'Tijd gewerkt',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPomodoroStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.accentOrange,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.getOrbitronStyle(
            size: 18,
            weight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.getOrbitronStyle(
            size: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Instellingen',
              style: AppTheme.getOrbitronStyle(
                size: 20,
                weight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Meldingen',
            subtitle: 'Beheer je notificaties',
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Taal',
            subtitle: 'Nederlands',
            onTap: () {
              // Navigate to language settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Thema',
            subtitle: 'Donker',
            onTap: () {
              // Navigate to AppTheme settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentOrange),
      title: Text(
        title,
        style: AppTheme.getOrbitronStyle(size: 16),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.getOrbitronStyle(
          size: 14,
          color: AppTheme.textTertiary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.errorRed,
        foregroundColor: AppTheme.textPrimary,
      ),
      onPressed: () async {
        final shouldLogout = await showLogOutDialog(context);
        if (shouldLogout) {
          await AuthService.firebase().logOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            );
          }
        }
      },
      child: const Text('Uitloggen'),
    );
  }
}
