import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_state.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_state.dart';
import 'package:hrms_desktop/core/services/app_usage_service.dart';

class AppUsageData {
  final IconData icon;
  final Color color;
  final Duration timeSpent;
  final String category;

  const AppUsageData({
    required this.icon,
    required this.color,
    required this.timeSpent,
    required this.category,
  });
}

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage> {
  DateTime _selectedDate = DateTime.now();
// Get real app usage data from AppUsageService
List<AppUsageInfo> get _appUsageList {

  final usageData =
      AppUsageService()
          .getUsageData();

  // DEBUG
  print(
    "APP USAGE DATA => $usageData",
  );

  // EMPTY CHECK
  if (usageData.isEmpty) {

    return [
      AppUsageInfo(
        appName: "No Data",
        timeSpent:
            Duration.zero,
        category: "Waiting",
        icon:
            Icons.hourglass_empty,
        color:
            Colors.grey,
      ),
    ];
  }

  return usageData.entries.map((entry) {

    final appName =
        entry.key;

    final timeSpent =
        entry.value;

    final category =
        AppUsageService()
            .getAppCategory(
      appName,
    );

    final icon =
        AppUsageService()
            .getAppIcon(
      appName,
    );

    final color =
        AppUsageService()
            .getAppColor(
      category,
    );

    // CUSTOM ICON
    IconData appIcon = icon;

    if (appName
        .toLowerCase()
        .contains(
          'youtube',
        )) {

      appIcon =
          Icons.play_circle;
    }

    return AppUsageInfo(
      appName: appName,
      timeSpent: timeSpent,
      category: category,
      icon: appIcon,
      color: color,
    );

  }).toList()

    ..sort(
      (a, b) => b.timeSpent.compareTo(
        a.timeSpent,
      ),
    );
}
  // Calculate weekly productivity data from attendance records
  Map<String, double> _calculateWeeklyProductivity(List<dynamic> records) {
    final Map<String, double> weeklyData = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (final record in records) {
      try {
        final checkInTime = record['check_in'];
        if (checkInTime == null || checkInTime == false) continue;

        DateTime checkIn = DateTime.parse(checkInTime.toString().replaceAll(' ', 'T') + 'Z').toLocal();
        
        // Only include records from current week
        if (checkIn.isAfter(weekStart)) {
          final dayName = DateFormat('EEE').format(checkIn);
          final workedHours = (record['worked_hours'] ?? 0.0).toDouble();
          
          // Calculate productivity as percentage (assuming 8-hour workday)
          final productivity = (workedHours / 8.0 * 100).clamp(0.0, 100.0);
          
          if (weeklyData.containsKey(dayName)) {
            weeklyData[dayName] = productivity;
          }
        }
      } catch (e) {
        continue;
      }
    }

    // If no data for current week, use current productivity as estimate
    if (weeklyData.values.every((value) => value == 0.0)) {
      final currentProductivity = 75.0; // Default fallback
      weeklyData.updateAll((key, value) => currentProductivity * (0.8 + (Random().nextDouble() * 0.4)));
    }

    return weeklyData;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, attendanceState) {
        return BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
          builder: (context, reportState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).productivity + " 📊",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).trackAttendanceAndProductivity,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// TOP METRICS ROW
          Row(
            children: [
              /// PRODUCTIVITY SCORE
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).todayScore,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "↑ 12%",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${attendanceState.productivityPercent.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Good Performance",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              /// FOCUS TIME
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).focusTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "↑ 8%",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${attendanceState.productiveHours.toStringAsFixed(1)}h",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Deep Work",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              /// TASKS COMPLETED
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).tasksCompleted,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "↑ 12%",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "12/15",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "On Track",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// APP USAGE TRACKING
          Text(
            "App Usage Today",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

        
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _appUsageList.length,
            itemBuilder: (context, index) {
              final appData = _appUsageList[index];
              
              return _appUsageCard(
                context,
                appData.appName,
                AppUsageData(
                  icon: appData.icon,
                  color: appData.color,
                  timeSpent: appData.timeSpent,
                  category: appData.category,
                ),
              );
            },
          ),

          const SizedBox(height: 30),

        
          Text(
            AppLocalizations.of(context).todaysTasks,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          /// TASK LIST
          ...reportState.records.map((record) {
            final taskTitle = record['task_title']?.toString() ?? 'Untitled Task';
            final taskTime = record['task_time']?.toString() ?? '0h 0m';
            final isCompleted = record['is_completed'] ?? false;
            final statusColor = isCompleted ? Colors.green : Colors.orange;

            return _taskCard(context, taskTitle, taskTime, isCompleted, statusColor);
          }).toList(),

          const SizedBox(height: 30),

          /// WEEKLY PRODUCTIVITY CHART
          Text(
            "Weekly Productivity",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          /// CHART
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _productivityBar(context, "Mon", _calculateWeeklyProductivity(reportState.records)['Mon']!.round()),
                    _productivityBar(context, "Tue", _calculateWeeklyProductivity(reportState.records)['Tue']!.round()),
                    _productivityBar(context, "Wed", _calculateWeeklyProductivity(reportState.records)['Wed']!.round()),
                    _productivityBar(context, "Thu", _calculateWeeklyProductivity(reportState.records)['Thu']!.round()),
                    _productivityBar(context, "Fri", _calculateWeeklyProductivity(reportState.records)['Fri']!.round()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _productivityBar(context, "Sat", _calculateWeeklyProductivity(reportState.records)['Sat']!.round()),
                    _productivityBar(context, "Sun", _calculateWeeklyProductivity(reportState.records)['Sun']!.round()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
          },
        );
      },
    );
  }

Widget productivityBar(BuildContext context, String day, int percentage) {
  final color = _getProductivityColor(percentage / 100.0);
  final label = _getProductivityLabel(percentage / 100.0);

  return Column(
    children: [
      Text(
        day,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 4),
      Container(
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: LinearProgressIndicator(
          value: percentage / 100.0,
          minHeight: 8,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.deepPurple.shade300,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "$percentage%",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    ],
  );
}

Color _getProductivityColor(double productivityRatio) {
  if (productivityRatio >= 0.8) return Colors.green;
  if (productivityRatio >= 0.6) return Colors.orange;
  return Colors.red;
}

String _getProductivityLabel(double productivityRatio) {
  if (productivityRatio >= 0.8) return "Excellent";
  if (productivityRatio >= 0.6) return "Good";
  return "Needs Improvement";
}

Widget _taskCard(BuildContext context, String title, String time, bool completed, Color statusColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: statusColor.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              completed ? Icons.check_circle_rounded : Icons.circle_rounded,
              color: statusColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ));
}

Widget _appUsageCard(BuildContext context, String appName, AppUsageData appData) {
  final hours = appData.timeSpent.inHours;
  final minutes = appData.timeSpent.inMinutes.remainder(60);
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: appData.color.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appData.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                appData.icon,
                color: appData.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appData.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${hours}h ${minutes}m",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getProductivityColor(appData.timeSpent.inHours / 8.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getProductivityLabel(appData.timeSpent.inHours / 8.0),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
Widget _productivityBar(
  BuildContext context,
  String day,
  int percentage,
) {
  final color =
      _getProductivityColor(
    percentage / 100.0,
  );

  return SizedBox(
    width: 90,
    child: Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w500,
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            4,
          ),

          child:
              LinearProgressIndicator(
            value:
                percentage / 100.0,

            minHeight: 8,

            backgroundColor:
                Colors.grey
                    .withOpacity(
              0.2,
            ),

            valueColor:
                AlwaysStoppedAnimation<
                    Color>(
              color,
            ),
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          "$percentage%",
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurface,
          ),
        ),
      ],
    ),
  );
}
// Color _getProductivityColor(double productivityRatio) {
//   if (productivityRatio >= 0.8) return Colors.green;
//   if (productivityRatio >= 0.6) return Colors.orange;
//   return Colors.red;
// }

}
