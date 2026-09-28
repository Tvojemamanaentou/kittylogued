import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service responsible for downloading and caching book cover images on local disk.
class CoverCacheService {
  final http.Client _client;
  final Directory? baseDirectory;

  CoverCacheService({http.Client? client, this.baseDirectory})
    : _client = client ?? http.Client();

  /// Returns the directory where covers are stored, creating it if necessary.
  Future _getCoversDirectory() async {
    final baseDir = baseDirectory ?? await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(baseDir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  /// Sanitizes an ISBN by stripping hyphens and non-alphanumeric characters.
  String sanitizeIsbn(String rawIsbn) {
    return rawIsbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
  }

  /// Returns the target [File] path for a given ISBN.
  Future getCoverFile(String rawIsbn) async {
    final cleanIsbn = sanitizeIsbn(rawIsbn);
    final coversDir = await _getCoversDirectory();
    return File(p.join(coversDir.path, '$cleanIsbn.jpg'));
  }

  /// Checks if a cover image is already cached on disk for [rawIsbn].
  ///
  /// Returns the [File] if it exists and is non-empty, otherwise `null`.
  Future getCachedCover(String rawIsbn) async {
    final cleanIsbn = sanitizeIsbn(rawIsbn);
    if (cleanIsbn.isEmpty) {
      return null;
    }
    final file = await getCoverFile(cleanIsbn);
    if (await file.exists() && (await file.length()) > 0) {
      return file;
    }
    return null;
  }

  /// Downloads cover artwork from [remoteUrl] and saves it locally as [rawIsbn].jpg.
  ///
  /// Returns the cached [File] on success, or `null` if the download or write fails.
  Future downloadAndCacheCover({
    required String rawIsbn,
    required String remoteUrl,
  }) async {
    final cleanIsbn = sanitizeIsbn(rawIsbn);
    if (cleanIsbn.isEmpty || remoteUrl.isEmpty) {
      return null;
    }

    try {
      final response = await _client
          .get(
            Uri.parse(remoteUrl),
            headers: {
              'Accept': 'image/jpeg,image/png,image/*;q=0.9,*/*;q=0.8',
              'User-Agent': 'KittyloguedApp/1.0 (https://github.com/Tvojemamanaentou/kittylogued)',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }

      final file = await getCoverFile(cleanIsbn);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (_) {
      return null;
    }
  }
}
