import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kittylogued/models/book_draft.dart';
import 'package:kittylogued/repositories/library_repository.dart';
import 'package:kittylogued/services/batch_queue_store.dart';
import 'package:kittylogued/services/cover_cache_service.dart';
import 'package:kittylogued/services/isbn_lookup_service.dart';
import 'package:kittylogued/utils/uuid.dart';

enum BatchLookupStatus { pending, found, notFound }

/// One scanned/typed ISBN waiting to be reviewed. All fields are editable.
class BatchItem extends ChangeNotifier {
  final String uid;
  final DateTime createdAt;

  String isbn;
  BatchLookupStatus status = BatchLookupStatus.pending;
  bool lookingUp = false;

  /// True while the lookup waits because there is no internet connection.
  bool waitingForNetwork = false;

  /// Set when the user asks for a fresh lookup (ignores the saved result).
  bool skipCache = false;

  /// Increases every time a lookup finishes, so the UI knows when to refill
  /// its text fields (and not overwrite what the user typed in between).
  int lookupVersion = 0;

  String title = '';
  String author = '';
  String publisher = '';
  String year = '';
  String pages = '';
  String? coverUrl;
  String? synopsis;
  String? contributors;

  bool include = true;
  bool inLibrary = false;

  BatchItem(this.isbn, {String? uid, DateTime? createdAt})
    : uid = uid ?? newUuid(),
      createdAt = createdAt ?? DateTime.now();

  bool get isValid => title.trim().isNotEmpty;

  /// The lookup could not run (no internet); keep the item queued.
  void markWaiting() {
    lookingUp = false;
    waitingForNetwork = true;
    notifyListeners();
  }

  void applyResult(BookLookupResult? result) {
    lookingUp = false;
    waitingForNetwork = false;
    if (result == null) {
      status = BatchLookupStatus.notFound;
    } else {
      status = BatchLookupStatus.found;
      title = result.title;
      author = result.author;
      publisher = result.publisher ?? '';
      year = result.publicationYear?.toString() ?? '';
      pages = result.pageCount?.toString() ?? '';
      coverUrl = result.coverUrl;
      synopsis = result.synopsis;
      contributors = result.secondaryContributors;
    }
    lookupVersion++;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'createdAt': createdAt.toIso8601String(),
    'isbn': isbn,
    'status': status.index,
    'title': title,
    'author': author,
    'publisher': publisher,
    'year': year,
    'pages': pages,
    'coverUrl': coverUrl,
    'synopsis': synopsis,
    'contributors': contributors,
    'include': include,
  };

  factory BatchItem.fromJson(Map<String, dynamic> m) {
    final item = BatchItem(
      m['isbn'] as String,
      uid: m['uid'] as String?,
      createdAt: DateTime.tryParse('${m['createdAt']}'),
    );
    final statusIndex = (m['status'] as int?) ?? 0;
    item.status = BatchLookupStatus
        .values[statusIndex.clamp(0, BatchLookupStatus.values.length - 1)];
    item.title = (m['title'] as String?) ?? '';
    item.author = (m['author'] as String?) ?? '';
    item.publisher = (m['publisher'] as String?) ?? '';
    item.year = (m['year'] as String?) ?? '';
    item.pages = (m['pages'] as String?) ?? '';
    item.coverUrl = m['coverUrl'] as String?;
    item.synopsis = m['synopsis'] as String?;
    item.contributors = m['contributors'] as String?;
    item.include = (m['include'] as bool?) ?? true;
    return item;
  }
}

/// Collects ISBNs and looks them up one after another in the background.
/// The queue is saved to the database, and lookups that fail because there
/// is no internet are retried automatically.
class BatchImportQueue extends ChangeNotifier {
  final IsbnLookupService _lookup;
  final BatchQueueStore? _store;
  final List<BatchItem> items = [];

  bool _working = false;
  Timer? _retryTimer;
  Timer? _saveTimer;
  final Set<BatchItem> _dirty = {};

  BatchImportQueue({IsbnLookupService? lookup, this._store})
    : _lookup = lookup ?? IsbnLookupService();

  int get pendingCount =>
      items.where((i) => i.status == BatchLookupStatus.pending).length;

  static String clean(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

  /// Loads the saved queue (call once at startup) and resumes lookups.
  Future<void> restore() async {
    final saved = await _store?.loadAll() ?? <BatchItem>[];
    for (final item in saved) {
      if (!items.any((i) => i.uid == item.uid)) items.add(item);
    }
    notifyListeners();
    _pump();
  }

  /// Saves an item shortly after it changed (edits are batched).
  void persist(BatchItem item) {
    if (_store == null) return;
    _dirty.add(item);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _flush);
  }

  Future<void> _flush() async {
    final toSave = _dirty.toList();
    _dirty.clear();
    for (final item in toSave) {
      if (items.contains(item)) await _store!.upsert(item);
    }
  }

  /// Adds an ISBN and starts looking it up. Returns false if it is not a
  /// valid ISBN length or was already added.
  bool add(String rawIsbn) {
    final isbn = clean(rawIsbn);
    if (isbn.length != 10 && isbn.length != 13) return false;
    if (items.any((i) => i.isbn == isbn)) return false;
    final item = BatchItem(isbn);
    items.add(item);
    persist(item);
    notifyListeners();
    _pump();
    return true;
  }

  void remove(BatchItem item) {
    items.remove(item);
    _store?.remove(item.uid);
    notifyListeners();
  }

  void clear() {
    items.clear();
    _store?.clear();
    notifyListeners();
  }

  /// Looks the item up again (e.g. after the user corrected the ISBN).
  void retry(BatchItem item) {
    final isbn = clean(item.isbn);
    if (isbn.length != 10 && isbn.length != 13) return;
    item.isbn = isbn;
    item.status = BatchLookupStatus.pending;
    item.lookingUp = false;
    item.skipCache = true;
    persist(item);
    notifyListeners();
    _pump();
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('openlibrary.org')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), _pump);
  }

  Future<void> _pump() async {
    if (_working) return;
    _working = true;
    try {
      while (true) {
        BatchItem? next;
        for (final i in items) {
          if (i.status == BatchLookupStatus.pending && !i.lookingUp) {
            next = i;
            break;
          }
        }
        if (next == null) break;

        next.lookingUp = true;
        final result = await _lookup.lookupByIsbn(
          next.isbn,
          useCache: !next.skipCache,
        );
        next.skipCache = false;

        // No result and no internet: keep the item queued and try again later.
        if (result == null && !await _hasInternet()) {
          next.markWaiting();
          notifyListeners();
          _scheduleRetry();
          break;
        }

        next.applyResult(result);
        persist(next);
        notifyListeners();
      }
    } finally {
      _working = false;
    }
  }

  /// Saves every included, valid item to the library. Returns how many.
  Future<int> commit({
    required LibraryRepository repository,
    required CoverCacheService coverCache,
    String? shelf,
    List<TagDraft> tags = const [],
  }) async {
    var added = 0;
    String? clean(String s) => s.trim().isEmpty ? null : s.trim();
    final shelfValue = clean(shelf ?? '');

    for (final item in items.where((i) => i.include && i.isValid).toList()) {
      final isbn = clean(item.isbn);
      if (isbn != null && await repository.findByIsbn(isbn) != null) {
        items.remove(item);
        await _store?.remove(item.uid);
        continue;
      }
      if (isbn != null && item.coverUrl != null && item.coverUrl!.isNotEmpty) {
        await coverCache.downloadAndCacheCover(
          rawIsbn: isbn,
          remoteUrl: item.coverUrl!,
        );
      }

      await repository.addBook(
        BookDraft(
          title: item.title.trim(),
          author: clean(item.author) ?? 'Unknown Author',
          isbn: isbn,
          publisher: clean(item.publisher),
          publicationYear: int.tryParse(item.year.trim()),
          pageCount: int.tryParse(item.pages.trim()),
          bindingType: 'paperback',
          secondaryContributors: item.contributors,
          coverUrl: item.coverUrl,
          synopsis: item.synopsis,
          shelfLocation: shelfValue,
          tags: tags,
        ),
      );

      items.remove(item);
      await _store?.remove(item.uid);
      added++;
    }
    notifyListeners();
    return added;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _saveTimer?.cancel();
    super.dispose();
  }
}
