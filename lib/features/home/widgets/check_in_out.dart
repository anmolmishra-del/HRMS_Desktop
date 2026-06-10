import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_state.dart';
import 'package:hrms_desktop/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CheckInOutCard extends StatelessWidget {
  const CheckInOutCard({super.key});

  @override
  Widget build(BuildContext context) {
    double size = 150;
    double strokeWidth = 10;

    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<AttendanceCubit>().clearMessages();
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<AttendanceCubit>().clearMessages();
        }
      },
         child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final isCheckedIn = state.isCheckedIn;
          final todayHoursStr = state.todayHours;
          final isLoading = state.status == AttendanceStatus.loading;
          double workedHours = 0.0;
          if (todayHoursStr.contains(':')) {
            final parts = todayHoursStr.split(':');
            if (parts.length == 2) {
              final h = double.tryParse(parts[0]) ?? 0.0;
              final m = double.tryParse(parts[1]) ?? 0.0;
              workedHours = h + (m / 60.0);
            }
          } else {
            workedHours = double.tryParse(todayHoursStr) ?? 0.0;
          }
          double progress = workedHours / 8.0;
          if (progress > 1.0) progress = 1.0;


          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(DateFormat.jm().format(DateTime.now()),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context).date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(width: 8),
                            // GestureDetector(
                            //   onTap: () => Navigator.pushNamed(context, Routes.inOutReport),
                            //   child: const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryPurple),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(DateFormat('d MMM yyyy', AppLocalization().currentLanguageCode).format(DateTime.now()),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: size,
                      width: size,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: strokeWidth,
                        backgroundColor: AppColors.progressBg,
                        valueColor: AlwaysStoppedAnimation(isCheckedIn ? AppColors.orange : AppColors.successGreen),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(todayHoursStr,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isCheckedIn ? AppColors.orange : AppColors.successGreen)),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context).workingHours, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.status == AttendanceStatus.initial || state.status == AttendanceStatus.loading)
                  const SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCheckedIn ? AppColors.dangerRed : AppColors.successGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => context.read<AttendanceCubit>().toggleAttendance(),
                      icon: Icon(isCheckedIn ? Icons.logout_rounded : Icons.login_rounded, size: 20),
                      label: Text(
                        isCheckedIn ? AppLocalizations.of(context).checkOut : AppLocalizations.of(context).checkIn,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
