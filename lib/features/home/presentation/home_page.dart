import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_state.dart';
import 'package:hrms_desktop/features/home/widgets/check_in_out.dart';
import 'package:hrms_desktop/core/widget/custom_shimer_card.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_state.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceReportCubit()..fetchReport(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F2FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 200,
          leading: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Image.asset('assets/images/opsen.png'),
              ),
              const Text(
                'OpzentoHR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: BlocListener<AttendanceCubit, AttendanceState>(
            listener: (context, state) {
              // Refresh the report list whenever a check-in or check-out is successful
              if (state.status == AttendanceStatus.success && state.successMessage != null) {
                context.read<AttendanceReportCubit>().fetchReport();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      if (state.status == AttendanceStatus.loading) {
                        return const Center(
                          child: ShimmerCard(),
                        );
                      }
                      return const CheckInOutCard();
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Recent Attendance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
                    builder: (context, state) {
                      if (state.status == ReportStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: AppColors.primaryPurple),
                          ),
                        );
                      }
                      
                      if (state.records.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No recent records", style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.records.length > 5 ? 5 : state.records.length,
                        itemBuilder: (context, index) {
                          final record = state.records[index];
                          return _HomeAttendanceTile(record: record);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAttendanceTile extends StatelessWidget {
  final dynamic record;
  const _HomeAttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final rawCheckIn = record['check_in'];
    final rawCheckOut = record['check_out'];
    final workedHours = (record['worked_hours'] ?? 0.0).toDouble();

    if (rawCheckIn == null || rawCheckIn == false) return const SizedBox.shrink();

    String checkInStr = rawCheckIn.toString();
    if (!checkInStr.endsWith('Z')) {
      checkInStr = '${checkInStr.replaceAll(' ', 'T')}Z';
    }
    final DateTime checkIn = DateTime.parse(checkInStr).toLocal();

    DateTime? checkOut;
    if (rawCheckOut != null && rawCheckOut is String && rawCheckOut.isNotEmpty) {
      String checkOutStr = rawCheckOut;
      if (!checkOutStr.endsWith('Z')) {
        checkOutStr = '${checkOutStr.replaceAll(' ', 'T')}Z';
      }
      checkOut = DateTime.parse(checkOutStr).toLocal();
    }

    final bool isClosed = checkOut != null;
    
    // If session is open, calculate worked hours based on current time
    double displayHours = workedHours;
    if (!isClosed) {
      displayHours = DateTime.now().difference(checkIn).inSeconds / 3600.0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isClosed ? AppColors.successGreen : AppColors.orange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isClosed ? Icons.check_circle_outline : Icons.timer_outlined,
              color: isClosed ? AppColors.successGreen : AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, dd MMM').format(checkIn),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  isClosed 
                    ? "In: ${DateFormat('hh:mm a').format(checkIn)} - Out: ${DateFormat('hh:mm a').format(checkOut!)}"
                    : "Started at ${DateFormat('hh:mm a').format(checkIn)}",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${displayHours.toStringAsFixed(2)}h',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}