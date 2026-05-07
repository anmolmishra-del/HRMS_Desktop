import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/widget/custom_shimer_card.dart';
import 'package:intl/intl.dart';

import '../cubit/all_in_out_cubit.dart';
import '../model/all_in_out_state.dart';

class InOutReportPage extends StatelessWidget {
  const InOutReportPage({super.key});

  Color getStatusColor(String status) {
    status = status.toLowerCase();

    if (status.contains("present")) return Colors.green;
    if (status.contains("late")) return Colors.orange;
    if (status.contains("absent")) return Colors.red;

    return Colors.grey;
  }

String getCleanStatus(String status) {
  status = status.toLowerCase();

  if (status.contains("present")) return "Present";
  if (status.contains("late")) return "Late";
  if (status.contains("absent")) return "Absent";

  return "Unknown";
}
  int getTotal(List records, String type) {
    return records
        .where((e) => e.status.toLowerCase().contains(type.toLowerCase()))
        .length;
  }
Widget attendanceTile(dynamic item) {
  final cleanStatus = getCleanStatus(item.status);
  final statusColor = getStatusColor(cleanStatus);

  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xffE5EAF3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: statusColor.withOpacity(.2),
          child: Icon(Icons.access_time, color: statusColor),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM yyyy')
                    .format(DateTime.parse(item.date)),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("In: ${item.checkIn ?? '--'}"),
              Text("Out: ${item.checkOut ?? '--'}"),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            cleanStatus, // ✅ CLEAN STATUS HERE
            style: TextStyle(color: statusColor),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
            builder: (context, state) {

              /// 🔄 LOADING (same UI feel)
              if (state.loading) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, __) => const ShimmerCard(),
                );
              }

              /// ❌ ERROR
              if (state.error.isNotEmpty) {
                return Center(child: Text(state.error));
              }

              final records = state.records;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER (UNCHANGED)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.menu),
                      Text(
                        "In/Out Report",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                
                  _dummyDateField("From Date"),
                  const SizedBox(height: 15),
                  _dummyDateField("To Date"),

                  const SizedBox(height: 30),

                  /// ✅ SUMMARY (dynamic now)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryCard(
                          "Present", getTotal(records, "present"), Colors.green),
                      _summaryCard(
                          "Late", getTotal(records, "late"), Colors.orange),
                      _summaryCard(
                          "Absent", getTotal(records, "absent"), Colors.red),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// LIST (same design)
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return attendanceTile(records[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dummyDateField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xffE5EAF3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Select"),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
