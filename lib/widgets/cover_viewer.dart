import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kittylogued/services/cover_cache_service.dart';

/// Shows a book cover enlarged. Pinch to zoom, tap anywhere to close.
Future<void> showCoverViewer(
  BuildContext context, {
  required String title,
  required String? isbn,
  required String? coverUrl,
  required CoverCacheService cacheService,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => _CoverViewer(
      title: title,
      isbn: isbn,
      coverUrl: coverUrl,
      cacheService: cacheService,
    ),
  );
}

class _CoverViewer extends StatefulWidget {
  final String title;
  final String? isbn;
  final String? coverUrl;
  final CoverCacheService cacheService;

  const _CoverViewer({
    required this.title,
    required this.isbn,
    required this.coverUrl,
    required this.cacheService,
  });

  @override
  State<_CoverViewer> createState() => _CoverViewerState();
}

class _CoverViewerState extends State<_CoverViewer> {
  File? _file;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final isbn = widget.isbn;
    if (isbn == null || isbn.isEmpty) return;
    final file = await widget.cacheService.getCachedCover(isbn);
    if (mounted && file != null) setState(() => _file = file);
  }

  Widget _placeholder() => const Icon(Icons.book, size: 96, color: Colors.grey);

  Widget _image() {
    if (_file != null) {
      return Image.file(
        _file!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final url = widget.coverUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
      );
    }
    return _placeholder();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: _image(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
