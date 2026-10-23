import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/pages/recently_deleted_page.dart';
import 'package:kittylogued/pages/settings_page.dart';
import 'package:kittylogued/pages/sign_in_page.dart';
import 'package:kittylogued/services/app_settings.dart';
import 'package:kittylogued/utils/library_stats.dart';
import 'package:kittylogued/utils/reading_insights.dart';
import 'package:kittylogued/widgets/reading_insights_section.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  void _openSignIn(BuildContext context, AppServices s) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SignInPage(auth: s.auth)),
    );
  }

  Future<void> _showAvatarOptions(BuildContext context, AppSettings settings) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await settings.changeAvatar();
              },
            ),
            if (settings.avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  settings.removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editGoal(BuildContext context, AppSettings settings) async {
    final controller = TextEditingController(
      text: settings.yearlyGoal > 0 ? '${settings.yearlyGoal}' : '',
    );
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yearly reading goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Books to finish this year',
            helperText: 'Leave empty or 0 for no goal',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              int.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await settings.setYearlyGoal(value);
  }

  /// Editing a username is intentionally split into a small, explicit flow so the
  /// validation and availability checks remain easy to follow and safe to modify.
  Future<void> _editUsername(BuildContext context, AppSettings settings) async {
    final controller = TextEditingController(text: settings.username ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? error;
        bool checking = false;

        return StatefulBuilder(
          builder: (stateContext, setLocalState) {
            Future<void> handleSave() async {
              final value = controller.text.trim();
              final localError = AppSettings.validateUsername(value);
              if (localError != null) {
                setLocalState(() => error = localError);
                return;
              }

              final check = settings.usernameAvailabilityCheck;
              if (check != null) {
                setLocalState(() {
                  checking = true;
                  error = null;
                });

                final remoteError = await check(value);
                setLocalState(() {
                  checking = false;
                  error = remoteError;
                });
                if (remoteError != null) {
                  return;
                }
              }

              await settings.setUsername(value);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              title: const Text('Username'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Username',
                  helperText: 'Uniqueness will be checked online later.',
                  border: const OutlineInputBorder(),
                  errorText: error,
                ),
                onSubmitted: (_) => handleSave(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: checking ? null : handleSave,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Widget _profileHeader(BuildContext context, AppServices s) {
    final settings = s.settings;
    final signedIn = s.auth.isSignedIn;
    final path = settings.avatarPath;
    final scheme = Theme.of(context).colorScheme;

    final avatar = CircleAvatar(
      radius: 60,
      backgroundColor: scheme.surfaceContainerHighest,
      backgroundImage: path != null ? FileImage(File(path)) : null,
      child: path == null
          ? Icon(Icons.person, size: 64, color: scheme.onSurfaceVariant)
          : null,
    );

    return Column(
      children: [
        // Changing the picture is only possible when signed in.
        signedIn
            ? GestureDetector(
                onTap: () => _showAvatarOptions(context, settings),
                child: Stack(
                  children: [
                    avatar,
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : avatar,
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                settings.username ?? (signedIn ? 'Choose a username' : 'Guest'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: settings.username == null ? Colors.grey : null,
                ),
              ),
            ),
            if (signedIn)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit username',
                onPressed: () => _editUsername(context, settings),
              ),
          ],
        ),
        if (signedIn && s.auth.user?.email != null)
          Text(
            s.auth.user!.email!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Account'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([s.settings, s.auth]),
            builder: (context, _) {
              return Column(
                children: [
                  _profileHeader(context, s),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsPage(),
                        ),
                      ),
                    ),
                  ),
                  // The recycle bin sits right under Settings.
                  StreamBuilder<List<Book>>(
                    stream: s.database.watchDeletedBooks(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Recently deleted'),
                          subtitle: Text(
                            count == 0
                                ? 'The bin is empty'
                                : '$count book(s) - removed for good after 30 days',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RecentlyDeletedPage(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (s.auth.isSignedIn)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign out'),
                        onTap: s.auth.signOut,
                      ),
                    )
                  else
                    // Greyed-out: profile details cannot be changed until signed in.
                    Opacity(
                      opacity: 0.5,
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('Sign in to change profile details'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openSignIn(context, s),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Library overview',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Book>>(
            stream: s.database.watchLiveBooks(),
            builder: (context, booksSnapshot) {
              return StreamBuilder<List<ReadingLog>>(
                stream: s.database.watchAllReadingLogs(),
                builder: (context, logsSnapshot) {
                  final stats = LibraryStats.compute(
                    booksSnapshot.data ?? const <Book>[],
                    logsSnapshot.data ?? const <ReadingLog>[],
                    DateTime.now(),
                  );
                  return _StatsSection(stats: stats);
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Reading insights',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Book>>(
            stream: s.database.watchLiveBooks(),
            builder: (context, booksSnapshot) {
              return StreamBuilder<List<ReadingLog>>(
                stream: s.database.watchAllReadingLogs(),
                builder: (context, logsSnapshot) {
                  final insights = ReadingInsights.compute(
                    booksSnapshot.data ?? const <Book>[],
                    logsSnapshot.data ?? const <ReadingLog>[],
                    DateTime.now(),
                  );
                  return ListenableBuilder(
                    listenable: s.settings,
                    builder: (context, _) => ReadingInsightsSection(
                      insights: insights,
                      goal: s.settings.yearlyGoal,
                      onEditGoal: () => _editGoal(context, s.settings),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final LibraryStats stats;

  const _StatsSection({required this.stats});

  Widget _tile(BuildContext context, String label, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _row(String label, List<String> cells, {bool header = false}) {
    final style = header
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
        : null;
    Widget cell(String text, {TextAlign align = TextAlign.end}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(text, textAlign: align, style: style),
    );
    return TableRow(
      children: [
        cell(label, align: TextAlign.start),
        for (final c in cells) cell(c),
      ],
    );
  }

  List<String> _cells(PeriodStats s) => [
    '${s.books}',
    '${s.pages}',
    '${s.pagesLogged}',
  ];

  @override
  Widget build(BuildContext context) {
    final speed = stats.pagesPerDay;
    final perBook = stats.daysPerBook;
    final avg = stats.averageRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _tile(context, 'In library', '${stats.total}', Icons.menu_book),
            _tile(context, 'Finished', '${stats.read}', Icons.check_circle_outline),
          ],
        ),
        Row(
          children: [
            _tile(context, 'Reading', '${stats.reading}', Icons.auto_stories),
            _tile(context, 'To read', '${stats.unread}', Icons.bookmark_border),
          ],
        ),
        Row(
          children: [
            _tile(
              context,
              'Average rating',
              avg == null ? '-' : avg.toStringAsFixed(1),
              Icons.star_outline,
            ),
            _tile(context, 'Rated books', '${stats.ratedCount}', Icons.star_half),
          ],
        ),
        const SizedBox(height: 8),
        Text('Reading progress', style: Theme.of(context).textTheme.titleSmall),
        Card(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
            },
            children: [
              _row('', ['Books', 'Book pages', 'Pages read'], header: true),
              _row('This week', _cells(stats.week)),
              _row('This month', _cells(stats.month)),
              _row('This year', _cells(stats.year)),
              _row('Overall', _cells(stats.overall)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            'Books = finished in the period. Pages read = pages from your dated progress entries.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text('Reading speed', style: Theme.of(context).textTheme.titleSmall),
        Card(
          child: ListTile(
            leading: const Icon(Icons.speed),
            title: Text(
              speed == null
                  ? 'Not enough data yet'
                  : '${speed.toStringAsFixed(1)} pages / day',
            ),
            subtitle: Text(
              perBook == null
                  ? 'Mark books as started and finished (with a page count) to see your speed.'
                  : 'About ${perBook.toStringAsFixed(1)} days per book',
            ),
          ),
        ),
      ],
    );
  }
}
