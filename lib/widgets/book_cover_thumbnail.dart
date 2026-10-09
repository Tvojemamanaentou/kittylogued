import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kittylogued/services/cover_cache_service.dart';

class BookCoverThumbnail extends StatefulWidget {
  final String? isbn;
  final String? coverUrl;
  final CoverCacheService cacheService;

  const BookCoverThumbnail({
    super.key,
    required this.isbn,
    required this.coverUrl,
    required this.cacheService,
  });

  @override
  State<BookCoverThumbnail> createState() => _BookCoverThumbnailState();
}

class _BookCoverThumbnailState extends State<BookCoverThumbnail> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _resolveCover();
  }

  @override
  void didUpdateWidget(covariant BookCoverThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isbn != widget.isbn ||
        oldWidget.coverUrl != widget.coverUrl) {
      _resolveCover();
    }
  }

  Future<void> _resolveCover() async {
    final rawIsbn = widget.isbn;
    if (rawIsbn == null || rawIsbn.isEmpty) {
      if (mounted) setState(() => _cachedFile = null);
      return;
    }

    final file = await widget.cacheService.getCachedCover(rawIsbn);
    if (!mounted) return;

    if (file != null) {
      setState(() => _cachedFile = file);
      return;
    }

    final remote = widget.coverUrl;
    if (remote != null && remote.isNotEmpty) {
      final downloaded = await widget.cacheService.downloadAndCacheCover(
        rawIsbn: rawIsbn,
        remoteUrl: remote,
      );
      if (mounted && downloaded != null) {
        setState(() => _cachedFile = downloaded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 64,
          child: Image.file(
            _cachedFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        ),
      );
    }

    if (widget.coverUrl != null && widget.coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 44,
          height: 64,
          child: Image.network(
            widget.coverUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.white10,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.book, size: 24, color: Colors.grey),
    );
  }
}
