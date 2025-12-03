enum ActivityType { registration, payment, classEnd, profileUpdate, other }

class AdminActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;

  const AdminActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.isNegative) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      id: json['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.other,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      userId: json['userId'],
      userName: json['userName'],
    );
  }
}
