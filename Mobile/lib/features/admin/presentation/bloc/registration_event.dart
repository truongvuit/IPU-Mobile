import 'package:equatable/equatable.dart';

import '../../domain/entities/quick_registration.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRegistration extends RegistrationEvent {
  const InitializeRegistration();
}

class SwitchStudentMode extends RegistrationEvent {
  final bool isNewStudent;

  const SwitchStudentMode(this.isNewStudent);

  @override
  List<Object?> get props => [isNewStudent];
}

class UpdateStudentInfo extends RegistrationEvent {
  final String? studentId;
  final String studentName;
  final String? studentGroup;
  final String phoneNumber;
  final String? email;

  const UpdateStudentInfo({
    this.studentId,
    required this.studentName,
    this.studentGroup,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    studentGroup,
    phoneNumber,
    email,
  ];
}

// Select existing student (from admin student list)
class SelectStudent extends RegistrationEvent {
  final String studentId;
  final String studentName;
  final String phoneNumber;
  final String? email;

  const SelectStudent({
    required this.studentId,
    required this.studentName,
    required this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [studentId, studentName, phoneNumber, email];
}

// Select class (add to list)
class SelectClass extends RegistrationEvent {
  final String classId;
  final String className;
  final double tuitionFee;
  final String? courseId; // ID của khóa học để filter khuyến mãi
  final String? courseName;

  const SelectClass({
    required this.classId,
    required this.className,
    required this.tuitionFee,
    this.courseId,
    this.courseName,
  });

  @override
  List<Object?> get props => [
    classId,
    className,
    tuitionFee,
    courseId,
    courseName,
  ];
}

// Remove class from list
class RemoveClass extends RegistrationEvent {
  final String classId;

  const RemoveClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

// Clear all selected classes
class ClearAllClasses extends RegistrationEvent {
  const ClearAllClasses();
}

// Load available classes
class LoadAvailableClasses extends RegistrationEvent {
  final String? searchQuery;

  const LoadAvailableClasses({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class ApplyPromotion extends RegistrationEvent {
  final String promotionCode;

  const ApplyPromotion(this.promotionCode);

  @override
  List<Object?> get props => [promotionCode];
}

class LoadPromotions extends RegistrationEvent {
  final String? courseId;

  const LoadPromotions({this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class RemovePromotion extends RegistrationEvent {
  const RemovePromotion();
}

class UpdatePaymentMethod extends RegistrationEvent {
  final PaymentMethod paymentMethod;

  const UpdatePaymentMethod(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class UpdateNotes extends RegistrationEvent {
  final String notes;

  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SubmitRegistration extends RegistrationEvent {
  const SubmitRegistration();
}
