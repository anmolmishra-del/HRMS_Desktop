// import 'package:flutter/material.dart';
// import 'package:flutter_app/core/constants/app_images.dart';
// import 'package:flutter_app/core/widget/custome_button.dart';
// import 'package:flutter_app/core/widget/custome_textfield.dart';
// import 'package:flutter_app/features/main/presentation/main_page.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool rememberMe = true;
//   bool obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           /// 🔵 Background Image
//           Positioned.fill(
//             child: Image.asset(
//               AppImages.image,
//               fit: BoxFit.cover, // change if needed
//             ),
//           ),
//           Positioned.fill(
//             child: Container(color: Colors.black.withOpacity(0.0)),
//           ),

//           Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Logo
//                   // Image.asset(
//                   //   "", // add your logo
//                   //   height: 90,
//                   // ),
//                   const SizedBox(height: 10),

//                   const Text(
//                     "Opzento HR",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Card
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       double maxWidth = constraints.maxWidth;

//                       return Container(
//                         width: maxWidth > 500 ? 360 : maxWidth * 0.88,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 18,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.80),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 40,
//                               spreadRadius: 5,
//                               offset: const Offset(0, 20),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Company Code'),
//                             const SizedBox(height: 10),

//                             // Email
//                             CustomTextFormField(
//                               hintText: 'Email',
//                               prefixIcon: Icons.email_outlined,
//                               keyboardType: TextInputType.emailAddress,
//                             ),
//                             const SizedBox(height: 15),

//                             // Password
//                             CustomTextFormField(
//                               hintText: 'Password',
//                               prefixIcon: Icons.lock_outline,
//                               obscureText: obscurePassword,
//                               suffixIcon: IconButton(
//                                 onPressed: () {},
//                                 icon: Icon(
//                                   obscurePassword
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 12),

//                             // Remember me + Forgot
//                             Row(
//                               children: [
//                                 Checkbox(
//                                   value: rememberMe,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       rememberMe = value!;
//                                     });
//                                   },
//                                 ),
//                                 const Text("Remember me"),
//                                 const Spacer(),
//                                 TextButton(
//                                   onPressed: () {},
//                                   child: const Text("Forgot password?"),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 20),
//                             // Sign In Button
//                             CustomGradientButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => MainPage(),
//                                   ),
//                                 );
//                               },
//                               text: "Sign In",
//                               borderRadius: 20,
//                               height: 50,
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   const Center(
//                     child: Text.rich(
//                       TextSpan(
//                         text: "Powered by ",
//                         style: TextStyle(color: Colors.grey),
//                         children: [
//                           TextSpan(
//                             text: "FastTrackProjects",
//                             style: TextStyle(
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
