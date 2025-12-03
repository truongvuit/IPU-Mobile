import '../../domain/entities/admin_activity.dart';

class AdminActivityModel extends AdminActivity {
  const AdminActivityModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.timestamp,
    super.userId,
    super.userName,
  });

  factory AdminActivityModel.fromJson(Map<String, dynamic> json) {
    return AdminActivityModel(
      id: json['id'] as String? ?? '',
      type: _activityTypeFromString(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );
  }

  static ActivityType _activityTypeFromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'registration':
        return ActivityType.registration;
      case 'payment':
        return ActivityType.payment;
      case 'class_end':
      case 'classend':
        return ActivityType.classEnd;
      case 'profile_update':
      case 'profileupdate':
        return ActivityType.profileUpdate;
      default:
        return ActivityType.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
    };
  }

  factory AdminActivityModel.fromEntity(AdminActivity entity) {
    return AdminActivityModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      userId: entity.userId,
      userName: entity.userName,
    );
  }

  AdminActivity toEntity() {
    return AdminActivity(
      id: id,
      type: type,
      title: title,
      description: description,
      timestamp: timestamp,
      userId: userId,
      userName: userName,
    );
  }
}
