import 'package:flutter/material.dart';

/// Five stars in half-star steps. [value] is 0-10 (each point is half a
/// star); null means "not rated". Pass [onChanged] to make it editable:
/// tap or drag across the stars, tap the same value again to clear it.
class StarRating extends StatelessWidget {
  final int? value;
  final ValueChanged<int?>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
  });

  /// "4.5" for 9, "3" for 6, "Not rated" for null.
  static String label(int? v) {
    if (v == null) return 'Not rated';
    final stars = v / 2;
    return stars == stars.roundToDouble()
        ? stars.toStringAsFixed(0)
        : stars.toStringAsFixed(1);
  }

  int _valueAt(double dx) => (dx / (size / 2)).ceil().clamp(1, 10);

  @override
  Widget build(BuildContext context) {
    final v = value ?? 0;
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            v >= (i + 1) * 2
                ? Icons.star
                : (v >= i * 2 + 1 ? Icons.star_half : Icons.star_border),
            size: size,
            color: Colors.amber,
          ),
      ],
    );

    final handler = onChanged;
    if (handler == null) return stars;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        final picked = _valueAt(d.localPosition.dx);
        handler(picked == value ? null : picked);
      },
      onHorizontalDragUpdate: (d) => handler(_valueAt(d.localPosition.dx)),
      child: SizedBox(width: size * 5, height: size, child: stars),
    );
  }
}
