import 'package:flutter/material.dart';
import 'package:kittylogued/utils/reading_progress.dart';

/// Progress bar that changes colour in five steps:
/// neutral (to read) -> red -> orange -> yellow -> green (finished).
class ReadingProgressBar extends StatelessWidget {
  final String status;
  final double fraction;
  final double? width;
  final double height;

  static const List<Color> stepColors = [
    Color(0xFF9E9E9E), // to read: neutral grey
    Color(0xFFE53935), // just started: red
    Color(0xFFFB8C00), // orange
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // finished: green
  ];

  const ReadingProgressBar({
    super.key,
    required this.status,
    required this.fraction,
    this.width,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final step = ReadingProgress.stepFor(status, fraction);
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: height,
        color: stepColors[step],
        backgroundColor: Colors.grey.withValues(alpha: 0.25),
      ),
    );
    return width == null ? bar : SizedBox(width: width, child: bar);
  }
}
