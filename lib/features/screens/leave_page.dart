import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final List<Map<String, dynamic>> leaveHistory = [
    {
      "type": "Sick Leave",
      "from": DateTime(2026, 2, 10),
      "to": DateTime(2026, 2, 12),
      "days": 3,
      "status": "Approved",
    },
    {
      "type": "Casual Leave",
      "from": DateTime(2026, 1, 25),
      "to": DateTime(2026, 1, 25),
      "days": 1,
      "status": "Pending",
    },
  ];

  final Map<String, int> leaveBalance = {
    "Casual Leave": 5,
    "Sick Leave": 3,
    "Earned Leave": 8,
  };

  Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _openApplyLeaveSheet() {
    String selectedType = "Casual Leave";
    DateTime? fromDate;
    DateTime? toDate;
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              int days = 0;
              if (fromDate != null && toDate != null) {
                days = toDate!.difference(fromDate!).inDays + 1;
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).applyLeave,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Leave Type Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        items: leaveBalance.keys
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).leaveType,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// From Date
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).fromDate,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: fromDate == null
                              ? ""
                              : DateFormat('dd MMM yyyy').format(fromDate!),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => fromDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      /// To Date
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).toDate,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: toDate == null
                              ? ""
                              : DateFormat('dd MMM yyyy').format(toDate!),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: fromDate ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => toDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      Text("${AppLocalizations.of(context).totalDays}: $days"),
                      const SizedBox(height: 15),

                      /// Reason
                      TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).reason,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            if (fromDate != null && toDate != null) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(AppLocalizations.of(context).submit),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).leaveManagement), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Leave Balance Section
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: leaveBalance.length,
                itemBuilder: (context, index) {
                  String key = leaveBalance.keys.elementAt(index);
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.blue.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          "${leaveBalance[key]} ${AppLocalizations.of(context).leaves}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Apply Leave Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _openApplyLeaveSheet,
                child: Text(AppLocalizations.of(context).applyLeave),
              ),
            ),

            const SizedBox(height: 20),

            /// Leave History
            Expanded(
              child: ListView.builder(
                itemCount: leaveHistory.length,
                itemBuilder: (context, index) {
                  var leave = leaveHistory[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(leave["type"]),
                      subtitle: Text(
                        "${DateFormat('dd MMM').format(leave["from"])} - "
                        "${DateFormat('dd MMM').format(leave["to"])} "
                        "(${leave["days"]} ${AppLocalizations.of(context).leaves.toLowerCase()})",
                      ),
                      trailing: Text(
                        leave["status"],
                        style: TextStyle(
                          color: getStatusColor(leave["status"]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
