import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductivityHeader extends StatelessWidget {
  final DateTime selectedDate;

  final VoidCallback onDateTap;

  const ProductivityHeader({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              "Productivity 📊",

              style: TextStyle(
                fontSize: 30,

                fontWeight:
                    FontWeight.bold,

                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Track attendance and productivity",

              style: TextStyle(
                fontSize: 16,

                color: colors.onSurface
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),

        GestureDetector(
          onTap: onDateTap,

          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color: colors.surface,

              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                ),

                const SizedBox(width: 10),

                Text(
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(selectedDate),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}