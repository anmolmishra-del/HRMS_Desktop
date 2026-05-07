import 'dart:async';
import 'package:flutter/material.dart';

class LiveWorkingHours extends StatefulWidget {
  final String firstCheckIn;
  final String lastCheckOut;
  final String totalHours;

  const LiveWorkingHours({
    super.key,
    required this.firstCheckIn,
    required this.lastCheckOut,
    required this.totalHours,
  });

  @override
  State<LiveWorkingHours> createState() => _LiveWorkingHoursState();
}

class _LiveWorkingHoursState extends State<LiveWorkingHours> {
  late String display;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  ////////////////////////////////////////////////
  /// 🔥 HANDLE NEW DATA (CHECK-IN / CHECK-OUT)
  ////////////////////////////////////////////////
  @override
  void didUpdateWidget(covariant LiveWorkingHours oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.firstCheckIn != widget.firstCheckIn ||
        oldWidget.lastCheckOut != widget.lastCheckOut ||
        oldWidget.totalHours != widget.totalHours) {
      _stopTimer();
      _startTimer();
    }
  }

  ////////////////////////////////////////////////
  /// START TIMER (INCREMENT MODE)
  ////////////////////////////////////////////////
  void _startTimer() {
  
    display = widget.totalHours.isNotEmpty
        ? widget.totalHours
        : "00:00:00";

   
    if (widget.firstCheckIn.isNotEmpty &&
        widget.lastCheckOut.isEmpty) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          display = _increment(display);
        });
      });
    }
  }


  ////////////////////////////////////////////////
  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }


  String _increment(String time) {
    final parts = time.split(":");

    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts[1]) ?? 0;
    int s = int.tryParse(parts[2]) ?? 0;

    s++;

    if (s >= 60) {
      s = 0;
      m++;
    }

    if (m >= 60) {
      m = 0;
      h++;
    }

    String two(int n) => n.toString().padLeft(2, '0');

    return "${two(h)}:${two(m)}:${two(s)}";
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      display,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}