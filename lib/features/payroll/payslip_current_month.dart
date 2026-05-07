import 'package:flutter/material.dart';

class CurrentMonthCard extends StatelessWidget {
  const CurrentMonthCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 TEMP functional values (hardcoded for now)
    double basicPay = 50000;
    double allowance = 5000;
    double deductions = 2000;

    // 🔹 Functional calculation
    double netSalary = basicPay + allowance - deductions;

    // 🔹 Current month
    final String currentMonth =
        "${DateTime.now().month}-${DateTime.now().year}";

    // 🔹 Simple formatter
    String format(double value) => "₹${value.toStringAsFixed(0)}";

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Month',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                currentMonth,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Salary values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PayrollTile(label: 'Basic Pay', value: format(basicPay)),
              _PayrollTile(label: 'Allowance', value: format(allowance)),
              _PayrollTile(
                label: 'Deductions',
                value: format(deductions),
                isNegative: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Net salary
          Center(
            child: Column(
              children: [
                const Text(
                  'Net Salary',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  format(netSalary),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Local widget (same page)
class _PayrollTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _PayrollTile({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
