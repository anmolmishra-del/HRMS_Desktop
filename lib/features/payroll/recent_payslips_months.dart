// import 'package:flutter/material.dart';
// import 'package:flutter_app/features/payroll/payslip_download_page.dart';

// class RecentPayslipsCard extends StatelessWidget {
//   const RecentPayslipsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<String> payslips = [
//       'March 2025',
//       'February 2025',
//       'January 2025',
//       'December 2024',
//       'November 2024',
//       'October 2024',
//     ];

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         // borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 12),

//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: payslips.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final month = payslips[index];

//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     month,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                       decoration: TextDecoration.none,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => PayslipDetailsPage(month: month),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color.fromARGB(255, 156, 204, 223),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'View',
//                           style: TextStyle(fontSize: 12, color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => PayslipDownloadPage(month: month),
//                             ),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.download,
//                           size: 14,
//                           color: Colors.white,
//                         ),
//                         label: const Text(
//                           'Download',
//                           style: TextStyle(fontSize: 12, color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color.fromARGB(255, 156, 204, 223),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PayslipDetailsPage extends StatelessWidget {
//   final String month;

//   const PayslipDetailsPage({super.key, required this.month});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(month)),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _infoTile('Employee Name', 'John Doe'),
//             _infoTile('Employee ID', 'EMP1023'),
//             _infoTile('Month', month),
//             _infoTile('Net Salary', '₹52,000'),
//             _infoTile('Paid On', '30th'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
// }
