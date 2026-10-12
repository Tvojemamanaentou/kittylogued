import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:kittylogued/database/app_database.dart';
import 'package:kittylogued/services/batch_import_queue.dart';

/// Keeps the batch queue in the database so it survives closing the app.
class BatchQueueStore {
  final AppDatabase db;

  BatchQueueStore(this.db);

  Future<List<BatchItem>> loadAll() async {
    final rows = await (db.select(db.batchQueueEntries)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
        .get();
    final items = <BatchItem>[];
    for (final row in rows) {
      try {
        items.add(
          BatchItem.fromJson(jsonDecode(row.payload) as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip an unreadable row.
      }
    }
    return items;
  }

  Future<void> upsert(BatchItem item) async {
    await db
        .into(db.batchQueueEntries)
        .insertOnConflictUpdate(
          BatchQueueEntriesCompanion.insert(
            uid: item.uid,
            payload: jsonEncode(item.toJson()),
            createdAt: item.createdAt,
          ),
        );
  }

  Future<void> remove(String uid) async {
    await (db.delete(db.batchQueueEntries)..where((t) => t.uid.equals(uid)))
        .go();
  }

  Future<void> clear() async {
    await db.delete(db.batchQueueEntries).go();
  }
}
