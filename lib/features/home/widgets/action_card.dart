import 'package:flutter/material.dart';

import 'package:hrms_desktop/core/widget/custome_card.dart';
import 'package:hrms_desktop/routes.dart';




class AttendanceActions extends StatelessWidget {
  const AttendanceActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Leaves',
        'icon': Icons.edit_calendar,
        'color': const Color(0xFF8E7CF0),
        'routeName': Routes.leavebalance,
      },
      {
        'title': 'MyPay',
        'icon': Icons.list_alt,
        'color': const Color(0xFF00C853),
        'routeName': Routes.myPay,
      },
      {
        'title': 'In/Out Report',
        'icon': Icons.report,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.inOutReport,
      },
      {
        'title': 'Fix Attendance',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF6C63FF),
        'routeName': Routes.leave,
      },
      {
        'title': 'Doc Box',
        'icon': Icons.swap_horiz,
        'color': const Color(0xFFFF4081),
        'routeName': Routes.docbox,
      },
      {
        'title': 'Company Calendor',
        'icon': Icons.calendar_month,
        'color': const Color(0xFF00ACC1),
        'routeName': Routes.companyCalendar,
      },
      {
        'title': 'Ai Chat Bot',
        'icon': Icons.report,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.aichatbot,
      },
      {
        'title': 'Tax Planner',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF6C63FF),
        'routeName': Routes.leave,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return AttendanceActionCard(
          title: action['title'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,

          /// ✅ FIXED onTap
         onTap: () async {
  if (action['routeName'] == Routes.inOutReport) {
    Navigator.pushNamed(context, Routes.inOutReport);
    return;
  }

  Navigator.pushNamed(
    context,
    action['routeName'] as String,
  );
}
        );
      },
    );
  }
}