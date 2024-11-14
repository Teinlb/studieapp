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
