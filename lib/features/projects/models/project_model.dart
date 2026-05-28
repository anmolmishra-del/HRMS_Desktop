class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String? dateStart;
  final String? date;
  final int? userId;
  final String? userName;
  final String? userImage128;
  final int taskCount;
  final bool allowTimesheets;
  final int? partnerId;
  final String? partnerName;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.dateStart,
    this.date,
    this.userId,
    this.userName,
    this.userImage128,
    required this.taskCount,
    required this.allowTimesheets,
    this.partnerId,
    this.partnerName,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    int? parseUserId;
    String? parseUserName;
    if (json['user_id'] is List && json['user_id'].length > 1) {
      parseUserId = json['user_id'][0] as int;
      parseUserName = json['user_id'][1].toString();
    }

    int? parsePartnerId;
    String? parsePartnerName;
    if (json['partner_id'] is List && json['partner_id'].length > 1) {
      parsePartnerId = json['partner_id'][0] as int;
      parsePartnerName = json['partner_id'][1].toString();
    }

    return ProjectModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Project',
      description: json['description']?.toString() ?? '',
      dateStart: json['date_start']?.toString() == 'false' ? null : json['date_start']?.toString(),
      date: json['date']?.toString() == 'false' ? null : json['date']?.toString(),
      userId: parseUserId,
      userName: parseUserName,
      userImage128: json['user_image_128']?.toString() == 'false' ? null : json['user_image_128']?.toString(),
      taskCount: json['task_count'] is int ? json['task_count'] : 0,
      allowTimesheets: json['allow_timesheets'] == true,
      partnerId: parsePartnerId,
      partnerName: parsePartnerName,
    );
  }
}
