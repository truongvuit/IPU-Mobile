import 'package:equatable/equatable.dart';

import '../../domain/entities/quick_registration.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/promotion.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

class RegistrationError extends RegistrationState {
  final String message;

  const RegistrationError(this.message);

  @override
  List<Object?> get props => [message];
}


class SelectedClassInfo {
  final String classId;
  final String className;
  final String? courseId;
  final String? courseName;
  final double tuitionFee;

  const SelectedClassInfo({
    required this.classId,
    required this.className,
    this.courseId,
    this.courseName,
    required this.tuitionFee,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedClassInfo &&
          runtimeType == other.runtimeType &&
          classId == other.classId;

  @override
  int get hashCode => classId.hashCode;
}

// Registration in progress with current data
class RegistrationInProgress extends RegistrationState {
  final bool isNewStudent; // true = học viên mới, false = học viên đã có
  final String? studentId; // ID học viên đã chọn (null nếu là học viên mới)
  final String? studentName;
  final String? studentGroup;
  final String? phoneNumber;
  final String? email;
  final List<SelectedClassInfo> selectedClasses; // Danh sách lớp đã chọn
  final double discount;
  final String? promotionCode;
  final Promotion? appliedPromotion;
  final PaymentMethod paymentMethod;
  final String? notes;

  const RegistrationInProgress({
    this.isNewStudent = true,
    this.studentId,
    this.studentName,
    this.studentGroup,
    this.phoneNumber,
    this.email,
    this.selectedClasses = const [],
    this.discount = 0,
    this.promotionCode,
    this.appliedPromotion,
    this.paymentMethod = PaymentMethod.cash,
    this.notes,
  });

  // Tính tổng học phí từ tất cả các lớp
  double get tuitionFee =>
      selectedClasses.fold(0, (sum, c) => sum + c.tuitionFee);

  double get totalAmount => tuitionFee - discount;

  // Lấy tên tất cả lớp đã chọn
  String? get className => selectedClasses.isEmpty
      ? null
      : selectedClasses.map((c) => c.className).join(', ');

  // Lấy class ID đầu tiên (để tương thích code cũ)
  String? get classId =>
      selectedClasses.isEmpty ? null : selectedClasses.first.classId;

  // Lấy course ID đầu tiên (để filter khuyến mãi)
  String? get courseId =>
      selectedClasses.isEmpty ? null : selectedClasses.first.courseId;
  String? get courseName =>
      selectedClasses.isEmpty ? null : selectedClasses.first.courseName;

  // Lấy tất cả course IDs đã chọn (unique)
  List<String> get selectedCourseIds => selectedClasses
      .where((c) => c.courseId != null)
      .map((c) => c.courseId!)
      .toSet()
      .toList();

  bool get isValid {
    // Học viên mới: cần có tên và SĐT
    // Học viên cũ: cần có studentId
    final hasValidStudent = isNewStudent
        ? (studentName != null &&
              studentName!.isNotEmpty &&
              phoneNumber != null &&
              phoneNumber!.isNotEmpty)
        : (studentId != null && studentId!.isNotEmpty);
    return hasValidStudent && selectedClasses.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    isNewStudent,
    studentId,
    studentName,
    studentGroup,
    phoneNumber,
    email,
    selectedClasses,
    discount,
    promotionCode,
    appliedPromotion,
    paymentMethod,
    notes,
  ];

  RegistrationInProgress copyWith({
    bool? isNewStudent,
    String? studentId,
    String? studentName,
    String? studentGroup,
    String? phoneNumber,
    String? email,
    List<SelectedClassInfo>? selectedClasses,
    double? discount,
    String? promotionCode,
    Promotion? appliedPromotion,
    PaymentMethod? paymentMethod,
    String? notes,
    bool clearPromotion = false,
    bool clearStudent = false,
  }) {
    return RegistrationInProgress(
      isNewStudent: isNewStudent ?? this.isNewStudent,
      studentId: clearStudent ? null : (studentId ?? this.studentId),
      studentName: clearStudent ? null : (studentName ?? this.studentName),
      studentGroup: clearStudent ? null : (studentGroup ?? this.studentGroup),
      phoneNumber: clearStudent ? null : (phoneNumber ?? this.phoneNumber),
      email: clearStudent ? null : (email ?? this.email),
      selectedClasses: selectedClasses ?? this.selectedClasses,
      discount: discount ?? this.discount,
      promotionCode: clearPromotion
          ? null
          : (promotionCode ?? this.promotionCode),
      appliedPromotion: clearPromotion
          ? null
          : (appliedPromotion ?? this.appliedPromotion),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}

/// Thông tin filter cho màn chọn lớp
class ClassFilterInfo {
  final String? courseId;
  final String? courseName;
  final String? teacherId;
  final String? teacherName;
  final String? schedule; // Ví dụ: "2-4-6", "3-5-7"

  const ClassFilterInfo({
    this.courseId,
    this.courseName,
    this.teacherId,
    this.teacherName,
    this.schedule,
  });
}

// Classes list loaded
class ClassesLoaded extends RegistrationState {
  final List<AdminClass> classes;
  final RegistrationInProgress currentRegistration;
  // Dữ liệu filter từ API
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> teachers;
  final List<String> schedules;
  // Filter đang áp dụng
  final ClassFilterInfo? appliedFilter;

  const ClassesLoaded({
    required this.classes,
    required this.currentRegistration,
    this.courses = const [],
    this.teachers = const [],
    this.schedules = const [],
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [
    classes,
    currentRegistration,
    courses,
    teachers,
    schedules,
    appliedFilter,
  ];

  List<AdminClass> get availableClasses => classes
      .where((c) => !c.isFull && c.status != ClassStatus.completed)
      .toList();

  ClassesLoaded copyWith({
    List<AdminClass>? classes,
    RegistrationInProgress? currentRegistration,
    List<Map<String, dynamic>>? courses,
    List<Map<String, dynamic>>? teachers,
    List<String>? schedules,
    ClassFilterInfo? appliedFilter,
    bool clearFilter = false,
  }) {
    return ClassesLoaded(
      classes: classes ?? this.classes,
      currentRegistration: currentRegistration ?? this.currentRegistration,
      courses: courses ?? this.courses,
      teachers: teachers ?? this.teachers,
      schedules: schedules ?? this.schedules,
      appliedFilter: clearFilter ? null : (appliedFilter ?? this.appliedFilter),
    );
  }
}

// Promotions loaded
class PromotionsLoaded extends RegistrationState {
  final List<Promotion> promotions;
  final RegistrationInProgress currentRegistration;

  const PromotionsLoaded({
    required this.promotions,
    required this.currentRegistration,
  });

  @override
  List<Object?> get props => [promotions, currentRegistration];

  /// Lọc khuyến mãi có thể áp dụng cho các khóa đã chọn
  List<Promotion> get validPromotions {
    final selectedCourseIds = currentRegistration.selectedCourseIds;
    return promotions.where((p) {
      // Kiểm tra khuyến mãi còn hiệu lực
      if (!p.isValid) return false;
      // Kiểm tra có thể áp dụng cho các khóa đã chọn
      return p.canApplyForCourses(selectedCourseIds);
    }).toList();
  }
}

// Registration submitted
class RegistrationSubmitted extends RegistrationState {
  final QuickRegistration registration;

  const RegistrationSubmitted(this.registration);

  @override
  List<Object?> get props => [registration];
}

// Registration submitting
class RegistrationSubmitting extends RegistrationState {
  const RegistrationSubmitting();
}
