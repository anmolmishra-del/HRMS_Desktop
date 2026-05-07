// import 'package:flutter/material.dart';
// import 'package:flutter_app/core/widget/custome_button.dart';

// class ProfileFullDetailsPage extends StatelessWidget {
//   const ProfileFullDetailsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const Icon(Icons.arrow_back, color: Colors.black),
//         title: const Text(
//           "personal Details",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         actions: const [
//           Icon(Icons.edit, color: Colors.green),
//           SizedBox(width: 15),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             /// ===== OVERVIEW =====
//             _buildSectionTitle("Overview"),
//             _buildOverviewCard(),

//             /// ===== PERSONAL INFORMATION =====
//             _buildSectionTitle("Personal Information"),
//             _buildInfoCard([
//               _buildInfoRow("Full Name", "Shankar Ankepaka"),
//               _buildInfoRow("Gender", "Male"),
//               _buildInfoRow("Date of Birth", "10-Jan-1998"),
//               _buildInfoRow("Blood Group", "O+"),
//               _buildInfoRow("Nationality", "Indian"),
//               _buildInfoRow("Phone", "+91 9876543210"),
//               _buildInfoRow("Email", "shankar@gmail.com"),
//               _buildInfoRow("Address", "Hyderabad, Telangana"),
//             ]),

//             /// ===== CAREER INFORMATION =====
//             _buildSectionTitle("Career Information"),
//             _buildInfoCard([
//               _buildInfoRow("Current Role", "Flutter Developer"),
//               _buildInfoRow("Company", "ABC Technologies"),
//               _buildInfoRow("Experience", "1 Year"),
//               _buildInfoRow("CTC", "₹4 LPA"),
//               _buildInfoRow("Previous Company", "XYZ Solutions"),
//               _buildInfoRow("Previous Role", "Junior Developer"),
//             ]),

//             /// ===== EDUCATION =====
//             _buildSectionTitle("Education"),
//             _buildInfoCard([
//               _buildInfoRow("Degree", "B.Tech"),
//               _buildInfoRow("Specialization", "Computer Science"),
//               _buildInfoRow("Year of Passing", "2021"),
//               _buildInfoRow("University", "JNTU Hyderabad"),
//             ]),

//             /// ===== JOB PREFERENCES =====
//             _buildSectionTitle("Job Preferences"),
//             _buildInfoCard([
//               _buildInfoRow("Preferred Location", "Hyderabad / Bangalore"),
//               _buildInfoRow("Expected Salary", "₹6 LPA"),
//               _buildInfoRow("Notice Period", "30 Days"),
//               _buildInfoRow("Employment Type", "Full Time"),
//             ]),

//             const SizedBox(height: 25),

//             // ElevatedButton(
//             //   style: ElevatedButton.styleFrom(
//             //     backgroundColor: Colors.green,
//             //     minimumSize: const Size(200, 45),
//             //     shape: RoundedRectangleBorder(
//             //       borderRadius: BorderRadius.circular(25),
//             //     ),
//             //   ),
//             //   onPressed: () {},
//             //   child: const Text("Update Profile"),
//             // ),
//             CustomGradientButton(text: 'Update Profile', onPressed: () {}),
//             const SizedBox(height: 65),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Section Title
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.black12,
//           ),
//         ),
//       ),
//     );
//   }

//   /// Overview Card
//   Widget _buildOverviewCard() {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: const [
//             CircleAvatar(
//               radius: 35,
//               backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=8"),
//             ),
//             SizedBox(width: 15),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Shankar Ankepaka",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text("Flutter Developer"),
//                 SizedBox(height: 4),
//                 Text(
//                   "1 Year Experience",
//                   style: TextStyle(color: Colors.green, fontSize: 13),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Info Card
//   Widget _buildInfoCard(List<Widget> children) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         child: Column(children: children),
//       ),
//     );
//   }

//   /// Info Row
//   Widget _buildInfoRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
