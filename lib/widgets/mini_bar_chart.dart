import 'package:flutter/material.dart';

/// A tiny bar chart: one bar per value with its label underneath.
class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;
  final Color? color;

  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 90,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Theme.of(context).colorScheme.primary;
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height + 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      values[i] > 0 ? values[i].round().toString() : '',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: maxValue <= 0
                          ? 2
                          : (values[i] / maxValue * height).clamp(2.0, height),
                      decoration: BoxDecoration(
                        color: values[i] > 0
                            ? barColor
                            : Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
