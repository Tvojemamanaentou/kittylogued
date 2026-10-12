import 'dart:io';

import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/database/db_files.dart';
import 'package:path/path.dart' as p;

class BackupInfo {
  final File file;
  final String name;

  /// weekly, manual, pre-upgrade or before-restore.
  final String kind;
  final DateTime modified;
  final int size;

  const BackupInfo({
    required this.file,
    required this.name,
    required this.kind,
    required this.modified,
    required this.size,
  });

  String get kindLabel {
    switch (kind) {
      case 'weekly':
        return 'Automatic (weekly)';
      case 'pre-upgrade':
        return 'Before an update';
      case 'before-restore':
        return 'Before a restore';
      default:
        return 'Manual';
    }
  }
}

/// Snapshots of the library database: weekly automatic ones, one before
/// every schema upgrade, and manual ones. Restoring is scheduled and
/// finished the next time the app starts (the open database cannot be
/// replaced while the app is running).
class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  static String _kindOf(String fileName) {
    for (final kind in ['weekly', 'pre-upgrade', 'before-restore', 'manual']) {
      if (fileName.startsWith('$kind-')) return kind;
    }
    return 'manual';
  }

  Future<File> createSnapshot({String kind = 'manual'}) async {
    final dir = await backupsDirectory();
    final path = p.join(dir.path, '$kind-${backupStamp(DateTime.now())}.sqlite');
    try {
      await db.vacuumInto(path);
    } catch (_) {
      // Fall back to copying the file.
      final source = await databaseFile();
      await source.copy(path);
    }
    await trimBackups();
    return File(path);
  }

  /// Takes a weekly snapshot when the newest one is older than [every].
  Future<void> snapshotIfDue({Duration every = const Duration(days: 7)}) async {
    final all = await list();
    final newest = all.isEmpty
        ? null
        : all.map((b) => b.modified).reduce((a, b) => a.isAfter(b) ? a : b);
    if (newest == null || DateTime.now().difference(newest) > every) {
      await createSnapshot(kind: 'weekly');
    }
  }

  Future<List<BackupInfo>> list() async {
    final dir = await backupsDirectory();
    final result = <BackupInfo>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.sqlite')) continue;
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      result.add(
        BackupInfo(
          file: entity,
          name: name,
          kind: _kindOf(name),
          modified: stat.modified,
          size: stat.size,
        ),
      );
    }
    result.sort((a, b) => b.modified.compareTo(a.modified));
    return result;
  }

  Future<void> delete(BackupInfo info) async {
    if (await info.file.exists()) await info.file.delete();
  }

  /// Schedules a restore; it is applied when the app starts next.
  Future<void> scheduleRestore(BackupInfo info) async {
    final db = await databaseFile();
    await info.file.copy('${db.path}.restore');
  }

  Future<bool> hasPendingRestore() async {
    final db = await databaseFile();
    return File('${db.path}.restore').exists();
  }

  Future<void> cancelPendingRestore() async {
    final db = await databaseFile();
    final f = File('${db.path}.restore');
    if (await f.exists()) await f.delete();
  }
}
