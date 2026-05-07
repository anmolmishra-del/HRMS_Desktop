// import 'package:flutter/material.dart';
// import 'package:flutter_app/features/payroll/recent_payslips_months.dart';
// import 'package:flutter_app/features/payroll/tax_planner_page.dart';

// class Anniversary extends StatelessWidget {
//   final IconData? trailing;

//   const Anniversary({super.key, this.trailing});

//   List<Map<String, String>> get _cards => [
//     {'title': 'Recent Payslip', 'imageUrl': 'https://i.pravatar.cc/150?img=8'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const RecentPayslipsCard()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Column(
//               children: _cards.map((c) {
//                 final cardTitle = c['title']!;

//                 return Row(
//                   children: [
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         cardTitle,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 14,
//                       color: Colors.grey,
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Tax_Paln extends StatelessWidget {
//   final IconData? trailing;

//   const Tax_Paln({super.key, this.trailing});

//   List<Map<String, String>> get _cards => [
//     {'title': 'Tax Plan', 'imageUrl': 'https://i.pravatar.cc/150?img=8'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const TaxPlannerPage()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Column(
//               children: _cards.map((c) {
//                 final cardTitle = c['title']!;

//                 return Row(
//                   children: [
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         cardTitle,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 14,
//                       color: Colors.grey,
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
