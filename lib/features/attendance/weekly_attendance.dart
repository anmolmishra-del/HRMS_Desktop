import 'package:flutter/material.dart';

class WeeklyAttendanceChart extends StatefulWidget {
  final bool shouldAnimate;

  const WeeklyAttendanceChart({super.key, required this.shouldAnimate});

  @override
  State<WeeklyAttendanceChart> createState() => _WeeklyAttendanceChartState();
}

class _WeeklyAttendanceChartState extends State<WeeklyAttendanceChart> {
  bool animate = false;

  @override
  void didUpdateWidget(covariant WeeklyAttendanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 Run animation ONLY when tab becomes active
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      setState(() {
        animate = false;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            animate = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = [
      {'day': 'Sun', 'hours': 0.0},
      {'day': 'Mon', 'hours': 8.0},
      {'day': 'Tue', 'hours': 7.5},
      {'day': 'Wed', 'hours': 6.0},
      {'day': 'Thu', 'hours': 8.5},
      {'day': 'Fri', 'hours': 7.0},
      {'day': 'Sat', 'hours': 0.0},
    ];

    const maxHours = 9.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Attendance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeklyData.length, (index) {
                final data = weeklyData[index];
                final targetHeight = (data['hours'] as double) / maxHours * 140;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${data['hours']}h',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 6),

                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: animate ? targetHeight : 0,
                          ),
                          duration: Duration(milliseconds: 500 + index * 120),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) {
                            return Container(
                              width: 18,
                              height: value,
                              decoration: BoxDecoration(
                                color: targetHeight == 0
                                    ? Colors.grey.shade300
                                    : const Color(0xFF35A2EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(data['day'] as String),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
