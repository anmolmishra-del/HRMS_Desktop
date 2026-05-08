// import 'package:flutter/material.dart';


// import 'package:flutter/material.dart';
// import 'package:hrms_desktop/routes.dart';

// import '../../../core/services/token_service.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: TokenService.getUser(),
//       builder: (context, snapshot) {
//         final user = snapshot.data;

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             children: [
//               const SizedBox(height: 50),

//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       ////////////////////////////////////////////////
//                       /// USER CARD (DYNAMIC)
//                       ////////////////////////////////////////////////
//                       _WhiteCard(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 const CircleAvatar(
//                                   radius: 28,
//                                   backgroundImage: NetworkImage(
//                                     "https://i.pravatar.cc/150",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),

//                                 Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       user?["full_name"] ?? "User",
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       user?["role"] ?? "",
//                                       style: const TextStyle(
//                                           color: Colors.grey),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),

//                             const Divider(height: 24),
//                              _InfoLine(user?["employee_code"]??""),
//                             const _InfoLine("IT Department"),
//                             const _InfoLine("Joining: 23/10/2024"),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       ////////////////////////////////////////////////
//                       /// REMAINING CODE (UNCHANGED)
//                       ////////////////////////////////////////////////
//                       _WhiteCard(
//                         title: "Reporting Manager",
//                         child: Row(
//                           children: const [
//                             CircleAvatar(
//                               radius: 20,
//                               backgroundImage: NetworkImage(
//                                 "https://i.pravatar.cc/100",
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   " Sham Prasad Podaralla",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 SizedBox(height: 2),
//                                 Text(
//                                   "CSIO",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       _SettingTile(
//                         icon: Icons.badge_outlined,
//                         title: "Job Details",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.jobdetails);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.event_available_outlined,
//                         title: "Leave Balance",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.leavebalance);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.bar_chart_outlined,
//                         title: "Performance Reviews",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.performRev);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.calendar_month_outlined,
//                         title: "Holidays Calendar",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.holidayCalendar);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.receipt_long_outlined,
//                         title: "Reimbursements",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.reimbursements);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.school_outlined,
//                         title: "Training & Learning",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.learnTraing);
//                         },
//                       ),
//                       const Divider(),

//                       const _SettingTile(
//                         icon: Icons.assignment_turned_in_outlined,
//                         title: "Assets Assigned",
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.lock_outline,
//                         title: "Change Password",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.changepassword);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.notifications_none_outlined,
//                         title: "Notifications",
//                         trailing: _Badge(count: 3),
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.notifications);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.language_outlined,
//                         title: "Language",
//                         onTap: () {
//                           Navigator.pushNamed(
//                               context, Routes.language);
//                         },
//                       ),
//                       const Divider(),

//                       _SettingTile(
//                         icon: Icons.logout,
//                         title: "Logout",
//                         titleColor: Colors.red,
//                         iconColor: Colors.red,
//                         onTap: () async {
//                           Navigator.of(context)
//                               .pushNamedAndRemoveUntil(
//                             '/login',
//                             (route) => false,
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _InfoLine extends StatelessWidget {
//   final String text;

//   const _InfoLine(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 13, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }

// class _WhiteCard extends StatelessWidget {
//   final String? title;
//   final Widget child;

//   const _WhiteCard({this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title!,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//             const Divider(),
//           ],
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _SettingTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String? subtitle;
//   final Widget? trailing;
//   final Color? titleColor;
//   final Color? iconColor;
//   final VoidCallback? onTap;

//   const _SettingTile({
//     required this.icon,
//     required this.title,
//     this.trailing,
//     this.titleColor,
//     this.iconColor,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           dense: true,
//           onTap: onTap,
//           leading: Icon(icon, color: iconColor ?? Colors.blue),
//           title: Text(
//             title,
//             style: TextStyle(
//               color: titleColor ?? Colors.black,
//               fontWeight: FontWeight.w500,
//               fontSize: 13,
//             ),
//           ),
//           subtitle: subtitle != null ? Text(subtitle!) : null,
//           trailing: trailing ?? const Icon(Icons.chevron_right),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 0,
//           ),
//         ),

//         // 🔹 Divider line
//         // const Divider(
//         //   height: 1,
//         //   thickness: 0.8,
//         //   indent: 66, // aligns after icon
//         //   endIndent: 30,
//         // ),
//       ],
//     );
//   }
// }

// class _Badge extends StatelessWidget {
//   final int count;
//   const _Badge({required this.count});

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: 12,
//       backgroundColor: Colors.red,
//       child: Text(
//         count.toString(),
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       ),
//     );
//   }
// }
