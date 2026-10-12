import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/services/app_settings.dart';
import 'package:kittylogued/services/backup_service.dart';
import 'package:kittylogued/theme/app_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final AppSettings settings = services.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) {
              final scheme = Theme.of(context).colorScheme;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Colour',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final palette in AppThemes.palettes)
                        _PaletteSwatch(
                          palette: palette,
                          selected: settings.paletteId == palette.id,
                          onTap: () => settings.setPalette(palette.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(Icons.contrast, color: scheme.primary),
                    title: const Text('High contrast'),
                    subtitle: const Text(
                      'Stronger colours and pure black/white background for visibility',
                    ),
                    value: settings.highContrast,
                    onChanged: settings.setHighContrast,
                  ),
                  const Divider(height: 32),
                  _BackupsSection(backup: services.backup),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Back up now, see the snapshots and schedule a restore.
class _BackupsSection extends StatefulWidget {
  final BackupService backup;

  const _BackupsSection({required this.backup});

  @override
  State<_BackupsSection> createState() => _BackupsSectionState();
}

class _BackupsSectionState extends State<_BackupsSection> {
  late Future<List<BackupInfo>> _future;
  bool _restorePending = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = widget.backup.list();
    widget.backup.hasPendingRestore().then((pending) {
      if (mounted) setState(() => _restorePending = pending);
    });
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  static String _fmtSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _backupNow() async {
    setState(() => _busy = true);
    await widget.backup.createSnapshot(kind: 'manual');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _reload();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup created')),
    );
  }

  Future<void> _restore(BackupInfo info) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: Text(
          'Your library will be replaced by the backup from ${_fmtDate(info.modified)} '
          'the next time the app starts. Your current library is saved as a '
          '"before restore" backup first, so you can go back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.backup.scheduleRestore(info);
    if (!mounted) return;
    setState(_reload);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore scheduled. Close and reopen the app to finish.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Backups', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text(
          'A copy of your library is kept every week and before every app update.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: _busy ? null : _backupNow,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.backup_outlined),
            label: const Text('Back up now'),
          ),
        ),
        if (_restorePending)
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('A restore is scheduled'),
              subtitle: const Text('Close and reopen the app to finish it.'),
              trailing: TextButton(
                onPressed: () async {
                  await widget.backup.cancelPendingRestore();
                  if (mounted) setState(_reload);
                },
                child: const Text('Cancel'),
              ),
            ),
          ),
        const SizedBox(height: 8),
        FutureBuilder<List<BackupInfo>>(
          future: _future,
          builder: (context, snapshot) {
            final backups = snapshot.data ?? const <BackupInfo>[];
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (backups.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No backups yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return Column(
              children: [
                for (final b in backups)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history),
                    title: Text(b.kindLabel),
                    subtitle: Text('${_fmtDate(b.modified)} • ${_fmtSize(b.size)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_backup_restore),
                          tooltip: 'Restore',
                          onPressed: () => _restore(b),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete backup',
                          onPressed: () async {
                            await widget.backup.delete(b);
                            if (mounted) setState(_reload);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteSwatch({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show how the palette looks in the brightness currently in use.
    final brightness = Theme.of(context).brightness;
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
    );
    return Tooltip(
      message: palette.name,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.secondaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? Icon(Icons.check, color: scheme.onPrimary)
              : null,
        ),
      ),
    );
  }
}
