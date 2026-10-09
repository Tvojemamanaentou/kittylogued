// Import asynchronous programming tools (e.g., Future, Timer).
import 'dart:async';
// Import file system I/O capabilities for reading and writing files.
import 'dart:io';
// Import Isolate support to execute heavy computations on a background thread.
import 'dart:isolate';
// Import math utilities (min, max, pi, etc.) under the alias 'math'.
import 'dart:math' as math;

// Import Flutter's camera plugin to interface with device cameras.
import 'package:camera/camera.dart';
// Import Flutter foundation utilities for platform detection and debug logging.
import 'package:flutter/foundation.dart';
// Import Flutter Material Design UI widgets and styling components.
import 'package:flutter/material.dart';
// Import the ZXing barcode decoding library for scanning barcode images.
import 'package:flutter_zxing/flutter_zxing.dart';
// Import the image manipulation package under the alias 'img'.
import 'package:image/image.dart' as img;

/// Work order for the background crop (kept simple so it can cross isolates).
// Define a data-transfer class holding all parameters needed for the image crop isolate.
class _CropJob {
  // File system path of the raw captured image.
  final String srcPath;
  // Destination path where the cropped JPEG should be written.
  final String outPath;
  // Desired crop width expressed as a fraction (0.0 - 1.0) of original image width.
  final double wFrac;
  // Desired crop height expressed as a fraction (0.0 - 1.0) of original image height.
  final double hFrac;
  // Whether to horizontally flip (mirror) the cropped image.
  final bool flip;
  // Ideal pixel width to upscale smaller images toward for better scanning accuracy.
  final int targetWidth;

  // Constant constructor requiring all job parameters.
  const _CropJob({
    required this.srcPath,
    required this.outPath,
    required this.wFrac,
    required this.hFrac,
    required this.flip,
    required this.targetWidth,
  });
}

/// Crops the centre of the photo, optionally mirrors and upscales it,
/// converts to grayscale and writes a JPEG. Returns the output path or null.
// Top-level worker function to crop, scale, and format an image within a background isolate.
Future _prepareCrop(_CropJob job) async {
  try {
    // Read the raw binary data of the source photo from disk.
    final bytes = await File(job.srcPath).readAsBytes();
    // Decode the raw bytes into a mutable Image object in memory.
    var image = img.decodeImage(bytes);
    // If the image fails to decode, exit early and return null.
    if (image == null) return null;
    // Rotate pixel data according to EXIF orientation so width and height are true.
    image = img.bakeOrientation(image);

    // Compute crop width, bounded between a minimum of 64px and the source width.
    final cw = math.max(
      64,
      math.min(image.width, (image.width * job.wFrac).round()),
    );
    // Compute crop height, bounded between a minimum of 64px and the source height.
    final ch = math.max(
      64,
      math.min(image.height, (image.height * job.hFrac).round()),
    );
    // Calculate the horizontal start coordinate (X) to center the crop box.
    final x = ((image.width - cw) / 2).round();
    // Calculate the vertical start coordinate (Y) to center the crop box.
    final y = ((image.height - ch) / 2).round();

    // Extract the cropped rectangular area from the source image.
    var out = img.copyCrop(image, x: x, y: y, width: cw, height: ch);
    // Check if horizontal flipping was requested for this job.
    if (job.flip) {
      // Mirror the image horizontally.
      out = img.flipHorizontal(out);
    }

    // Determine the scaling factor to hit targetWidth, capped at 3x maximum upscale.
    final scale = math.min(3.0, job.targetWidth / cw);
    // Upscale only if the image would be enlarged by more than 5%.
    if (scale > 1.05) {
      // Resize using cubic interpolation for sharp text and edge preservation.
      out = img.copyResize(
        out,
        width: (out.width * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    // Convert image to single-channel grayscale to boost barcode detection contrast.
    out = img.grayscale(out);
    // Encode the processed image as a high-quality JPEG (95%) and write it to disk.
    await File(job.outPath).writeAsBytes(img.encodeJpg(out, quality: 95));
    // Return the path of the successfully written file.
    return job.outPath;
  } catch (e) {
    // Print any error encountered during image processing to the debug console.
    debugPrint('Crop error: $e');
    // Return null to signal processing failure.
    return null;
  }
}

// Spawns a background isolate to run _prepareCrop without blocking the Flutter UI thread.
Future _runCrop(_CropJob job) => Isolate.run(() => _prepareCrop(job));

// Stateful dialog widget presenting the camera viewfinder and barcode scanning UI.
class BarcodeScannerDialog extends StatefulWidget {
  // Const constructor accepting an optional widget key.
  const BarcodeScannerDialog({super.key});

  @override
  // Creates and associates the mutable state instance for this widget.
  State createState() => _BarcodeScannerDialogState();
}

// State class managing camera lifecycle, periodic frame captures, and barcode parsing.
class _BarcodeScannerDialogState extends State {
  // Size of the purple targeting box, in logical pixels.
  // Logical pixel width of the on-screen barcode viewfinder box.
  static const double _boxW = 280;
  // Logical pixel height of the on-screen barcode viewfinder box.
  static const double _boxH = 140;
  // Minimum allowable preview zoom level.
  static const double _minZoom = 1.0;
  // Maximum allowable preview zoom level.
  static const double _maxZoom = 3.0;

  // Controller handling hardware camera initialization and capture.
  CameraController? _controller;
  // List of all physical or virtual cameras detected on the device.
  List _cameras = [];
  // Index in _cameras currently active.
  int _selectedCameraIndex = 0;
  // Periodic timer repeatedly triggering frame capture and barcode analysis.
  Timer? _scanTimer;
  // Guard flag preventing overlapping scans when processing takes longer than the interval.
  bool _isProcessing = false;
  // Guard flag indicating a barcode was found and preventing further captures.
  bool _hasDetected = false;
  // Loading state indicating whether a camera is actively starting up.
  bool _isInitializing = true;
  // Toggle controlling whether to horizontally invert the displayed preview.
  bool _unmirror = true;
  // Current software zoom factor applied to the viewfinder.
  double _zoom = 1.6;
  // Counter tracking total frames captured to rotate between processing strategies.
  int _frameCount = 0;
  // Holds any error message that needs to be displayed to the user.
  String? _errorMessage;
  // Dimensions of the dialog viewport used to compute crop scale.
  Size _viewport = const Size(520, 480);
  // Text controller for the fallback manual ISBN input field.
  final TextEditingController _manualController = TextEditingController();

  @override
  // Lifecycle hook invoked once when the widget is inserted into the widget tree.
  void initState() {
    super.initState();
    // Start discovering cameras and initialize the best available camera.
    _initCamera();
  }

  // Helper method checking if a camera is likely an infrared or virtual software feed.
  static bool _looksVirtualOrIr(CameraDescription c) {
    // Normalize camera name to lowercase for case-insensitive matching.
    final n = c.name.toLowerCase();
    // Return true if the camera name matches typical non-standard camera keywords.
    return n.contains(' ir') ||
        n.contains('infrared') ||
        n.contains('virtual') ||
        n.contains('obs') ||
        n.contains('snap') ||
        n.contains('hello');
  }

  // Asynchronous workflow to discover devices and attempt to initialize the primary camera.
  Future _initCamera() async {
    // Update state to display loading spinner and clear previous errors.
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Query the operating system for all available hardware cameras.
      _cameras = await availableCameras();
      // Handle the case where no cameras are attached to the device.
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
            _errorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      // Generate indexed list of cameras and sort standard cameras before virtual/IR cameras.
      final order = List.generate(_cameras.length, (i) => i)
        ..sort(
          (a, b) => (_looksVirtualOrIr(_cameras[a]) ? 1 : 0).compareTo(
            _looksVirtualOrIr(_cameras[b]) ? 1 : 0,
          ),
        );

      // Collect error descriptions for any camera that fails to start.
      final errors = [];
      // Try opening each camera in sorted priority order.
      for (final i in order) {
        debugPrint('Trying camera (i:){_cameras[i].name}');
        // Attempt to start the camera at index i.
        final err = await _startCamera(i);
        // If startup succeeded without error, mark it as active and exit initialization.
        if (err == null) {
          _selectedCameraIndex = i;
          return;
        }
        // If the user dismissed the dialog during initialization, abort.
        if (!mounted) return;
        // Record failed attempt details.
        errors.add('[(i]){_cameras[i].name}\n  $err');
        // Brief pause before trying the next camera to let hardware settle.
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // If all cameras failed, update UI with an aggregate error report.
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage =
              'Could not start any camera.\n\n${errors.join('\n\n')}';
        });
      }
    } catch (e) {
      // Catch and surface unexpected platform exceptions during device discovery.
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera initialization failed: $e';
        });
      }
    }
  }

  // Attempts to open and configure a specific camera index across multiple resolutions.
  Future _startCamera(int index) async {
    // Cancel any active background scanning timer.
    _scanTimer?.cancel();
    // Keep reference to any active controller to safely dispose it.
    final old = _controller;
    // Remove the old controller from state immediately if widget is mounted.
    if (mounted) setState(() => _controller = null);
    // Release hardware resources tied to the previous camera session.
    await old?.dispose();

    // Ordered list of resolution presets to attempt, starting from highest quality.
    const presets = [
      ResolutionPreset.max,
      ResolutionPreset.ultraHigh,
      ResolutionPreset.veryHigh,
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    // Track the latest error message across resolution attempts.
    String lastErr = 'Unknown error';
    // Iterate through resolution presets until one succeeds.
    for (final preset in presets) {
      // Construct a new camera controller instance without audio permissions.
      final candidate = CameraController(
        _cameras[index],
        preset,
        enableAudio: false,
      );

      try {
        // Initialize the camera connection with the current preset.
        await candidate.initialize();
        // If dialog was closed while waiting, clean up resources and exit.
        if (!mounted) {
          await candidate.dispose();
          return 'Widget unmounted';
        }
        // Store successfully initialized controller.
        _controller = candidate;
        // Log successful camera resolution details.
        debugPrint(
          'Camera started at (preset, previewSize=){candidate.value.previewSize}',
        );
        // Clear loading indicators and error states in the UI.
        setState(() {
          _isInitializing = false;
          _errorMessage = null;
        });
        // Kick off periodic scan loop for barcode detection.
        _startScannerLoop();
        // Return null indicating no error occurred.
        return null;
      } catch (e) {
        // Record failure details and retry with next lower resolution.
        lastErr = '(preset:)e';
        debugPrint(
          'Camera (index (){_cameras[index].name}) failed at $lastErr',
        );
        // Dispose failed candidate controller before retrying.
        await candidate.dispose();
        // Brief delay before the next initialization attempt.
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    // Return the last captured error if all resolution presets failed.
    return lastErr;
  }

  /// Fraction of the photo (width, height) that the targeting box covers,
  /// including a safety margin so slightly off-centre barcodes still fit.
  // Calculates the relative width and height fraction to crop around the targeting reticle.
  ({double w, double h}) _cropFractions(CameraController cam) {
    // Retrieve native preview dimensions reported by the camera hardware.
    final ps = cam.value.previewSize;
    // Provide a safe fallback if preview dimensions are invalid or zero.
    if (ps == null || ps.width == 0 || ps.height == 0) {
      return (w: 0.5, h: 0.4);
    }
    // Determine whether running on Android or iOS where camera orientations are rotated.
    final isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    // Swap width and height on mobile because camera sensors are natively landscape.
    final dispW = isMobile ? ps.height : ps.width;
    final dispH = isMobile ? ps.width : ps.height;

    // BoxFit.cover scale from preview pixels to dialog pixels.
    // Calculate uniform scale factor needed to cover dialog viewport bounds.
    final s = math.max(_viewport.width / dispW, _viewport.height / dispH);
    // Multiplier adding padding around the target box to capture slight offsets.
    const margin = 1.3;
    // Calculate horizontal crop fraction relative to preview width and zoom.
    final w = (_boxW * margin) / (s * _zoom * dispW);
    // Calculate vertical crop fraction relative to preview height and zoom.
    final h = (_boxH * margin) / (s * _zoom * dispH);
    // Clamp fraction values between 10% and 100% of the image size.
    return (w: w.clamp(0.1, 1.0).toDouble(), h: h.clamp(0.1, 1.0).toDouble());
  }

  // Sets up a repeating timer that captures photos and evaluates them for barcodes.
  void _startScannerLoop() {
    // Ensure any previously active timer is terminated.
    _scanTimer?.cancel();
    // Schedule frame analysis to run every 650 milliseconds.
    _scanTimer = Timer.periodic(const Duration(milliseconds: 650), (_) async {
      // Reference current camera controller instance.
      final cam = _controller;
      // Skip execution if camera is unready, actively scanning, barcode already found, or UI disposed.
      if (cam == null ||
          !cam.value.isInitialized ||
          _isProcessing ||
          _hasDetected ||
          !mounted) {
        return;
      }

      // Lock scanning to prevent concurrent capture operations.
      _isProcessing = true;
      // Temporary path for cropped image derivative.
      String? cropPath;
      // File handle for raw camera photo.
      XFile? file;
      try {
        // Take a full-resolution snapshot from the camera sensor.
        file = await cam.takePicture();

        // Cycle: 0 = crop, 1 = crop mirrored, 2 = full frame.
        // Cycle frame variation: 0 = cropped, 1 = cropped & flipped, 2 = full uncropped frame.
        final variant = _frameCount % 3;
        // Text labels for debug output corresponding to variant index.
        const labels = ['crop', 'crop-flipped', 'full'];
        final label = labels[variant];

        // Default path to analyze is the raw captured photo.
        String decodePath = file.path;
        // Perform cropping when variant is 0 (normal crop) or 1 (flipped crop).
        if (variant != 2) {
          // Calculate cropping dimensions.
          final fr = _cropFractions(cam);
          // Execute image crop in background isolate.
          cropPath = await _runCrop(
            _CropJob(
              srcPath: file.path,
              outPath: '${file.path}_crop.jpg',
              wFrac: fr.w,
              hFrac: fr.h,
              flip: variant == 1,
              targetWidth: 1400,
            ),
          );
          // If cropping succeeded, redirect decodePath to the processed image.
          if (cropPath != null) decodePath = cropPath;
        }

        // Run ZXing barcode decoding on the chosen image file.
        final Code result = await zx.readBarcodeImagePath(
          XFile(decodePath),
          DecodeParams(format: Format.any, tryHarder: true, tryRotate: true),
        );

        // Increment frame counter for cycling through processing variants.
        _frameCount++;
        // Verify whether ZXing found a valid barcode containing non-empty text.
        final found =
            result.isValid && result.text != null && result.text!.isNotEmpty;
        // Log outcome to the debug console.
        if (found) {
          debugPrint('>>> SUCCESS [(label]: Found barcode:){result.text}');
        } else {
          debugPrint('Frame (_frameCount [)label]: no barcode detected yet');
        }

        // Stop if a prior async event already matched or widget unmounted.
        if (_hasDetected || !mounted) return;

        // Process found barcode string.
        if (found) {
          // Strip out non-alphanumeric barcode characters (allowing 'X'/'x' for ISBN-10 check digits).
          final clean = result.text!
              .replaceAll(RegExp(r'[^0-9Xx]'), '')
              .toUpperCase();

          // Validate ISBN length: must be either ISBN-10 (10 chars) or ISBN-13 (13 chars).
          if (clean.length == 10 || clean.length == 13) {
            // Mark detection completed to suppress subsequent scans.
            _hasDetected = true;
            // Stop scanning timer.
            _scanTimer?.cancel();
            // Close the dialog and return the detected ISBN string to caller.
            Navigator.of(context).pop(clean);
          }
        }
      } catch (e) {
        // Log unexpected errors during capture or decoding.
        debugPrint('Capture error: $e');
      } finally {
        // Clean up temporary files from disk to prevent storage leaks.
        for (final p in [file?.path, cropPath]) {
          if (p == null) continue;
          try {
            final f = File(p);
            // Delete file if it exists.
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
        // Release processing lock so the next cycle can run.
        _isProcessing = false;
      }
    });
  }

  // Toggles to the next camera in the available camera list.
  Future _switchCamera() async {
    // Cannot switch if fewer than two cameras exist.
    if (_cameras.length < 2) return;
    // Display loading state during camera swap.
    setState(() => _isInitializing = true);
    // Advance selected index cyclically through the camera list.
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    // Attempt to start the newly selected camera.
    final err = await _startCamera(_selectedCameraIndex);
    // If switching failed, show error message in the UI.
    if (err != null && mounted) {
      setState(() {
        _isInitializing = false;
        _errorMessage =
            'Camera ({_cameras[_selectedCameraIndex].name} failed.\n\n)err';
      });
    }
  }

  // Increments or decrements preview zoom within allowed min/max thresholds.
  void _changeZoom(double delta) {
    setState(() {
      // Clamp updated zoom level to boundaries.
      _zoom = (_zoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    });
  }

  // Validates and submits manually entered ISBN string from text input field.
  void _submitManual() {
    // Sanitize user input by keeping only digits and check-digit 'X'.
    final clean = _manualController.text
        .replaceAll(RegExp(r'[^0-9Xx]'), '')
        .toUpperCase();
    // Validate length for standard ISBN formats.
    if (clean.length == 10 || clean.length == 13) {
      // Prevent scanner loops from interfering.
      _hasDetected = true;
      _scanTimer?.cancel();
      // Close dialog and return manual entry.
      Navigator.of(context).pop(clean);
    } else {
      // Display warning snackbar if length is invalid.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ISBN must be 10 or 13 characters.')),
      );
    }
  }

  @override
  // Clean up timers and controllers when widget is permanently removed from tree.
  void dispose() {
    // Stop the scanning timer.
    _scanTimer?.cancel();
    // Release camera resources.
    _controller?.dispose();
    // Release text editing controller resources.
    _manualController.dispose();
    // Invoke superclass disposal logic.
    super.dispose();
  }

  @override
  // Builds UI tree displaying camera preview, viewfinder overlays, and controls.
  Widget build(BuildContext context) {
    // Check if platform is Android or iOS.
    final isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    // Retrieve total screen dimensions.
    final screen = MediaQuery.of(context).size;
    // Compute dialog width with maximum boundary of 520px and 40px outer margin.
    final dialogWidth = math.min(520.0, screen.width - 40);
    // Compute dialog height with maximum boundary of 480px and 48px outer margin.
    final dialogHeight = math.min(480.0, screen.height - 48);
    // Update local viewport size record.
    _viewport = Size(dialogWidth, dialogHeight);

    // Root Dialog wrapper.
    return Dialog(
      // Dark backdrop color.
      backgroundColor: Colors.black,
      // Margins surrounding dialog window.
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      // Rounded dialog borders.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Clip inner contents to match rounded border radius.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // Enforce fixed dimensions for the scanner container.
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          // Layer camera preview, overlays, targeting reticle, and buttons.
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Show error screen with retry/manual input options if camera setup failed.
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Red error icon.
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        // Selectable error description text.
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
                        // Retry button re-executing camera initialization.
                        FilledButton.icon(
                          onPressed: _initCamera,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 20),
                        // Text input field allowing manual barcode entry as fallback.
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
                              borderSide: BorderSide(
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _submitManual(),
                        ),
                        const SizedBox(height: 8),
                        // Confirmation button for manual text entry.
                        OutlinedButton(
                          onPressed: _submitManual,
                          child: const Text('Use this ISBN'),
                        ),
                      ],
                    ),
                  ),
                )
              // Show spinner when camera is still starting up.
              else if (_isInitializing)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                  ),
                )
              // Render live camera preview once controller is fully initialized.
              else if (_controller != null && _controller!.value.isInitialized)
                // Apply software zoom scaling to viewfinder.
                Transform.scale(
                  scale: _zoom,
                  // Expand widget to fill container bounds.
                  child: SizedBox.expand(
                    // Scale and crop preview aspect ratio to fill container without distortion.
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        // Adapt width/height swap depending on mobile orientation.
                        width: isMobile
                            ? (_controller!.value.previewSize?.height ?? 520)
                            : (_controller!.value.previewSize?.width ?? 520),
                        height: isMobile
                            ? (_controller!.value.previewSize?.width ?? 480)
                            : (_controller!.value.previewSize?.height ?? 480),
                        // Matrix transformation to optionally unmirror the preview horizontally.
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(_unmirror ? math.pi : 0),
                          // Native Flutter camera preview feed widget.
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  ),
                ),

              // Targeting box: only this area (plus a small margin) is scanned.
              // Render reticle overlay only when camera preview is active without errors.
              if (_errorMessage == null && !_isInitializing)
                // IgnorePointer ensures touch events pass through targeting overlay.
                IgnorePointer(
                  child: Container(
                    width: _boxW,
                    height: _boxH,
                    decoration: BoxDecoration(
                      // Purple border highlighting scanner scan window.
                      border: Border.all(
                        color: Colors.deepPurpleAccent,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      // Subtle semi-transparent inner tint.
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

              // Bottom-left control buttons (mirror toggle, zoom, camera switcher).
              Positioned(
                bottom: 12,
                left: 12,
                child: Row(
                  children: [
                    // Button toggling horizontal mirror effect on preview.
                    IconButton(
                      icon: Icon(
                        _unmirror ? Icons.flip : Icons.flip_camera_android,
                        color: Colors.white,
                      ),
                      tooltip: 'Toggle Mirror Preview',
                      onPressed: () => setState(() => _unmirror = !_unmirror),
                    ),
                    // Button decreasing zoom level.
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.white),
                      tooltip: 'Zoom out',
                      onPressed: _zoom > _minZoom
                          ? () => _changeZoom(-0.4)
                          : null,
                    ),
                    // Button increasing zoom level.
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.white),
                      tooltip: 'Zoom in',
                      onPressed: _zoom < _maxZoom
                          ? () => _changeZoom(0.4)
                          : null,
                    ),
                    // Button switching between available cameras (only shown if multi-camera).
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

              // Top-right close button to dismiss dialog.
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ),

              // Bottom instruction banner giving scanning guidance to the user.
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
                      'Put the barcode inside the box, ~30 cm away',
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
