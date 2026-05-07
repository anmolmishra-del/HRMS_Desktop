// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';

// class PayslipPdfService {
//   static Future<File> generatePayslipPdf() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(16),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _header(),
//               pw.SizedBox(height: 10),
//               _employeeInfo(),
//               pw.SizedBox(height: 10),
//               _attendanceInfo(),
//               pw.SizedBox(height: 12),
//               _earningsDeductionsTable(),
//               pw.SizedBox(height: 12),
//               _netPaySection(),
//               pw.SizedBox(height: 12),
//               _footer(),
//             ],
//           );
//         },
//       ),
//     );

//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/Payslip_Jan_26.pdf');
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   // ---------------- HEADER ----------------
//   static pw.Widget _header() {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         pw.Text(
//           'Fast Track Projects Private Limited',
//           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.Text(
//           'Unit 302, Surya Arcade, Magnum Opus Lane, Gachibowli, Hyderabad, Telangana, 500032',
//           textAlign: pw.TextAlign.center,
//           style: const pw.TextStyle(fontSize: 9),
//         ),
//         pw.SizedBox(height: 6),
//         pw.Text(
//           'SALARY SLIP FOR THE MONTH OF JAN-26',
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   // ---------------- EMPLOYEE INFO ----------------
//   static pw.Widget _employeeInfo() {
//     return pw.Table(
//       border: pw.TableBorder.all(),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(2),
//         1: const pw.FlexColumnWidth(3),
//         2: const pw.FlexColumnWidth(2),
//         3: const pw.FlexColumnWidth(3),
//       },
//       children: [
//         _row('EmpCode', 'FTPHRD/2024/1137', 'Employee Name', 'MR THALAPANENI PRAVEEN KUMAR'),
//         _row('Father Name', 'Thalapaneni Thirmula Rao', 'DOB', '27-03-2001'),
//         _row('CC', 'Internal', 'DOJ', '23-09-2024'),
//         _row('Bank', 'ICICI BANK', 'Account #', '778401500585'),
//         _row('PAN #', 'BTRPT8766M', 'Aadhaar #', '839171010682'),
//       ],
//     );
//   }

//   // ---------------- ATTENDANCE INFO ----------------
//   static pw.Widget _attendanceInfo() {
//     return pw.Table(
//       border: pw.TableBorder.all(),
//       children: [
//         pw.TableRow(children: [
//           _cell('Workable Days'),
//           _cell('Worked Days'),
//           _cell('LOP/LWOP'),
//           _cell('Arrear Days'),
//           _cell('Late Days'),
//           _cell('Overtime Hours'),
//         ]),
//         pw.TableRow(children: [
//           _cell('31'),
//           _cell('31'),
//           _cell('0'),
//           _cell('0'),
//           _cell('0'),
//           _cell('0'),
//         ]),
//       ],
//     );
//   }

//   // ---------------- EARNINGS & DEDUCTIONS ----------------
//   static pw.Widget _earningsDeductionsTable() {
//     return pw.Table(
//       border: pw.TableBorder.all(),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(3),
//         1: const pw.FlexColumnWidth(2),
//         2: const pw.FlexColumnWidth(3),
//         3: const pw.FlexColumnWidth(2),
//       },
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey300),
//           children: [
//             _cell('EARNINGS', bold: true),
//             _cell('AMOUNT', bold: true),
//             _cell('DEDUCTIONS', bold: true),
//             _cell('AMOUNT', bold: true),
//           ],
//         ),
//         _row('Basic Salary', '8,413', 'Provident Fund', '1,800'),
//         _row('House Rent Allowance', '3,365', 'Professional Tax', '200'),
//         _row('Special Allowance', '7,502', '', ''),
//         _row('Leave Travel Allowance', '1,753', '', ''),
//         _row('Total Earnings', '21,033', 'Total Deductions', '2,000'),
//       ],
//     );
//   }

//   // ---------------- NET PAY ----------------
//   static pw.Widget _netPaySection() {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           'Net Pay : ₹19,033',
//           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//         ),
//         pw.Text(
//           'In words : INR Nineteen Thousand Thirty Three Only',
//           style: const pw.TextStyle(fontSize: 9),
//         ),
//       ],
//     );
//   }

//   // ---------------- FOOTER ----------------
//   static pw.Widget _footer() {
//     return pw.Text(
//       '*This is a system generated payslip and does not require signature',
//       style: const pw.TextStyle(fontSize: 8),
//     );
//   }

//   // ---------------- HELPERS ----------------
//   static pw.TableRow _row(String a, String b, String c, String d) {
//     return pw.TableRow(
//       children: [_cell(a), _cell(b), _cell(c), _cell(d)],
//     );
//   }

//   static pw.Widget _cell(String text, {bool bold = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(4),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
// import 'payslip_pdf_service.dart';

// class PayslipDownloadPage extends StatelessWidget {
//   const PayslipDownloadPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payslip PDF')),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.picture_as_pdf),
//           label: const Text('Generate Payslip PDF'),
//           onPressed: () async {
//             final File file = await PayslipPdfService.generatePayslipPdf();
//             await Printing.openFile(file.path);
//           },
//         ),
//       ),
//     );
//   }
// }


// class PayslipDownloadPage extends StatelessWidget {
//   const PayslipDownloadPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payslip PDF')),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.picture_as_pdf),
//           label: const Text('Generate Payslip PDF'),
//           onPressed: () async {
//             final File file = await PayslipPdfService.generatePayslipPdf();
//             await Printing.openFile(file.path);
//           },
//         ),
//       ),
//     );
//   }
// }

