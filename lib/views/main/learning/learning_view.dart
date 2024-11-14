import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/constants/routes.dart';
import 'package:studieapp/theme/app_theme.dart';

class LearningView extends StatefulWidget {
  const LearningView({super.key});

  @override
  State<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends State<LearningView> {
  // Mock data - replace with actual data from your backend
  final List<StudyFile> recentFiles = [
    StudyFile(
      title: 'Economie H1',
      type: FileType.flashcards,
      lastOpened: DateTime.now().subtract(const Duration(hours: 2)),
      thumbnailUrl: 'path/to/thumbnail',
    ),
    StudyFile(
      title: 'Nederlands Literatuur',
      type: FileType.summary,
      lastOpened: DateTime.now().subtract(const Duration(days: 1)),
      thumbnailUrl: 'path/to/thumbnail',
    ),
  ];

  // main widget
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentFiles(),
            const SizedBox(height: 24),
            _buildCreateSection(),
            const SizedBox(height: 24),
            _buildOnlineSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent geopend',
              style: AppTheme.getOrbitronStyle(
                size: 24,
                weight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.folder_outlined),
              label: const Text('Alle bestanden'),
              onPressed: () {
                Navigator.of(context).pushNamed(fileListRoute);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentFiles.length,
            itemBuilder: (context, index) {
              return _buildRecentFileCard(recentFiles[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFileCard(StudyFile file) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          // Open file
        },
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                file.type == FileType.flashcards
                    ? Icons.style_outlined
                    : Icons.description_outlined,
                size: 32,
                color: AppTheme.accentOrange,
              ),
              const Spacer(),
              Text(
                file.title,
                style: AppTheme.getOrbitronStyle(
                  size: 16,
                  weight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Laatst geopend: ${_formatDate(file.lastOpened)}',
                style: AppTheme.getOrbitronStyle(
                  size: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nieuw bestand maken',
          style: AppTheme.getOrbitronStyle(
            size: 24,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCreateCard(
                title: 'Woordenlijst',
                icon: Icons.style_outlined,
                onTap: () {
                  Navigator.of(context).pushNamed(createWordlistRoute);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCreateCard(
                title: 'Samenvatting',
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.of(context).pushNamed(createSummaryRoute);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTheme.getOrbitronStyle(
                  size: 16,
                  weight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Bibliotheek',
          style: AppTheme.getOrbitronStyle(
            size: 24,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildOnlineOption(
                title: 'Zoek studiemateriaal',
                subtitle: 'Ontdek woordenlijsten en samenvattingen van anderen',
                icon: Icons.search,
                onTap: () {
                  // Navigate to search page
                },
              ),
              const Divider(height: 1),
              _buildOnlineOption(
                title: 'Deel je bestanden',
                subtitle: 'Help anderen door je materiaal te delen',
                icon: Icons.upload_file,
                onTap: () {
                  // Navigate to upload page
                },
              ),
              const Divider(height: 1),
              _buildOnlineOption(
                title: 'Jouw gedeelde content',
                subtitle: 'Bekijk en beheer je gedeelde bestanden',
                icon: Icons.person_outline,
                onTap: () {
                  // Navigate to shared content page
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentOrange.withOpacity(0.1),
        child: Icon(
          icon,
          color: AppTheme.accentOrange,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.getOrbitronStyle(
          size: 16,
          weight: FontWeight.bold,
        ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Vandaag ${DateFormat('HH:mm').format(date)}';
    }
    if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Gisteren ${DateFormat('HH:mm').format(date)}';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

enum FileType { flashcards, summary }

class StudyFile {
  final String title;
  final FileType type;
  final DateTime lastOpened;
  final String thumbnailUrl;

  StudyFile({
    required this.title,
    required this.type,
    required this.lastOpened,
    required this.thumbnailUrl,
  });
}
