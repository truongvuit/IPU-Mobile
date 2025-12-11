import 'package:equatable/equatable.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends StudentEvent {
  const LoadDashboard();
}

class LoadAllCourses extends StudentEvent {
  const LoadAllCourses();
}

class SearchCourses extends StudentEvent {
  final String query;

  const SearchCourses(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadCourseDetail extends StudentEvent {
  final String courseId;

  const LoadCourseDetail(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadMyClasses extends StudentEvent {
  const LoadMyClasses();
}

class LoadClassDetail extends StudentEvent {
  final String classId;

  const LoadClassDetail(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadSchedule extends StudentEvent {
  final DateTime date;

  const LoadSchedule(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadWeekSchedule extends StudentEvent {
  final DateTime startDate;

  const LoadWeekSchedule(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

class LoadMyGrades extends StudentEvent {
  const LoadMyGrades();
}

class LoadGradesByCourse extends StudentEvent {
  final String courseId;

  const LoadGradesByCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadGradesByClass extends StudentEvent {
  final String classId;

  const LoadGradesByClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadProfile extends StudentEvent {
  const LoadProfile();
}

class UpdateProfile extends StudentEvent {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? avatarPath;

  const UpdateProfile(
    this.fullName,
    this.phoneNumber,
    this.address, {
    this.avatarPath,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, address, avatarPath];
}

class SubmitRating extends StudentEvent {
  final String classId;
  final int overallRating;
  final int? teacherRating;
  final int? facilityRating;
  final String comment;

  const SubmitRating({
    required this.classId,
    required this.overallRating,
    this.teacherRating,
    this.facilityRating,
    required this.comment,
  });

  @override
  List<Object?> get props => [
    classId,
    overallRating,
    teacherRating,
    facilityRating,
    comment,
  ];
}

class LoadReviewHistory extends StudentEvent {
  const LoadReviewHistory();
}

class LoadClassReview extends StudentEvent {
  final String classId;

  const LoadClassReview(this.classId);

  @override
  List<Object?> get props => [classId];
}




class AddCourseToCart extends StudentEvent {
  final String courseId;
  final String courseName;
  final int classId;
  final String className;
  final double price;
  final String? imageUrl;

  const AddCourseToCart({
    required this.courseId,
    required this.courseName,
    required this.classId,
    required this.className,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [courseId, classId, courseName, className, price];
}


class RemoveFromCart extends StudentEvent {
  final int classId;

  const RemoveFromCart(this.classId);

  @override
  List<Object?> get props => [classId];
}


class ClearCart extends StudentEvent {
  const ClearCart();
}


class ResetStudentState extends StudentEvent {
  const ResetStudentState();
}
