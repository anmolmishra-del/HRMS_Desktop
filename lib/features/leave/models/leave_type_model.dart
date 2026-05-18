

class LeaveType {
  final int id;
  final String name;
  final double maxLeaves;
  final double remainingLeaves;

  LeaveType({
    required this.id, 
    required this.name,
    this.maxLeaves = 0,
    this.remainingLeaves = 0,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      maxLeaves: double.tryParse(json['max_leaves']?.toString() ?? '0') ?? 0.0,
      remainingLeaves: double.tryParse(json['virtual_remaining_leaves']?.toString() ?? '0') ?? 0.0,
    );
  }
}
