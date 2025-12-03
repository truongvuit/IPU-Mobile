import 'package:equatable/equatable.dart';

class TeacherMaterial extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final int classId;
  final String? className;
  final DateTime? uploadedAt;
  final DateTime? updatedAt;

  const TeacherMaterial({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    required this.classId,
    this.className,
    this.uploadedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    fileUrl,
    fileType,
    fileSize,
    classId,
    className,
    uploadedAt,
    updatedAt,
  ];
}
