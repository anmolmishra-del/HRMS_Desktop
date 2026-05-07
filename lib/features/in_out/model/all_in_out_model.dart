class AllAttendanceRecord {
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String workedHours;

  AllAttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.workedHours,
  });

  factory AllAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AllAttendanceRecord(
      date: json["date"],
      checkIn: json["first_check_in"],
      checkOut: json["last_check_out"],
      status: json["status"],
      workedHours: json["worked_hours"],
    );
  }
}