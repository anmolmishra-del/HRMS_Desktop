import 'package:flutter/material.dart';

class WeeklyProductivityChart
    extends StatelessWidget {
  final Map<String, double> data;

  const WeeklyProductivityChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Wrap(
        spacing: 20,
        runSpacing: 20,

        alignment:
            WrapAlignment.spaceEvenly,

        children: data.entries.map(
          (entry) {
            return _bar(
              entry.key,
              entry.value.round(),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _bar(
    String day,
    int value,
  ) {
    return SizedBox(
      width: 90,

      child: Column(
        children: [
          Text(day),

          const SizedBox(height: 6),

          LinearProgressIndicator(
            value: value / 100,

            minHeight: 8,
          ),

          const SizedBox(height: 6),

          Text("$value%"),
        ],
      ),
    );
  }
}