import 'package:equatable/equatable.dart';

class AdminClassroom extends Equatable {
  final String id;
  final String name;
  final int capacity;
  final String status;
  final List<String> amenities;
  final String? description;
  final String? currentClass;

  const AdminClassroom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    this.amenities = const [],
    this.description,
    this.currentClass,
  });

  static const empty = AdminClassroom(
    id: '',
    name: '',
    capacity: 0,
    status: 'active',
  );

  String get statusText {
    switch (status) {
      case 'active':
        return 'Trống';
      case 'occupied':
        return 'Đang sử dụng';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return 'Không xác định';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    capacity,
    status,
    amenities,
    description,
    currentClass,
  ];

  factory AdminClassroom.fromJson(Map<String, dynamic> json) {
    return AdminClassroom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? 'active',
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description'],
      currentClass: json['currentClass'],
    );
  }
}
