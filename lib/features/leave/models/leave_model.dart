
import 'package:hrms_desktop/core/models/odoo_models.dart';

class LeaveRequest {
  final int id;
  final String displayName;
  final ManyToOne? holidayStatusId;
  final String? payslipState;
  final DateTime? requestDateFrom;
  final DateTime? requestDateTo;
  final String? durationDisplay;
  final String? name; // Description
  final List<int> supportedAttachmentIds;
  final bool requestUnitHalf;
  final String? requestDateFromPeriod;
  final bool requestUnitHours;
  final double requestHourFrom;
  final double requestHourTo;
  final String state; // 'draft', 'confirm', 'refuse', 'validate', 'cancel'

  LeaveRequest({
    required this.id,
    required this.displayName,
    this.holidayStatusId,
    this.payslipState,
    this.requestDateFrom,
    this.requestDateTo,
    this.durationDisplay,
    this.name,
    this.supportedAttachmentIds = const [],
    this.requestUnitHalf = false,
    this.requestDateFromPeriod,
    this.requestUnitHours = false,
    this.requestHourFrom = 0.0,
    this.requestHourTo = 0.0,
    this.state = 'draft',
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _toDouble(dynamic val) {
    if (val == null || val == false) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: _toInt(json['id']),
      displayName: json['display_name']?.toString() ?? '',
      holidayStatusId: ManyToOne.tryParse(json['holiday_status_id']),
      payslipState: json['payslip_state']?.toString(),
      requestDateFrom: json['request_date_from'] != null && json['request_date_from'] != false
          ? DateTime.tryParse(json['request_date_from'].toString())
          : null,
      requestDateTo: json['request_date_to'] != null && json['request_date_to'] != false
          ? DateTime.tryParse(json['request_date_to'].toString())
          : null,
      durationDisplay: json['duration_display']?.toString(),
      name: json['name']?.toString(),
      supportedAttachmentIds: json['supported_attachment_ids'] is List 
          ? List<int>.from(json['supported_attachment_ids']) 
          : [],
      requestUnitHalf: json['request_unit_half'] is bool ? json['request_unit_half'] : false,
      requestDateFromPeriod: json['request_date_from_period']?.toString(),
      requestUnitHours: json['request_unit_hours'] is bool ? json['request_unit_hours'] : false,
      requestHourFrom: _toDouble(json['request_hour_from']),
      requestHourTo: _toDouble(json['request_hour_to']),
      state: json['state']?.toString() ?? 'draft',
    );
  }
}
