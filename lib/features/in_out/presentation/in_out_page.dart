import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import 'package:hrms_desktop/core/widget/glass_card.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:intl/intl.dart';

/// Main page for displaying the Check-In/Check-Out attendance report.
class InOutReportPage extends StatelessWidget {
  const InOutReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttendanceReportCubit()..fetchReport(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            // Transparent so the parent background image shows through
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                _ReportHeader(),
                Expanded(
                  child: BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
                    builder: (context, state) {
                      if (state.status == ReportStatus.loading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
                      }
                      if (state.records.isEmpty) {
                        return _buildEmptyState(context, themeState);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.records.length,
                        itemBuilder: (context, index) {
                          final record = state.records[index];
                          return _AttendanceCard(record: record);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeState themeState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: themeState.hasBackground
                ? Colors.white.withOpacity(0.5)
                : AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noRecordsFound,
            style: TextStyle(
              color: themeState.hasBackground
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header widget containing the title and date range picker buttons.
class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  Future<void> _selectDate(BuildContext context, bool isFrom, AttendanceReportState state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? state.fromDate : state.toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      final cubit = context.read<AttendanceReportCubit>();
      if (isFrom) {
        cubit.updateDateRange(picked, state.toDate);
      } else {
        cubit.updateDateRange(state.fromDate, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
      builder: (context, state) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isGlass = themeState.hasBackground;

            return ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isGlass ? 14 : 0,
                  sigmaY: isGlass ? 14 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  decoration: BoxDecoration(
                    // Glass mode: semi-transparent dark/light tint
                    // Normal mode: original purple gradient
                    gradient: isGlass ? null : const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.violet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: isGlass
                        ? (themeState.themeMode == ThemeMode.dark
                            ? Colors.black.withOpacity(0.45)
                            : AppColors.primaryPurple.withOpacity(0.55))
                        : null,
                    border: isGlass
                        ? const Border(
                            bottom: BorderSide(color: Colors.white24, width: 1),
                          )
                        : null,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          ),
                           Expanded(
                            child: Text(
                              AppLocalizations.of(context).attendanceReport,
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _DateButton(
                              label: AppLocalizations.of(context).from,
                              date: state.fromDate,
                              onTap: () => _selectDate(context, true, state),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
                          ),
                          Expanded(
                            child: _DateButton(
                              label: AppLocalizations.of(context).to,
                              date: state.toDate,
                              onTap: () => _selectDate(context, false, state),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual card — uses GlassCard so it gets the blur when a background is active.
class _AttendanceCard extends StatelessWidget {
  final dynamic record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final rawCheckIn = record['check_in'];
    final rawCheckOut = record['check_out'];
    final workedHours = (record['worked_hours'] ?? 0.0).toDouble();
    final overtimeHours = (record['overtime_hours'] ?? 0.0).toDouble();
    final validatedOT = (record['validated_overtime_hours'] ?? 0.0).toDouble();
    final inLat = record['in_latitude'];
    final inLong = record['in_longitude'];
    final outLat = record['out_latitude'];
    final outLong = record['out_longitude'];

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
    double displayHours = workedHours;
    if (!isClosed) {
      displayHours = DateTime.now().difference(checkIn).inSeconds / 3600.0;
    }

    final bool hasInLoc  = inLat  != null && inLat  != 0.0;
    final bool hasOutLoc = outLat != null && outLat != 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(
          children: [
            // Upper section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isClosed ? AppColors.successGreen : AppColors.orange).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isClosed ? Icons.check_circle_outline : Icons.timer_outlined,
                      color: isClosed ? AppColors.successGreen : AppColors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, dd MMM').format(checkIn),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isClosed ? AppLocalizations.of(context).completed : AppLocalizations.of(context).stillWorking,
                          style: TextStyle(
                            color: isClosed ? AppColors.textSecondary : AppColors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${displayHours.toStringAsFixed(2)} ${AppLocalizations.of(context).hrs}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      if (overtimeHours > 0)
                        Text(
                          '+${overtimeHours.toStringAsFixed(2)} ${AppLocalizations.of(context).ot}',
                          style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Lower section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeInfo(
                        context, AppLocalizations.of(context).inLabel,
                        DateFormat('hh:mm:ss a').format(checkIn),
                        AppColors.blue,
                        subtitle: hasInLoc
                            ? '${inLat.toStringAsFixed(2)}, ${inLong.toStringAsFixed(2)}'
                            : null,
                      ),
                      _buildTimeInfo(
                        context, AppLocalizations.of(context).outLabel,
                        isClosed ? DateFormat('hh:mm:ss a').format(checkOut) : '--:--',
                        isClosed ? AppColors.dangerRed : AppColors.textSecondary,
                        subtitle: hasOutLoc
                            ? '${outLat.toStringAsFixed(2)}, ${outLong.toStringAsFixed(2)}'
                            : null,
                      ),
                    ],
                  ),
                  if (validatedOT > 0) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined, size: 14, color: AppColors.successGreen),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context).validatedOvertime(validatedOT.toStringAsFixed(2)),
                          style: const TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, String label, String time, Color color, {String? subtitle}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
