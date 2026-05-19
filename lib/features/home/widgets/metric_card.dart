import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;

  final String value;

  final String subtitle;

  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
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
            BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: 14,

              color: colors.onSurface
                  .withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            value,

            style: TextStyle(
              fontSize: 36,

              fontWeight:
                  FontWeight.bold,

              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(subtitle),
        ],
      ),
    );
  }
}