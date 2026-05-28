class ProjectTaskModel {
  final int id;
  final String name;
  final String description;
  final String? dateDeadline;
  final int? stageId;
  final String? stageName;
  final String priority;
  final double remainingHours;
  final double effectiveHours;
  final double allocatedHours;
  final bool allowTimesheets;
  final List<int> userIds;

  ProjectTaskModel({
    required this.id,
    required this.name,
    required this.description,
    this.dateDeadline,
    this.stageId,
    this.stageName,
    required this.priority,
    required this.remainingHours,
    required this.effectiveHours,
    required this.allocatedHours,
    required this.allowTimesheets,
    required this.userIds,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    int? parseStageId;
    String? parseStageName;
    if (json['stage_id'] is List && json['stage_id'].length > 1) {
      parseStageId = json['stage_id'][0] as int;
      parseStageName = json['stage_id'][1].toString();
    }

    return ProjectTaskModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Task',
      description: json['description']?.toString() ?? '',
      dateDeadline: json['date_deadline']?.toString() == 'false' ? null : json['date_deadline']?.toString(),
      stageId: parseStageId,
      stageName: parseStageName ?? 'New',
      priority: json['priority']?.toString() ?? '0',
      remainingHours: (json['remaining_hours'] is num) ? (json['remaining_hours'] as num).toDouble() : 0.0,
      effectiveHours: (json['effective_hours'] is num) ? (json['effective_hours'] as num).toDouble() : 0.0,
      allocatedHours: (json['allocated_hours'] is num) ? (json['allocated_hours'] as num).toDouble() : 0.0,
      allowTimesheets: json['allow_timesheets'] == true,
      userIds: (json['user_ids'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }
}
