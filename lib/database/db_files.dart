import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File-level helpers for the database: where it lives, snapshots taken
/// before an upgrade, and applying a restore that was scheduled earlier.
/// They work on the files only, so they can run before the database opens.

Future<Directory> _docsDir() => getApplicationDocumentsDirectory();

Future<File> databaseFile() async =>
    File(p.join((await _docsDir()).path, 'kittylogued.sqlite'));

Future<File> _schemaFile() async =>
    File(p.join((await _docsDir()).path, 'kittylogued.schema'));

Future<Directory> backupsDirectory() async {
  final dir = Directory(p.join((await _docsDir()).path, 'backups'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

String backupStamp(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}${two(d.month)}${two(d.day)}-'
      '${two(d.hour)}${two(d.minute)}${two(d.second)}';
}

/// How many snapshots of each kind are kept.
const Map<String, int> backupKeep = {
  'weekly-': 4,
  'pre-upgrade-': 3,
  'manual-': 5,
  'before-restore-': 2,
};

Future<void> trimBackups() async {
  final dir = await backupsDirectory();
  final files = await dir
      .list()
      .where((e) => e is File && e.path.endsWith('.sqlite'))
      .cast<File>()
      .toList();
  for (final entry in backupKeep.entries) {
    final ofKind =
        files.where((f) => p.basename(f.path).startsWith(entry.key)).toList()
          ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    for (final old in ofKind.skip(entry.value)) {
      try {
        await old.delete();
      } catch (_) {}
    }
  }
}

/// Copies the database to the backups folder when the app is about to
/// upgrade it to a newer schema. Call before the database is opened.
Future<void> snapshotBeforeUpgrade(int currentVersion) async {
  final db = await databaseFile();
  if (!await db.exists()) return;

  final schema = await _schemaFile();
  int? stored;
  if (await schema.exists()) {
    stored = int.tryParse((await schema.readAsString()).trim());
  }
  if (stored != null && stored >= currentVersion) return;

  final dir = await backupsDirectory();
  final name =
      'pre-upgrade-v${stored ?? 'old'}-to-v$currentVersion-${backupStamp(DateTime.now())}.sqlite';
  await db.copy(p.join(dir.path, name));
  await trimBackups();
}

Future<void> markSchemaVersion(int version) async {
  await (await _schemaFile()).writeAsString('$version');
}

/// If a restore was scheduled, swaps the database file now. Must run before
/// the database is opened (i.e. at the start of main).
Future<void> applyPendingRestore() async {
  final db = await databaseFile();
  final pending = File('${db.path}.restore');
  if (!await pending.exists()) return;

  final dir = await backupsDirectory();
  if (await db.exists()) {
    await db.copy(
      p.join(dir.path, 'before-restore-${backupStamp(DateTime.now())}.sqlite'),
    );
  }
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File('${db.path}$suffix');
    if (await f.exists()) await f.delete();
  }
  await pending.rename(db.path);
  final schema = await _schemaFile();
  if (await schema.exists()) await schema.delete();
  await trimBackups();
}
