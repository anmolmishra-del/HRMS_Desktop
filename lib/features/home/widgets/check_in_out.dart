import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/home/cubit/home_cubit.dart';
import 'package:hrms_desktop/features/home/widgets/live_working_hours.dart';
import 'package:intl/intl.dart';

class CheckInOutCard extends StatelessWidget {
  final String firstCheckIn;
  final String lastCheckOut;
  final String totalHours;
  final String breakTime;
  final String tags;

  const CheckInOutCard({
    super.key,
    required this.firstCheckIn,
    required this.lastCheckOut,
    required this.totalHours,
    this.breakTime = "",
    this.tags = "",
  });

  String formatTime(String time) {
    if (time.isEmpty) return '--:--';
    return DateFormat.jm().format(DateTime.parse(time));
  }

  double getProgress() {
    if (totalHours.isEmpty) return 0;

    final parts = totalHours.split(":");
    if (parts.length < 2) return 0;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    final totalSeconds = (hours * 3600) + (minutes * 60);

    double progress = totalSeconds / (8 * 3600); // 8 hrs target

    if (progress > 1.0) progress = 1.0;

    return progress;
  }

  double getProgressBreak() {
    if (breakTime.isEmpty) return 0;

    final parts = breakTime.split(":");
    if (parts.length < 2) return 0;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;

    final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    double progress = totalSeconds / 3600;

    if (progress > 1.0) progress = 1.0;

    return progress;
  }

  @override
  Widget build(BuildContext context) {
    double progress = getProgress();
    double breakProgress = getProgressBreak();
    double size2 = 150;
    double strokeWidth2 = 10;
    double radius2 = (size2 / 7) - (strokeWidth2 / 7);
    double angle2 = (2 * math.pi * breakProgress) - math.pi / 2;

    double size = 150;
    double strokeWidth = 10;
    double radius = (size / 7) - (strokeWidth / 7);
    double angle = (2 * math.pi * progress) - math.pi / 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
                  const Text(
                    'Time',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.jm().format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Spacer(),

              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),

                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    tags,
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: size2,
                    width: size2,
                    child: CircularProgressIndicator(
                      value: breakProgress,
                      strokeWidth: strokeWidth2,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.deepOrange,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        breakTime,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Break Hours',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: size,
                    width: size,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: strokeWidth,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Colors.green),
                    ),
                  ),

                  // Positioned(
                  //   left: (size / 2) + radius * math.cos(angle) - 10,
                  //   top: (size / 2) + radius * math.sin(angle) - 7,
                  //   child: Container(
                  //     width: 6,
                  //     height: 6,
                  //     decoration: const BoxDecoration(
                  //       color: Colors.green,
                  //       shape: BoxShape.circle,
                  //     ),
                  //   ),
                  // ),
                  Column(
                    children: [
                      LiveWorkingHours(
                        firstCheckIn: firstCheckIn,
                        lastCheckOut: lastCheckOut,
                        totalHours: totalHours,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Working Hours',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          ////////////////////////////////////////////////
          /// CLOCK IN / OUT
          ////////////////////////////////////////////////
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Clock In',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTime(firstCheckIn),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Clock Out',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTime(lastCheckOut),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ////////////////////////////////////////////////
          /// BUTTON (UI ONLY for now)
          ////////////////////////////////////////////////
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (firstCheckIn.isEmpty || lastCheckOut.isNotEmpty)
                    ? Colors.green
                    : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (firstCheckIn.isEmpty || lastCheckOut.isNotEmpty) {
                  context.read<AttendanceCubit>().checkIn();
                } else {
                  context.read<AttendanceCubit>().checkOut();
                }
              },
              icon: Icon(
                (firstCheckIn.isEmpty || lastCheckOut.isNotEmpty)
                    ? Icons.login
                    : Icons.logout,
                color: Colors.white,
              ),
              label: Text(
                (firstCheckIn.isEmpty || lastCheckOut.isNotEmpty)
                    ? 'Check In'
                    : 'Check Out',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
