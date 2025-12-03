import 'package:equatable/equatable.dart';


class TeacherClass extends Equatable {
  final String id;
  final String code;
  final String? name;
  final String courseType; 
  final int totalStudents;
  final String? schedule; 
  final DateTime startTime;
  final DateTime endTime;
  final String? room;
  final DateTime startDate;
  final DateTime? endDate;
  final String? status; 
  final String? imageUrl;
  final double completionPercentage;

  const TeacherClass({
    required this.id,
    required this.code,
    this.name,
    required this.courseType,
    required this.totalStudents,
    this.schedule,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.startDate,
    this.endDate,
    this.status,
    this.imageUrl,
    this.completionPercentage = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        courseType,
        totalStudents,
        schedule,
        startTime,
        endTime,
        room,
        startDate,
        endDate,
        status,
        imageUrl,
        completionPercentage,
      ];

  TeacherClass copyWith({
    String? id,
    String? code,
    String? name,
    String? courseType,
    int? totalStudents,
    String? schedule,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? imageUrl,
    double? completionPercentage,
  }) {
    return TeacherClass(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      courseType: courseType ?? this.courseType,
      totalStudents: totalStudents ?? this.totalStudents,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
