class ManyToOne {
  final int id;
  final String name;

  ManyToOne({required this.id, required this.name});

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  factory ManyToOne.fromJson(dynamic json) {
    if (json is List && json.length >= 2) {
      return ManyToOne(
        id: _toInt(json[0]),
        name: json[1]?.toString() ?? '',
      );
    } else if (json is Map) {
      return ManyToOne(
        id: _toInt(json['id']),
        name: json['name']?.toString() ?? '',
      );
    }
    return ManyToOne(id: 0, name: '');
  }

  static ManyToOne? tryParse(dynamic json) {
    if (json == null || json == false) return null;
    try {
      return ManyToOne.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() => name;
}
