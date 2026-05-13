import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/core/widget/custome_appbar.dart';
import 'package:hrms_desktop/features/attendance/action_card.dart';
import 'package:hrms_desktop/features/attendance/this_week_page.dart';
import 'package:hrms_desktop/features/attendance/weekly_attendance.dart';


class AttendanceScreen extends StatelessWidget {
  final bool shouldAnimate;
  const AttendanceScreen({super.key, this.shouldAnimate = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).attendance,
        subtitle: 'Mark and your attendance',
        assetImage: AppImages.person,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeeklyAttendanceChart(shouldAnimate: shouldAnimate),
              const SizedBox(height: 2),
              const SizedBox(height: 16),
              WeekSummaryCard(),
              const SizedBox(height: 16),
              HomeActions(),
            ],
          ),
        ),
      ),
    );
  }
}
