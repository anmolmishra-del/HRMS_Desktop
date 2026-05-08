import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_state.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:hrms_desktop/features/home/widgets/check_in_out.dart';
import 'package:hrms_desktop/core/widget/custom_shimer_card.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_state.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  /// PAGES
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const DashboardContent(),

      const AttendancePage(),

      const ProductivityPage(),

      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceReportCubit()..fetchReport(),

      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        body: SafeArea(
          child: Row(
            children: [
              /// SIDEBAR
              Container(
                width: 250,

                decoration: const BoxDecoration(color: Color(0xFF111827)),

                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Image.asset('assets/images/opsen.png', height: 70),

                    const SizedBox(height: 12),

                    const Text(
                      "OpzentoHR",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// DASHBOARD
                    _sideBarItem(
                      icon: Icons.dashboard_rounded,

                      title: "Dashboard",

                      active: selectedIndex == 0,

                      onTap: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                      },
                    ),

                    /// ATTENDANCE
                    _sideBarItem(
                      icon: Icons.access_time_filled_rounded,

                      title: "Attendance",

                      active: selectedIndex == 1,

                      onTap: () {
                        setState(() {
                          selectedIndex = 1;
                        });
                      },
                    ),

                    /// PRODUCTIVITY
                    _sideBarItem(
                      icon: Icons.bar_chart_rounded,

                      title: "Productivity",

                      active: selectedIndex == 2,

                      onTap: () {
                        setState(() {
                          selectedIndex = 2;
                        });
                      },
                    ),

                    /// SETTINGS
                    _sideBarItem(
                      icon: Icons.settings_rounded,

                      title: "Settings",

                      active: selectedIndex == 3,

                      onTap: () {
                        setState(() {
                          selectedIndex = 3;
                        });
                      },
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(20),

                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,

                            backgroundColor: Colors.deepPurple.shade200,

                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FutureBuilder(
                              future: SharedPref().getObject('employee_data'),

                              builder: (context, snapshot) {
                                String employeeName = "Employee";

                                String employeePost = "Staff";

                                if (snapshot.hasData && snapshot.data != null) {
                                  final employee =
                                      snapshot.data as Map<String, dynamic>;

                                  employeeName =
                                      employee['name']?.toString() ??
                                      "Employee";

                                  employeePost =
                                      employee['job_title']?.toString() ??
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

                                          style: const TextStyle(
                                            color: Colors.white,

                                            fontWeight: FontWeight.w600,

                                            fontSize: 15,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          employeePost,

                                          style: const TextStyle(
                                            color: Colors.white54,

                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Spacer(),
                                    IconButton(
                                      onPressed: () async {
                                        await context
                                            .read<LoginCubit>()
                                            .logout();

                                        if (context.mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false,
                                          );
                                        }
                                      },

                                      icon: const Icon(
                                        Icons.logout_rounded,

                                        color: Colors.white,
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
        ),
      ),
    );
  }
}

/// DASHBOARD PAGE
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatus.success) {
          context.read<AttendanceReportCubit>().fetchReport();
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Welcome Back 👋",

                      style: TextStyle(
                        fontSize: 30,

                        fontWeight: FontWeight.bold,

                        color: Color(0xFF111827),
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Track attendance and productivity",

                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

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
                Expanded(
                  child: _statCard(
                    title: "Productivity",

                    value: "78%",

                    icon: Icons.pie_chart_rounded,

                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 20),

                /// WORKING HOURS
                Expanded(
                  child: BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      final hours = "${state.todayHours ?? 0}h";

                      return _statCard(
                        title: "Working Hours",

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
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),

                    blurRadius: 14,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Weekly Productivity",

                        style: TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,
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

                        child: const Text(
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

                      children: [
                        _graphBar("Mon", 80),

                        _graphBar("Tue", 120),

                        _graphBar("Wed", 100),

                        _graphBar("Thu", 170),

                        _graphBar("Fri", 150),

                        _graphBar("Sat", 90),

                        _graphBar("Sun", 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// RECENT ACTIVITIES
            const Text(
              "Recent Activities",

              style: TextStyle(
                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 18),

            BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
              builder: (context, state) {
                if (state.status == ReportStatus.loading) {
                  return const ShimmerCard();
                }

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
    return const Center(
      child: Text(
        "Attendance Page",

        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProductivityPage extends StatelessWidget {
  const ProductivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Productivity Page",

        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Settings Page",

        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _sideBarItem({
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
        color: active ? Colors.deepPurple : Colors.transparent,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(width: 14),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
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
        color: Colors.white,

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

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  completed
                      ? "Checked in at ${DateFormat('hh:mm a').format(checkIn)} and checked out at ${DateFormat('hh:mm a').format(checkOut)}"
                      : "Working session started at ${DateFormat('hh:mm a').format(checkIn)}",

                  style: const TextStyle(color: Colors.grey, fontSize: 13),
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
              completed ? "Completed" : "Running",

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

Widget _graphBar(String day, double height) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,

    children: [
      Container(
        width: 42,
        height: height,

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],

            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),

          borderRadius: BorderRadius.circular(16),
        ),
      ),

      const SizedBox(height: 10),

      Text(day, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
