import 'dart:io' as dart_io;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_images.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/core/services/auto_checkin_service.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_state.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:hrms_desktop/features/home/widgets/check_in_out.dart';
import 'package:hrms_desktop/core/widget/custom_shimer_card.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_state.dart';
import 'package:hrms_desktop/features/in_out/presentation/in_out_page.dart';
import 'package:hrms_desktop/features/leave/presentation/leave_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/features/home/presentation/productivity_page.dart';
import 'package:hrms_desktop/features/home/presentation/settings_page.dart'
    as settings;
import 'package:hrms_desktop/features/chat/presentation/chat_listpage.dart';
import 'package:hrms_desktop/features/chat/cubit/chat_cubit.dart';
import 'package:hrms_desktop/core/widget/glass_card.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  late final List pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const DashboardContent(),

      const AttendancePage(),
      LeaveListScreen(),
      const ProductivityPage(),
      const ChatListPage(),

      const settings.SettingsPage(),
    ];

    // CRITICAL: Initialize Chat background polling, WebSockets, and notifications immediately at app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatCubit>().initChat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceReportCubit()..fetchReport(),

      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            backgroundColor: themeState.hasBackground
                ? Colors.transparent
                : Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // Background image (preset asset or custom file)
                  if (themeState.hasBackground)
                    Positioned.fill(
                      child: themeState.isAssetBackground
                          ? Image.asset(
                              themeState.backgroundImagePath,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              dart_io.File(themeState.backgroundImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  // Semi-transparent overlay for readability
                  if (themeState.hasBackground)
                    Positioned.fill(
                      child: Container(
                        color: themeState.themeMode == ThemeMode.dark
                            ? Colors.black.withOpacity(0.55)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ),
                  Row(
                    children: [
                      /// SIDEBAR
                      Container(
                        width: 250,

                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),

                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 30),

                                    Image.asset(
                                      themeState.themeMode == ThemeMode.dark
                                          ? AppImages.logo
                                          : AppImages.logoDark,
                                      height: 120,
                                      width: 120,
                                    ),

                                    const SizedBox(height: 15),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.dashboard_rounded,

                                      title: AppLocalizations.of(context).dashboard,

                                      active: selectedIndex == 0,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 0;
                                        });
                                      },
                                    ),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.access_time_filled_rounded,

                                      title: AppLocalizations.of(context).attendance,

                                      active: selectedIndex == 1,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 1;
                                        });
                                      },
                                    ),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.leave_bags_at_home,

                                      title: AppLocalizations.of(context).leaves,

                                      active: selectedIndex == 2,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 2;
                                        });
                                      },
                                    ),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.bar_chart_rounded,

                                      title: AppLocalizations.of(context).productivity,

                                      active: selectedIndex == 3,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 3;
                                        });
                                      },
                                    ),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.forum_rounded,

                                      title: AppLocalizations.of(context).chat,

                                      active: selectedIndex == 4,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 4;
                                        });
                                      },
                                    ),

                                    _sideBarItem(
                                      context: context,
                                      icon: Icons.settings_rounded,

                                      title: AppLocalizations.of(context).settings,

                                      active: selectedIndex == 5,

                                      onTap: () {
                                        setState(() {
                                          selectedIndex = 5;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(20),

                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,

                                    backgroundColor: Colors.deepPurple.shade200,

                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: FutureBuilder(
                                      future: SharedPref().getObject(
                                        'employee_data',
                                      ),

                                      builder: (context, snapshot) {
                                        String employeeName = "Employee";

                                        String employeePost = "Staff";

                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          final employee =
                                              snapshot.data
                                                  as Map<String, dynamic>;

                                          employeeName =
                                              employee['name']?.toString() ??
                                              "Employee";

                                          employeePost =
                                              employee['job_title']
                                                  ?.toString() ??
                                              "Staff";
                                        }

                                        return Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                Text(
                                                  employeeName,

                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,

                                                    fontWeight: FontWeight.w600,

                                                    fontSize: 15,
                                                  ),
                                                ),

                                                const SizedBox(height: 2),

                                                Text(
                                                  employeePost,

                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.7),

                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Spacer(),
                                            IconButton(
                                              onPressed: () async {
                                                final navigator = Navigator.of(
                                                  context,
                                                );

                                                await context
                                                    .read<LoginCubit>()
                                                    .logout();

                                                if (!context.mounted) return;

                                                navigator
                                                    .pushNamedAndRemoveUntil(
                                                      '/login',
                                                      (route) => false,
                                                    );
                                              },

                                              icon: Icon(
                                                Icons.logout_rounded,

                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// PAGE CONTENT
                      Expanded(child: pages[selectedIndex]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// DASHBOARD PAGE
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  bool _autoCheckInAttempted = false;
  bool? _lastIsCheckedIn;

  @override
  void initState() {
    super.initState();
    // Auto check-in will be triggered after attendance state is loaded
  }

  Future<void> _performAutoCheckIn(BuildContext context) async {
    try {
      await AutoCheckInService.performAutoCheckInIfNeeded(
        context.read<AttendanceCubit>(),
      );
    } catch (e) {
      // Silently handle auto check-in errors to not disrupt user experience
      debugPrint('Auto check-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatus.success) {
          // Only fetch report on initial load or when check-in status actually changes
          if (_lastIsCheckedIn == null || _lastIsCheckedIn != state.isCheckedIn) {
            _lastIsCheckedIn = state.isCheckedIn;
            context.read<AttendanceReportCubit>().fetchReport();
          }

          // Trigger auto check-in only once after initial load
          if (!_autoCheckInAttempted) {
            _autoCheckInAttempted = true;
            _performAutoCheckIn(context);
          }
        }
      },

      child: SingleChildScrollView(
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
                      "${AppLocalizations.of(context).welcomeBack} 👋",

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      AppLocalizations.of(context).todaysTasks,

                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                Container(
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
                        DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// TOP CARDS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// CHECK IN CARD
                Expanded(
                  flex: 2,

                  child: BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      if (state.status == AttendanceStatus.loading) {
                        return const ShimmerCard();
                      }

                      return const CheckInOutCard();
                    },
                  ),
                ),

                const SizedBox(width: 20),

                /// PRODUCTIVITY
                /// PRODUCTIVITY
                Expanded(
                  child: BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      final productivity = state.productivityPercent
                          .toStringAsFixed(1);

                      return _statCard(
                        title: AppLocalizations.of(context).productivity,

                        value: "$productivity%",

                        icon: Icons.pie_chart_rounded,

                        color: Colors.deepPurple,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                /// WORKING HOURS
                Expanded(
                  child: BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      final hours = "${state.todayHours}h";

                      return _statCard(
                        title: AppLocalizations.of(context).workingHours,

                        value: hours,

                        icon: Icons.timer_rounded,

                        color: Colors.blue,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// GRAPH SECTION
            BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
              builder: (context, reportState) {
                // Calculate dates for the current week (Monday to Sunday)
                final DateTime now = DateTime.now();
                final int currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
                final DateTime monday = now.subtract(Duration(days: currentWeekday - 1));

                final List<Map<String, dynamic>> weekDays = List.generate(7, (index) {
                  final dayDate = monday.add(Duration(days: index));
                  final dateStr = DateFormat('yyyy-MM-dd').format(dayDate);
                  final dayLabel = DateFormat('E').format(dayDate); // Mon, Tue, etc.

                  // Retrieve productivity percentage from cubit state (default to 0.0)
                  final percentage = reportState.weeklyProductivity[dateStr] ?? 0.0;
                  return {
                    'label': dayLabel,
                    'percentage': percentage,
                  };
                });

                return GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            AppLocalizations.of(context).weeklyProductivityTrend,

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Text(
                              "This Week",

                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        height: 250,

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,

                          mainAxisAlignment: MainAxisAlignment.spaceAround,

                          children: weekDays.map((day) {
                            return _graphBar(
                              context,
                              day['label'] as String,
                              (day['percentage'] as num).toDouble(),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// RECENT ACTIVITIES
            Text(
              AppLocalizations.of(context).recentActivities,

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 18),

            BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
              builder: (context, state) {
                if (state.records.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No recent records"),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: state.records.length > 5
                      ? 5
                      : state.records.length,

                  itemBuilder: (context, index) {
                    final record = state.records[index];
                    return _ModernActivityTile(record: record);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InOutReportPage();
  }
}

Widget _sideBarItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required bool active,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,

    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),

          const SizedBox(width: 14),

          Text(
            title,

            style: TextStyle(
              color: active
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ModernActivityTile extends StatelessWidget {
  final dynamic record;

  const _ModernActivityTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final rawCheckIn = record['check_in'];
    final rawCheckOut = record['check_out'];

    /// SAFE CHECK-IN VALIDATION
    if (rawCheckIn == null ||
        rawCheckIn == false ||
        rawCheckIn.toString().isEmpty) {
      return const SizedBox();
    }

    DateTime checkIn;

    try {
      String checkInStr = rawCheckIn.toString();

      if (!checkInStr.endsWith('Z')) {
        checkInStr = '${checkInStr.replaceAll(' ', 'T')}Z';
      }

      checkIn = DateTime.parse(checkInStr).toLocal();
    } catch (e) {
      return const SizedBox();
    }

    /// SAFE CHECK-OUT VALIDATION
    DateTime? checkOut;

    if (rawCheckOut != null &&
        rawCheckOut != false &&
        rawCheckOut.toString().isNotEmpty) {
      try {
        String checkOutStr = rawCheckOut.toString();

        if (!checkOutStr.endsWith('Z')) {
          checkOutStr = '${checkOutStr.replaceAll(' ', 'T')}Z';
        }

        checkOut = DateTime.parse(checkOutStr).toLocal();
      } catch (e) {
        checkOut = null;
      }
    }

    final bool completed = checkOut != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          /// STATUS ICON
          Container(
            height: 52,
            width: 52,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
            ),

            child: Icon(
              completed ? Icons.check_circle_rounded : Icons.timer_rounded,

              color: completed ? Colors.green : Colors.orange,
            ),
          ),

          const SizedBox(width: 16),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  DateFormat('EEEE, dd MMM').format(checkIn),

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  completed
                      ? "${AppLocalizations.of(context).checkedInAt} ${DateFormat('hh:mm a').format(checkIn)} ${AppLocalizations.of(context).and} ${AppLocalizations.of(context).checkedOutAt} ${DateFormat('hh:mm a').format(checkOut)}"
                      : "${AppLocalizations.of(context).workingSessionStartedAt} ${DateFormat('hh:mm a').format(checkIn)}",

                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Text(
              completed
                  ? AppLocalizations.of(context).completed
                  : AppLocalizations.of(context).running,

              style: TextStyle(
                color: completed ? Colors.green : Colors.orange,

                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(24),

    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color, color.withOpacity(0.75)]),

      borderRadius: BorderRadius.circular(28),

      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, color: Colors.white, size: 34),

        const SizedBox(height: 30),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    ),
  );
}

Widget _graphBar(BuildContext context, String day, double percentage) {
  final double maxHeight = 180;
  final double barHeight = (percentage / 100.0) * maxHeight;
  // Ensure a minimum height of 8.0 for visual aesthetics
  final double displayHeight = barHeight < 8.0 ? 8.0 : barHeight;
  final bool hasData = percentage > 0;

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        hasData ? "${percentage.toStringAsFixed(0)}%" : "0%",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: hasData 
              ? Colors.deepPurple 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: 42,
        height: displayHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasData 
                ? [Colors.deepPurple, Colors.purpleAccent]
                : [
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasData ? [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}
