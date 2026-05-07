import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      shape: RoundedRectangleBorder(
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
                      const Text(
                        "Apply Leave",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Leave Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedType,
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
                          labelText: "Leave Type",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// From Date
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "From Date",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
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
                          labelText: "To Date",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
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

                      Text("Total Days: $days"),
                      const SizedBox(height: 15),

                      /// Reason
                      TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Reason",
                          border: OutlineInputBorder(),
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
                          child: const Text("Submit"),
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
      appBar: AppBar(title: const Text("Leave Management"), centerTitle: true),
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
                          "${leaveBalance[key]} Days",
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
                child: const Text("Apply Leave"),
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
                        "(${leave["days"]} days)",
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
