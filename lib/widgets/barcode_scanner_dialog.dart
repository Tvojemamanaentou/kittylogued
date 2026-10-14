import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

/// Scans ISBN barcodes from the live camera image using ZXing.
///
/// Frames are decoded straight from the camera stream (no photos are taken),
/// which is much faster than capture-and-decode.
///
/// - Normal mode: pops with the ISBN as soon as one is read.
/// - Batch mode ([onBatchIsbn] set): keeps scanning and reports every ISBN to
///   the callback (it returns true when the ISBN was new). Close the dialog
///   when you are done.
class BarcodeScannerDialog extends StatefulWidget {
  final bool Function(String isbn)? onBatchIsbn;

  const BarcodeScannerDialog({super.key, this.onBatchIsbn});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  final TextEditingController _manual = TextEditingController();

  bool _done = false; // single mode: stop after the first hit
  DateTime _lastHit = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastIsbn;
  int _batchCount = 0;
  String? _error;

  bool get _batch => widget.onBatchIsbn != null;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  /// 10 or 13 digits (ISBN-10 may end in X); anything else is not a book.
  static String? _isbnFrom(String? raw) {
    if (raw == null) return null;
    final clean = raw.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (clean.length == 13 || clean.length == 10) return clean;
    return null;
  }

  void _handleIsbn(String isbn) {
    final now = DateTime.now();

    if (_batch) {
      // Ignore the same barcode being read again while it is still in view.
      if (isbn == _lastIsbn &&
          now.difference(_lastHit) < const Duration(seconds: 3)) {
        return;
      }
      _lastHit = now;
      _lastIsbn = isbn;
      final added = widget.onBatchIsbn!(isbn);
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          if (added) _batchCount++;
        });
      }
      return;
    }

    if (_done) return;
    _done = true;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(isbn);
  }

  void _onScan(Code result) {
    if (!result.isValid) return;
    final isbn = _isbnFrom(result.text);
    if (isbn != null) _handleIsbn(isbn);
  }

  void _submitManual() {
    final isbn = _isbnFrom(_manual.text);
    if (isbn == null) {
      setState(() => _error = 'ISBN must be 10 or 13 characters.');
      return;
    }
    setState(() => _error = null);
    _manual.clear();
    _handleIsbn(isbn);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ReaderWidget(
                    onScan: _onScan,
                    // Book barcodes are EAN-13 (older ones EAN-8).
                    codeFormat: Format.ean13 | Format.ean8,
                    // Medium resolution is plenty and keeps frames fast.
                    resolution: ResolutionPreset.medium,
                    cropPercent: 0.8,
                    scanDelay: const Duration(milliseconds: 120),
                    scanDelaySuccess: const Duration(milliseconds: 400),
                    tryHarder: false,
                    tryRotate: true,
                    showFlashlight: true,
                    showToggleCamera: true,
                    showGallery: false,
                  ),
                  if (_batch)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _lastIsbn == null
                              ? 'Batch: 0 scanned - close when finished'
                              : 'Batch: $_batchCount scanned (last $_lastIsbn)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Hold the barcode inside the frame',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manual,
                      decoration: InputDecoration(
                        labelText: 'Or type the ISBN',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _submitManual(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submitManual,
                    child: Text(_batch ? 'Add' : 'Use'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
