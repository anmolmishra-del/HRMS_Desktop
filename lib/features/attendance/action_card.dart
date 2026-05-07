import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/widget/custome_card.dart';
import 'package:hrms_desktop/features/attendance/attendance_page.dart';


class HomeActions extends StatelessWidget {
  const HomeActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      children: [
        AttendanceActionCard(
          title: 'Fix Attendance',
          icon: Icons.edit_calendar,
          color: const Color(0xFF8E7CF0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceScreen()),
            );
          },
        ),
        AttendanceActionCard(
          title: 'Daily Details',
          icon: Icons.list_alt,
          color: const Color(0xFF00C853),
          onTap: () {
            // navigate to leave page
          },
        ),
        AttendanceActionCard(
          title: 'In/Out Report',
          icon: Icons.report,
          color: const Color(0xFFFF6D00),
          onTap: () {
            // navigate to payroll page
          },
        ),
        AttendanceActionCard(
          title: 'Calendar View',
          icon: Icons.calendar_today,
          color: const Color(0xFF6C63FF),
          onTap: () {
            // navigate to profile page
          },
        ),
        AttendanceActionCard(
          title: 'Change Shift Request',
          icon: Icons.swap_horiz,
          color: const Color(0xFFFF4081),
          onTap: () {
            // navigate to profile page
          },
        ),
        AttendanceActionCard(
          title: 'Geo-Location Track',
          icon: Icons.location_on,
          color: const Color(0xFF00ACC1),
          onTap: () {
            // navigate to profile page
          },
        ),
      ],
    );
  }
}
