import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/widget/custome_appbar.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FB),
      appBar: CustomAppBar(
        title: 'Payroll',
        subtitle: 'View your salary details',
        assetImage: AppImages.person,
      ),
      body: const SafeArea(
        child: Center(
          child: Text("Payroll Content Coming Soon"),
        ),
      ),
    );
  }
}
