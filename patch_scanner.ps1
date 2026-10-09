$path = Join-Path (Get-Location) 'lib\barcode_scanner_dialog.dart'
if (-not (Test-Path $path)) { $path = Get-ChildItem -Recurse -Filter barcode_scanner_dialog.dart | Select-Object -First 1 -ExpandProperty FullName }
Copy-Item $path "$path.bak" -Force

$code = @'
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  Timer? _scanTimer;
  bool _isProcessing = false;
  bool _hasDetected = false;
  bool _isInitializing = true;
  bool _unmirror = true;
  int _frameCount = 0;
  String? _errorMessage;
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  static bool _looksVirtualOrIr(CameraDescription c) {
    final n = c.name.toLowerCase();
    return n.contains(' ir') ||
        n.contains('infrared') ||
        n.contains('virtual') ||
        n.contains('obs') ||
        n.contains('snap') ||
        n.contains('hello');
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      final order = List<int>.generate(_cameras.length, (i) => i)
        ..sort((a, b) => (_looksVirtualOrIr(_cameras[a]) ? 1 : 0)
            .compareTo(_looksVirtualOrIr(_cameras[b]) ? 1 : 0));

      final errors = <String>[];
      for (final i in order) {
        debugPrint('Trying camera $i: ${_cameras[i].name}');
        final err = await _startCamera(i);
        if (err == null) {
          _selectedCameraIndex = i;
          return;
        }
        if (!mounted) return;
        errors.add('[$i] ${_cameras[i].name}\n  $err');
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage =
              'Could not start any camera.\n\n${errors.join('\n\n')}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera initialization failed: $e';
        });
      }
    }
  }

  Future<String?> _startCamera(int index) async {
    _scanTimer?.cancel();
    final old = _controller;
    if (mounted) setState(() => _controller = null);
    await old?.dispose();

    const presets = [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.veryHigh,
      ResolutionPreset.low,
    ];

    String lastErr = 'Unknown error';
    for (final preset in presets) {
      final candidate = CameraController(
        _cameras[index],
        preset,
        enableAudio: false,
      );

      try {
        await candidate.initialize();
        if (!mounted) {
          await candidate.dispose();
          return 'Widget unmounted';
        }
        _controller = candidate;
        setState(() {
          _isInitializing = false;
          _errorMessage = null;
        });
        _startScannerLoop();
        return null;
      } catch (e) {
        lastErr = '$preset: $e';
        debugPrint('Camera $index (${_cameras[index].name}) failed at $lastErr');
        await candidate.dispose();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    return lastErr;
  }

  void _startScannerLoop() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 650), (_) async {
      final cam = _controller;
      if (cam == null ||
          !cam.value.isInitialized ||
          _isProcessing ||
          _hasDetected ||
          !mounted) {
        return;
      }

      _isProcessing = true;
      try {
        final XFile file = await cam.takePicture();

        final Code result = await zx.readBarcodeImagePath(
          file,
          DecodeParams(format: Format.any, tryHarder: true, tryRotate: true),
        );

        _frameCount++;
        if (result.isValid && result.text != null && result.text!.isNotEmpty) {
          debugPrint('>>> SUCCESS: Found barcode: ${result.text}');
        } else {
          debugPrint('Frame $_frameCount: scanning (no barcode detected yet)');
        }

        try {
          final tempFile = File(file.path);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}

        if (_hasDetected || !mounted) return;

        if (result.isValid && result.text != null && result.text!.isNotEmpty) {
          final clean = result.text!
              .replaceAll(RegExp(r'[^0-9Xx]'), '')
              .toUpperCase();

          if (clean.length == 10 || clean.length == 13) {
            _hasDetected = true;
            _scanTimer?.cancel();
            Navigator.of(context).pop(clean);
          }
        }
      } catch (e) {
        debugPrint('Capture error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitializing = true);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    final err = await _startCamera(_selectedCameraIndex);
    if (err != null && mounted) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Camera ${_cameras[_selectedCameraIndex].name} failed.\n\n$err';
      });
    }
  }

  void _submitManual() {
    final clean =
        _manualController.text.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (clean.length == 10 || clean.length == 13) {
      _hasDetected = true;
      _scanTimer?.cancel();
      Navigator.of(context).pop(clean);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ISBN must be 10 or 13 characters.')),
      );
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _controller?.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final screen = MediaQuery.of(context).size;
    final dialogWidth = math.min(520.0, screen.width - 40);
    final dialogHeight = math.min(480.0, screen.height - 48);

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Consolas',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _initCamera,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _manualController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Or type the ISBN manually',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.deepPurpleAccent),
                            ),
                          ),
                          onSubmitted: (_) => _submitManual(),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _submitManual,
                          child: const Text('Use this ISBN'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isInitializing)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                  ),
                )
              else if (_controller != null && _controller!.value.isInitialized)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: isMobile
                          ? (_controller!.value.previewSize?.height ?? 520)
                          : (_controller!.value.previewSize?.width ?? 520),
                      height: isMobile
                          ? (_controller!.value.previewSize?.width ?? 480)
                          : (_controller!.value.previewSize?.height ?? 480),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(_unmirror ? math.pi : 0),
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),

              if (_errorMessage == null && !_isInitializing)
                IgnorePointer(
                  child: Container(
                    width: 280,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.deepPurpleAccent,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _unmirror ? Icons.flip : Icons.flip_camera_android,
                        color: Colors.white,
                      ),
                      tooltip: 'Toggle Mirror Preview',
                      onPressed: () => setState(() => _unmirror = !_unmirror),
                    ),
                    if (_cameras.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                        ),
                        tooltip: 'Switch Camera',
                        onPressed: _switchCamera,
                      ),
                  ],
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ),

              if (_errorMessage == null && !_isInitializing)
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hold book ~30 cm away for sharp focus',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
'@

[System.IO.File]::WriteAllText($path, $code, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Patched: $path (backup: $path.bak)"