import 'package:flutter/material.dart';

class SalaryBreakdownCard extends StatelessWidget {
  const SalaryBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 TEMP functional values (replace later with API)
    double basicPay = 50000;
    double hra = 3000;
    double conveyance = 2000;

    double professionalTax = 200;
    double incomeTax = 1800;

    // 🔹 Functional calculation
    double totalEarnings = basicPay + hra + conveyance;
    double totalDeductions = professionalTax + incomeTax;
    double netSalary = totalEarnings - totalDeductions;

    // 🔹 Simple formatter
    String format(double value, {bool negative = false}) =>
        "${negative ? '-' : ''}₹${value.toStringAsFixed(0)}";

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
          const Text(
            'Salary Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          /// Earnings
          _BreakdownRow(label: 'Basic Pay', value: format(basicPay)),
          _BreakdownRow(label: 'House Rent Allowance', value: format(hra)),
          _BreakdownRow(label: 'Conveyance', value: format(conveyance)),

          /// Deductions
          _BreakdownRow(
            label: 'Professional Tax',
            value: format(professionalTax, negative: true),
          ),
          _BreakdownRow(
            label: 'Income Tax',
            value: format(incomeTax, negative: true),
          ),

          const Divider(height: 24, thickness: 1),

          /// Net Salary
          _BreakdownRow(
            label: 'Net Salary',
            value: format(netSalary),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
