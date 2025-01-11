import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/constants/routes.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/local/local_service.dart';
import 'package:studieapp/views/main/learning/local/summary/summary_view.dart';
import 'package:studieapp/views/main/learning/local/wordlist/wordlist_view.dart';

class LearningView extends StatefulWidget {
  const LearningView({super.key});

  @override
  State<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends State<LearningView> {
  late final LocalService _localService;
  List<File> recentFiles = [];

  @override
  void initState() {
    super.initState();
    _localService = LocalService();
    _loadRecentFiles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentFiles(theme),
            const SizedBox(height: 24),
            _buildCreateSection(theme),
            const SizedBox(height: 24),
            _buildOnlineSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFiles(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent geopend',
              style: theme.textTheme.displayLarge,
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
        recentFiles.isEmpty
            ? Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 64,
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Geen recente bestanden',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bestanden die je opent, verschijnen hier',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentFiles.length,
                  itemBuilder: (context, index) {
                    return _buildRecentFileCard(recentFiles[index], theme);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildRecentFileCard(File file, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () async {
          if (file.type == 'wordlist') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WordListView(file: file)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SummaryView(file: file)),
            );
          }
        },
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                file.type == 'wordlist'
                    ? Icons.style_outlined
                    : Icons.description_outlined,
                size: 32,
                color: colorScheme.secondary,
              ),
              const Spacer(),
              Text(
                file.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Laatst geopend: ${_formatDate(file.lastOpened)}',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nieuw bestand maken',
          style: theme.textTheme.displayLarge,
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
                theme: theme,
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
                theme: theme,
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
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
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
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Bibliotheek',
          style: theme.textTheme.displayLarge,
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
                  Navigator.of(context).pushNamed(searchFilesRoute);
                },
                theme: theme,
              ),
              const Divider(height: 1),
              _buildOnlineOption(
                title: 'Deel je bestanden',
                subtitle: 'Help anderen door je materiaal te delen',
                icon: Icons.upload_file,
                onTap: () {
                  Navigator.of(context).pushNamed(publishFileListRoute);
                },
                theme: theme,
              ),
              const Divider(height: 1),
              _buildOnlineOption(
                title: 'Jouw gedeelde content',
                subtitle: 'Bekijk en beheer je gedeelde bestanden',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.of(context).pushNamed(publishedFileListRoute);
                },
                theme: theme,
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
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondary.withOpacity(0.1),
        child: Icon(
          icon,
          color: colorScheme.secondary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.textTheme.bodyMedium?.color,
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

  Future<void> _loadRecentFiles() async {
    final allFiles = await _localService.getAllFiles();
    final sortedFiles = allFiles.toList()
      ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

    if (mounted) {
      setState(() {
        recentFiles = sortedFiles.take(5).toList();
      });
    }
  }
}
