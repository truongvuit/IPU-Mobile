import 'package:flutter_bloc/flutter_bloc.dart';

import 'registration_event.dart';
import 'registration_state.dart';

import '../../domain/entities/quick_registration.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/admin_repository.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AdminRepository? adminRepository;

  RegistrationBloc({this.adminRepository})
    : super(const RegistrationInitial()) {
    on<InitializeRegistration>(_onInitializeRegistration);
    on<SwitchStudentMode>(_onSwitchStudentMode);
    on<UpdateStudentInfo>(_onUpdateStudentInfo);
    on<SelectStudent>(_onSelectStudent);
    on<SelectClass>(_onSelectClass);
    on<RemoveClass>(_onRemoveClass);
    on<ClearAllClasses>(_onClearAllClasses);
    on<LoadAvailableClasses>(_onLoadAvailableClasses);
    on<ApplyPromotion>(_onApplyPromotion);
    on<LoadPromotions>(_onLoadPromotions);
    on<RemovePromotion>(_onRemovePromotion);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<UpdateNotes>(_onUpdateNotes);
    on<SubmitRegistration>(_onSubmitRegistration);
  }

  Future<void> _onInitializeRegistration(
    InitializeRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    // Mặc định là học viên mới (phù hợp cho đăng ký nhanh tại quầy)
    emit(const RegistrationInProgress(isNewStudent: true));
  }

  Future<void> _onSwitchStudentMode(
    SwitchStudentMode event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }
    
    // Xóa thông tin học viên cũ khi chuyển mode
    emit(
      current.copyWith(isNewStudent: event.isNewStudent, clearStudent: true),
    );
  }

  Future<void> _onUpdateStudentInfo(
    UpdateStudentInfo event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }
    
    emit(
      current.copyWith(
        studentId: event.studentId,
        studentName: event.studentName,
        studentGroup: event.studentGroup,
        phoneNumber: event.phoneNumber,
        email: event.email,
      ),
    );
  }

  Future<void> _onSelectStudent(
    SelectStudent event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }
    
    emit(
      current.copyWith(
        isNewStudent: false,
        studentId: event.studentId,
        studentName: event.studentName,
        phoneNumber: event.phoneNumber,
        email: event.email,
      ),
    );
  }

  Future<void> _onSelectClass(
    SelectClass event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    List<AdminClass>? loadedClasses;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
      loadedClasses = (state as ClassesLoaded).classes;
    } else {
      return;
    }

    // Tạo thông tin lớp mới
    final newClass = SelectedClassInfo(
      classId: event.classId,
      className: event.className,
      courseId: event.courseId,
      courseName: event.courseName,
      tuitionFee: event.tuitionFee,
    );

    // Kiểm tra xem lớp đã được chọn chưa
    final existingClasses = List<SelectedClassInfo>.from(
      current.selectedClasses,
    );
    final alreadySelected = existingClasses.any(
      (c) => c.classId == event.classId,
    );

    if (alreadySelected) {
      // Nếu đã chọn rồi, xóa khỏi danh sách (toggle)
      existingClasses.removeWhere((c) => c.classId == event.classId);
    } else {
      // Nếu chưa chọn, thêm vào danh sách
      existingClasses.add(newClass);
    }

    // Tạo state mới với danh sách lớp đã cập nhật
    final updatedRegistration = current.copyWith(
      selectedClasses: existingClasses,
      clearPromotion: true,
      discount: 0,
    );

    // Nếu đang ở ClassesLoaded, giữ nguyên state đó với currentRegistration mới
    if (loadedClasses != null) {
      emit(
        ClassesLoaded(
          classes: loadedClasses,
          currentRegistration: updatedRegistration,
        ),
      );
    } else {
      emit(updatedRegistration);
    }
  }

  Future<void> _onRemoveClass(
    RemoveClass event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    List<AdminClass>? loadedClasses;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
      loadedClasses = (state as ClassesLoaded).classes;
    } else {
      return;
    }

    final updatedClasses = List<SelectedClassInfo>.from(current.selectedClasses)
      ..removeWhere((c) => c.classId == event.classId);

    final updatedRegistration = current.copyWith(
      selectedClasses: updatedClasses,
      clearPromotion: true,
      discount: 0,
    );

    // Nếu đang ở ClassesLoaded, giữ nguyên state đó
    if (loadedClasses != null) {
      emit(
        ClassesLoaded(
          classes: loadedClasses,
          currentRegistration: updatedRegistration,
        ),
      );
    } else {
      emit(updatedRegistration);
    }
  }

  Future<void> _onClearAllClasses(
    ClearAllClasses event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    List<AdminClass>? loadedClasses;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
      loadedClasses = (state as ClassesLoaded).classes;
    } else {
      return;
    }

    final updatedRegistration = current.copyWith(
      selectedClasses: [],
      clearPromotion: true,
      discount: 0,
    );

    // Nếu đang ở ClassesLoaded, giữ nguyên state đó
    if (loadedClasses != null) {
      emit(
        ClassesLoaded(
          classes: loadedClasses,
          currentRegistration: updatedRegistration,
        ),
      );
    } else {
      emit(updatedRegistration);
    }
  }

  Future<void> _onLoadAvailableClasses(
    LoadAvailableClasses event,
    Emitter<RegistrationState> emit,
  ) async {
    // Lưu current state trước khi emit loading
    RegistrationInProgress savedState;
    if (state is RegistrationInProgress) {
      savedState = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      savedState = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      savedState = (state as PromotionsLoaded).currentRegistration;
    } else {
      savedState = const RegistrationInProgress();
    }

    emit(const RegistrationLoading());

    try {
      List<AdminClass> classes;

      // Sử dụng API thực nếu có repository
      if (adminRepository != null) {
        try {
          classes = await adminRepository!.getClasses();
        } catch (e) {
          // Fallback to mock nếu lỗi
          classes = _getMockClasses();
        }
      } else {
        // Fallback to mock data
        await Future.delayed(const Duration(milliseconds: 500));
        classes = _getMockClasses();
      }

      emit(ClassesLoaded(classes: classes, currentRegistration: savedState));
    } catch (e) {
      emit(
        RegistrationError('Không thể tải danh sách lớp học: ${e.toString()}'),
      );
    }
  }

  Future<void> _onApplyPromotion(
    ApplyPromotion event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! RegistrationInProgress && state is! PromotionsLoaded) return;

    RegistrationInProgress current;
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }

    try {
      Promotion? promotion;

      // Thử validate từ API trước
      if (adminRepository != null) {
        try {
          promotion = await adminRepository!.validatePromotionCode(
            event.promotionCode,
          );
        } catch (e) {
          // Fallback to local search in loaded promotions
          if (state is PromotionsLoaded) {
            final loadedPromotions = (state as PromotionsLoaded).promotions;
            promotion = loadedPromotions.firstWhere(
              (p) => p.code.toUpperCase() == event.promotionCode.toUpperCase(),
              orElse: () => throw Exception('Mã khuyến mãi không hợp lệ'),
            );
          } else {
            throw Exception('Mã khuyến mãi không hợp lệ');
          }
        }
      } else {
        // Fallback to mock
        promotion = _getMockPromotions().firstWhere(
          (p) => p.code.toUpperCase() == event.promotionCode.toUpperCase(),
          orElse: () => throw Exception('Mã khuyến mãi không hợp lệ'),
        );
      }

      final discount = promotion.calculateDiscount(current.tuitionFee);

      emit(
        current.copyWith(
          promotionCode: promotion.code,
          appliedPromotion: promotion,
          discount: discount,
        ),
      );
    } catch (e) {
      emit(RegistrationError(e.toString()));
      emit(current); // Return to previous state
    }
  }

  Future<void> _onLoadPromotions(
    LoadPromotions event,
    Emitter<RegistrationState> emit,
  ) async {
    // Lưu current state trước khi emit loading
    RegistrationInProgress savedState;
    if (state is RegistrationInProgress) {
      savedState = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      savedState = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      savedState = (state as PromotionsLoaded).currentRegistration;
    } else {
      savedState = const RegistrationInProgress();
    }

    // Lấy courseId từ event hoặc từ state đã lưu
    final courseId = event.courseId ?? savedState.courseId;

    emit(const RegistrationLoading());

    try {
      List<Promotion> promotions;

      // Sử dụng API thực nếu có repository
      if (adminRepository != null) {
        try {
          // Nếu có courseId, lấy khuyến mãi theo khóa học
          if (courseId != null) {
            promotions = await adminRepository!.getPromotionsByCourse(courseId);
          } else {
            // Nếu không có courseId, lấy tất cả khuyến mãi active
            promotions = await adminRepository!.getActivePromotions();
          }
        } catch (e) {
          // Fallback to mock nếu API lỗi
          promotions = _getMockPromotions();
        }
      } else {
        // Fallback to mock data
        await Future.delayed(const Duration(milliseconds: 500));
        promotions = _getMockPromotions();
      }

      emit(
        PromotionsLoaded(
          promotions: promotions,
          currentRegistration: savedState,
        ),
      );
    } catch (e) {
      emit(
        RegistrationError(
          'Không thể tải danh sách khuyến mãi: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRemovePromotion(
    RemovePromotion event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is RegistrationInProgress) {
      final current = state as RegistrationInProgress;
      emit(current.copyWith(clearPromotion: true, discount: 0));
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }
    
    emit(current.copyWith(paymentMethod: event.paymentMethod));
  }

  Future<void> _onUpdateNotes(
    UpdateNotes event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }
    
    emit(current.copyWith(notes: event.notes));
  }

  Future<void> _onSubmitRegistration(
    SubmitRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    
    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      current = (state as ClassesLoaded).currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }

    if (!current.isValid) {
      emit(
        const RegistrationError(
          'Vui lòng điền đầy đủ thông tin học viên và chọn lớp học',
        ),
      );
      emit(current);
      return;
    }

    emit(const RegistrationSubmitting());

    try {
      if (adminRepository != null) {
        try {
          int studentIdInt;

          // Nếu là học viên mới, tạo học viên trước
          if (current.isNewStudent) {
            // Kiểm tra thông tin học viên mới
            if (current.studentName == null || current.phoneNumber == null) {
              throw Exception('Vui lòng nhập tên và số điện thoại học viên');
            }

            // Gọi API tạo học viên mới
            final createStudentResponse = await adminRepository!.createStudent(
              name: current.studentName!,
              phoneNumber: current.phoneNumber!,
              email: current.email,
            );

            // Parse studentId từ response
            // BE trả về StudentInfo với trường studentId
            studentIdInt =
                createStudentResponse['studentId'] ??
                createStudentResponse['id'] ??
                createStudentResponse['mahocvien'] ??
                0;

            if (studentIdInt == 0) {
              throw Exception('Không thể tạo học viên mới');
            }
          } else {
            // Học viên cũ - parse studentId từ state
            if (current.studentId == null) {
              throw Exception('Vui lòng chọn học viên');
            }
            studentIdInt =
                int.tryParse(
                  current.studentId!.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            if (studentIdInt == 0) {
              throw Exception('ID học viên không hợp lệ');
            }
          }

          // Parse tất cả classIds sang List<int>
          final classIds = current.selectedClasses.map((c) {
            final parsed =
                int.tryParse(c.classId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            if (parsed == 0) {
              throw Exception('ID lớp học không hợp lệ: ${c.className}');
            }
            return parsed;
          }).toList();

          if (classIds.isEmpty) {
            throw Exception('Vui lòng chọn ít nhất một lớp học');
          }

          // Map PaymentMethod enum sang int cho BE
          // 1: Tiền mặt, 2: Chuyển khoản, 3: Quét thẻ
          int paymentMethodId;
          switch (current.paymentMethod) {
            case PaymentMethod.cash:
              paymentMethodId = 1;
              break;
            case PaymentMethod.transfer:
              paymentMethodId = 2;
              break;
            case PaymentMethod.card:
              paymentMethodId = 3;
              break;
          }

          // Gọi API đăng ký khóa học (với danh sách nhiều lớp)
          final response = await adminRepository!.registerCourses(
            studentId: studentIdInt,
            classIds: classIds,
            paymentMethodId: paymentMethodId,
            notes: current.notes,
          );

          // Parse response từ BE để hiển thị kết quả
          final invoiceId =
              response['invoiceId'] ??
              response['mahoadon'] ??
              DateTime.now().millisecondsSinceEpoch.toString();

          final registration = QuickRegistration(
            id: invoiceId.toString(),
            studentName: current.studentName!,
            studentGroup: current.studentGroup,
            phoneNumber: current.phoneNumber!,
            email: current.email,
            classId: current.selectedClasses.map((c) => c.classId).join(','),
            className: current.className ?? '',
            tuitionFee: current.tuitionFee,
            discount: current.discount,
            promotionCode: current.promotionCode,
            paymentMethod: current.paymentMethod,
            notes: current.notes,
            registrationDate: DateTime.now(),
            status: 'completed',
          );

          emit(RegistrationSubmitted(registration));
          return;
        } catch (e) {
          // Nếu API lỗi, hiển thị lỗi thay vì fallback
          emit(RegistrationError('Đăng ký thất bại: ${e.toString()}'));
          emit(current);
          return;
        }
      }

      // Fallback: tạo mock registration khi không có API
      await Future.delayed(const Duration(seconds: 1));

      final registration = QuickRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentName: current.studentName ?? 'Unknown',
        studentGroup: current.studentGroup,
        phoneNumber: current.phoneNumber ?? '',
        email: current.email,
        classId: current.selectedClasses.map((c) => c.classId).join(','),
        className: current.className ?? '',
        tuitionFee: current.tuitionFee,
        discount: current.discount,
        promotionCode: current.promotionCode,
        paymentMethod: current.paymentMethod,
        notes: current.notes,
        registrationDate: DateTime.now(),
        status: 'completed',
      );

      emit(RegistrationSubmitted(registration));
    } catch (e) {
      emit(RegistrationError('Không thể đăng ký: ${e.toString()}'));
      emit(current);
    }
  }

  // Mock data - Replace with actual repository calls
  List<AdminClass> _getMockClasses() {
    return [
      AdminClass(
        id: '1',
        name: 'IELTS Foundation 5.0',
        courseName: 'IELTS Foundation',
        status: ClassStatus.upcoming,
        schedule: 'Thứ 5-6-7',
        timeRange: '19:00 - 20:30',
        room: 'Phòng A101',
        teacherName: 'Ms. Alines',
        startDate: DateTime(2024, 12, 25),
        totalStudents: 13,
        maxStudents: 15,
        tuitionFee: 4500000, // 4.5 triệu
      ),
      AdminClass(
        id: '2',
        name: 'TOEIC Intensive 750+',
        courseName: 'TOEIC Intensive',
        status: ClassStatus.ongoing,
        schedule: 'Thứ 2-4-6',
        timeRange: '18:00 - 19:30',
        room: 'Phòng B203',
        teacherName: 'Ms. Tram',
        startDate: DateTime(2024, 11, 1),
        totalStudents: 8,
        maxStudents: 15,
        tuitionFee: 5500000, // 5.5 triệu
      ),
      AdminClass(
        id: '3',
        name: 'Giao tiếp cơ bản',
        courseName: 'Communication',
        status: ClassStatus.upcoming,
        schedule: 'Thứ 3-5',
        timeRange: '20:30 - 21:30',
        room: 'Phòng C101',
        teacherName: 'Ms. Gabby',
        startDate: DateTime(2024, 12, 15),
        totalStudents: 15,
        maxStudents: 15,
        tuitionFee: 3000000, // 3 triệu
      ),
    ];
  }

  List<Promotion> _getMockPromotions() {
    return [
      Promotion(
        id: '1',
        code: 'CHAOMUNG2025',
        title: 'Chào mừng năm mới 2025',
        description: 'Giảm 15% cho học viên đăng ký khóa học đầu tiên',
        discountType: DiscountType.percentage,
        discountValue: 15,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: PromotionStatus.active,
        usageCount: 0,
      ),
      Promotion(
        id: '2',
        code: 'SUMMER2025',
        title: 'Summer Sale 2025',
        description: 'Giảm 500,000đ cho khóa học mùa hè',
        discountType: DiscountType.fixedAmount,
        discountValue: 500000,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 8, 31),
        status: PromotionStatus.active,
        usageCount: 0,
      ),
      Promotion(
        id: '3',
        code: 'GIAMGIA10',
        title: 'Ưu đãi giảm 10%',
        description: 'Giảm ngay 10% học phí cho mọi khóa học',
        discountType: DiscountType.percentage,
        discountValue: 10,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        status: PromotionStatus.active,
        usageLimit: 100,
        usageCount: 25,
      ),
    ];
  }
}
