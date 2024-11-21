import 'package:flutter/material.dart';
import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/constants/routes.dart';
import 'package:studieapp/theme/app_theme.dart';
import 'package:studieapp/utilities/dialogs/logout_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Mock data - replace with actual user data from your backend
  final String username = "Student123";
  final int streak = 7;
  final int xp = 1250;

  // main widget
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildPomodoroSection(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
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
            Text(
              username,
              style: AppTheme.getOrbitronStyle(
                size: 24,
                weight: FontWeight.bold,
              ),
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
