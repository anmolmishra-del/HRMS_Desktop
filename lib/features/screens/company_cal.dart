import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

class CompanyCalendarPage extends StatefulWidget {
  const CompanyCalendarPage({super.key});

  @override
  State<CompanyCalendarPage> createState() => _CompanyCalendarPageState();
}

class _CompanyCalendarPageState extends State<CompanyCalendarPage> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> events = [
    {"date": DateTime(2026, 1, 26), "title": "Republic Day", "type": "Holiday"},
  ];

  List<Map<String, dynamic>> getEventsForSelectedDate() {
    return events.where((event) {
      final date = event["date"] as DateTime;
      return date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    }).toList();
  }

  Color getEventColor(String type) {
    switch (type) {
      case "Holiday":
        return Colors.red;
      case "Event":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _openAddEventSheet() {
    final titleController = TextEditingController();
    String selectedType = "Event";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).addEvent,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).eventTitle,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    items: [
                      DropdownMenuItem(value: "Event", child: Text(AppLocalizations.of(context).event)),
                      DropdownMenuItem(
                        value: "Holiday",
                        child: Text(AppLocalizations.of(context).holiday),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).type,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          setState(() {
                            events.add({
                              "date": selectedDate,
                              "title": titleController.text,
                              "type": selectedType,
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(AppLocalizations.of(context).save),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = getEventsForSelectedDate();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).companyCalendar), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEventSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${AppLocalizations.of(context).eventsOn} ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).noEvents,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getEventColor(
                              event["type"],
                            ).withAlpha(38),
                            child: Icon(
                              event["type"] == "Holiday"
                                  ? Icons.beach_access
                                  : Icons.event,
                              color: getEventColor(event["type"]),
                            ),
                          ),
                          title: Text(event["title"]),
                          subtitle: Text(
                            event["type"] == "Holiday" 
                                ? AppLocalizations.of(context).holiday 
                                : AppLocalizations.of(context).event
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
