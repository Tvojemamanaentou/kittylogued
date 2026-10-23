import 'package:flutter/material.dart';
import 'package:kittylogued/utils/reading_insights.dart';
import 'package:kittylogued/widgets/mini_bar_chart.dart';

/// Yearly goal, streak and charts for the home page.
class ReadingInsightsSection extends StatelessWidget {
  final ReadingInsights insights;
  final int goal;
  final VoidCallback onEditGoal;
  final bool compact;

  const ReadingInsightsSection({
    super.key,
    required this.insights,
    required this.goal,
    required this.onEditGoal,
    this.compact = false,
  });

  static const _monthLetters = [
    'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D',
  ];

  Widget _title(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _goalRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = insights.finishedThisYear;
    final progress = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: CircularProgressIndicator(
                  value: goal <= 0 ? 0 : progress,
                  strokeWidth: 9,
                  backgroundColor: Colors.grey.withValues(alpha: 0.25),
                  color: progress >= 1 ? Colors.green : scheme.primary,
                ),
              ),
              Text(
                goal <= 0 ? '$done' : '$done/$goal',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal <= 0 ? 'No yearly goal yet' : 'Yearly goal',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                goal <= 0
                    ? 'Books finished this year: $done'
                    : (done >= goal
                          ? 'Goal reached - well done!'
                          : '${goal - done} book(s) to go'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: onEditGoal,
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(goal <= 0 ? 'Set goal' : 'Change goal'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = insights.months;
    final labels = [for (final m in months) _monthLetters[m.month - 1]];
    final ratingLabels = [
      for (var i = 1; i <= 10; i++)
        i.isEven ? '${i ~/ 2}' : '${i ~/ 2}.5',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _goalRow(context),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  insights.currentStreak == 1
                      ? '1-day streak'
                      : '${insights.currentStreak}-day streak',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Text(
                  'Longest: ${insights.longestStreak}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            if (compact) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.auto_stories_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Pages read this week: ${insights.pagesThisWeek}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ] else ...[
              _title(context, 'Books finished per month'),
              MiniBarChart(
                values: [for (final m in months) m.books.toDouble()],
                labels: labels,
              ),
              _title(context, 'Pages read per month'),
              MiniBarChart(
                values: [for (final m in months) m.pages.toDouble()],
                labels: labels,
                color: Colors.teal,
              ),
              _title(context, 'Your ratings (stars)'),
              MiniBarChart(
                values: [
                  for (final c in insights.ratingHistogram) c.toDouble(),
                ],
                labels: ratingLabels,
                color: Colors.amber,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
