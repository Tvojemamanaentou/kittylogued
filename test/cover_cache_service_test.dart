import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kittylogued/services/cover_cache_service.dart';

void main() {
  late Directory tempDir;
  late CoverCacheService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('kittylogued_test_covers_');
    service = CoverCacheService(baseDirectory: tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('CoverCacheService downloads artwork, writes to disk, and retrieves from cache', () async {
    const rawIsbn = '978-80-277-1368-4';
    const remoteUrl = 'https://www.knihovny.cz/Cover/Show?isbn=9788027713684&size=medium';

    // 1. Initial state: cache must be empty
    final beforeDownload = await service.getCachedCover(rawIsbn);
    expect(beforeDownload, isNull);

    // 2. Download and cache
    final downloadedFile = await service.downloadAndCacheCover(
      rawIsbn: rawIsbn,
      remoteUrl: remoteUrl,
    );

    expect(downloadedFile, isNotNull);
    expect(await downloadedFile!.exists(), isTrue);
    expect(await downloadedFile.length(), greaterThan(0));
    expect(downloadedFile.path.endsWith('9788027713684.jpg'), isTrue);

    // 3. Retrieve from cache without downloading again
    final cachedFile = await service.getCachedCover(rawIsbn);
    expect(cachedFile, isNotNull);
    expect(cachedFile!.path, equals(downloadedFile.path));
  });

  test('CoverCacheService handles empty or invalid inputs gracefully', () async {
    final emptyResult = await service.downloadAndCacheCover(
      rawIsbn: '',
      remoteUrl: '',
    );
    expect(emptyResult, isNull);

    final noCachedCover = await service.getCachedCover('');
    expect(noCachedCover, isNull);
  });
}
