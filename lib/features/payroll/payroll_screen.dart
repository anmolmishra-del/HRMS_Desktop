// import 'package:flutter/material.dart';
// import 'package:flutter_app/core/constants/app_images.dart';
// import 'package:flutter_app/core/widget/custome_appbar.dart';
// import 'package:flutter_app/features/home/widgets/anniversary.dart';
// import 'package:flutter_app/features/payroll/Salary_breakdown.dart';
// import 'package:flutter_app/features/payroll/payslip_current_month.dart';
// import 'package:flutter_app/features/payroll/recent_payslip_page.dart';
// import 'package:flutter_app/features/payroll/recent_payslips_months.dart';

// class PayrollScreen extends StatelessWidget {
//   const PayrollScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F2FB),
//       appBar: CustomAppBar(
//         title: 'Payroll',
//         subtitle: 'View your salary details',
//         assetImage: AppImages.person,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CurrentMonthCard(),
//               SizedBox(height: 16),
//               SalaryBreakdownCard(),
//               SizedBox(height: 16),
//               Anniversary(),
//               SizedBox(height: 12),
//               Tax_Paln(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
