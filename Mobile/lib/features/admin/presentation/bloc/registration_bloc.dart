import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'registration_event.dart';
import 'registration_state.dart';

import '../../domain/entities/quick_registration.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/admin_repository.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AdminRepository? adminRepository;

  List<Map<String, dynamic>> _cachedCourses = [];

  List<Map<String, dynamic>> _cachedTeachers = [];

  List<AdminClass> _allClasses = [];

  RegistrationBloc({this.adminRepository})
    : super(const RegistrationInitial()) {
    on<InitializeRegistration>(_onInitializeRegistration);
    on<SwitchStudentMode>(_onSwitchStudentMode);
    on<UpdateStudentInfo>(_onUpdateStudentInfo);
    on<SelectStudent>(_onSelectStudent);
    on<SelectClass>(_onSelectClass);
    on<RemoveClass>(_onRemoveClass);
    on<ClearAllClasses>(_onClearAllClasses);

    on<LoadAvailableClasses>(_onLoadAvailableClasses, transformer: droppable());
    on<LoadPromotions>(_onLoadPromotions, transformer: droppable());
    on<SubmitRegistration>(_onSubmitRegistration, transformer: droppable());

    on<CalculateCartPreview>(
      _onCalculateCartPreview,
      transformer: restartable(),
    );

    on<FilterClasses>(_onFilterClasses);
    on<ClearClassFilter>(_onClearClassFilter);
    on<ApplyPromotion>(_onApplyPromotion);
    on<RemovePromotion>(_onRemovePromotion);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<UpdateNotes>(_onUpdateNotes);
    on<ClearCartPreviewError>(_onClearCartPreviewError);
  }

  Future<void> _onInitializeRegistration(
    InitializeRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
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
    ClassesLoaded? classesLoadedState;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      classesLoadedState = state as ClassesLoaded;
      current = classesLoadedState.currentRegistration;
    } else {
      return;
    }

    final newClass = SelectedClassInfo(
      classId: event.classId,
      className: event.className,
      courseId: event.courseId,
      courseName: event.courseName,
      tuitionFee: event.tuitionFee,
    );

    final existingClasses = List<SelectedClassInfo>.from(
      current.selectedClasses,
    );
    final alreadySelected = existingClasses.any(
      (c) => c.classId == event.classId,
    );

    if (alreadySelected) {
      existingClasses.removeWhere((c) => c.classId == event.classId);
    } else {
      existingClasses.add(newClass);
    }

    final updatedRegistration = current.copyWith(
      selectedClasses: existingClasses,
      clearPromotion: true,
      discount: 0,
      clearCartPreview: true,
    );

    if (classesLoadedState != null) {
      emit(
        classesLoadedState.copyWith(currentRegistration: updatedRegistration),
      );
    } else {
      emit(updatedRegistration);
    }

    if (existingClasses.isNotEmpty) {
      add(const CalculateCartPreview());
    }
  }

  Future<void> _onRemoveClass(
    RemoveClass event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    ClassesLoaded? classesLoadedState;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      classesLoadedState = state as ClassesLoaded;
      current = classesLoadedState.currentRegistration;
    } else {
      return;
    }

    final updatedClasses = List<SelectedClassInfo>.from(current.selectedClasses)
      ..removeWhere((c) => c.classId == event.classId);

    final updatedRegistration = current.copyWith(
      selectedClasses: updatedClasses,
      clearPromotion: true,
      discount: 0,
      clearCartPreview: true,
    );

    if (classesLoadedState != null) {
      emit(
        classesLoadedState.copyWith(currentRegistration: updatedRegistration),
      );
    } else {
      emit(updatedRegistration);
    }

    if (updatedClasses.isNotEmpty) {
      add(const CalculateCartPreview());
    }
  }

  Future<void> _onClearAllClasses(
    ClearAllClasses event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    ClassesLoaded? classesLoadedState;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      classesLoadedState = state as ClassesLoaded;
      current = classesLoadedState.currentRegistration;
    } else {
      return;
    }

    final updatedRegistration = current.copyWith(
      selectedClasses: [],
      clearPromotion: true,
      discount: 0,
      clearCartPreview: true,
    );

    if (classesLoadedState != null) {
      emit(
        classesLoadedState.copyWith(currentRegistration: updatedRegistration),
      );
    } else {
      emit(updatedRegistration);
    }
  }

  Future<void> _onLoadAvailableClasses(
    LoadAvailableClasses event,
    Emitter<RegistrationState> emit,
  ) async {
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
      List<Map<String, dynamic>> courses = [];
      List<Map<String, dynamic>> teachers = [];

      if (adminRepository != null) {
        try {
          final results = await Future.wait([
            adminRepository!.getClasses(),
            adminRepository!.getCategories(),
          ]);

          classes = results[0] as List<AdminClass>;
          courses = results[1] as List<Map<String, dynamic>>;

          final teacherSet = <String, Map<String, dynamic>>{};
          for (final c in classes) {
            if (c.teacherId != null && !teacherSet.containsKey(c.teacherId)) {
              teacherSet[c.teacherId!] = {
                'id': c.teacherId,
                'name': c.teacherName,
              };
            }
          }
          teachers = teacherSet.values.toList();
        } catch (e) {
          classes = _getMockClasses();
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        classes = _getMockClasses();
      }

      final scheduleSet = <String>{};
      for (final c in classes) {
        if (c.schedule.isNotEmpty) {
          scheduleSet.add(c.schedule);
        }
      }
      final schedules = scheduleSet.toList()..sort();

      _allClasses = classes;
      _cachedCourses = courses;
      _cachedTeachers = teachers;

      emit(
        ClassesLoaded(
          classes: classes,
          currentRegistration: savedState,
          courses: courses,
          teachers: teachers,
          schedules: schedules,
        ),
      );
    } catch (e) {
      emit(
        RegistrationError('Không thể tải danh sách lớp học: ${e.toString()}'),
      );
    }
  }

  Future<void> _onFilterClasses(
    FilterClasses event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! ClassesLoaded) return;

    final currentState = state as ClassesLoaded;

    List<AdminClass> filteredClasses = List.from(_allClasses);

    if (event.courseId != null && event.courseId!.isNotEmpty) {
      filteredClasses = filteredClasses
          .where(
            (c) =>
                c.courseId == event.courseId ||
                c.courseName.toLowerCase().contains(
                  _cachedCourses
                      .firstWhere(
                        (course) => course['id'].toString() == event.courseId,
                        orElse: () => {'name': ''},
                      )['name']
                      .toString()
                      .toLowerCase(),
                ),
          )
          .toList();
    }

    if (event.teacherId != null && event.teacherId!.isNotEmpty) {
      filteredClasses = filteredClasses
          .where((c) => c.teacherId == event.teacherId)
          .toList();
    }

    if (event.schedule != null && event.schedule!.isNotEmpty) {
      filteredClasses = filteredClasses
          .where((c) => c.schedule == event.schedule)
          .toList();
    }

    String? courseName;
    String? teacherName;
    if (event.courseId != null) {
      final course = _cachedCourses.firstWhere(
        (c) => c['id'].toString() == event.courseId,
        orElse: () => {},
      );
      courseName = course['name']?.toString();
    }
    if (event.teacherId != null) {
      final teacher = _cachedTeachers.firstWhere(
        (t) => t['id'].toString() == event.teacherId,
        orElse: () => {},
      );
      teacherName = teacher['name']?.toString();
    }

    emit(
      currentState.copyWith(
        classes: filteredClasses,
        appliedFilter: ClassFilterInfo(
          courseId: event.courseId,
          courseName: courseName,
          teacherId: event.teacherId,
          teacherName: teacherName,
          schedule: event.schedule,
        ),
      ),
    );
  }

  Future<void> _onClearClassFilter(
    ClearClassFilter event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! ClassesLoaded) return;

    final currentState = state as ClassesLoaded;

    emit(currentState.copyWith(classes: _allClasses, clearFilter: true));
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

      if (adminRepository != null) {
        try {
          promotion = await adminRepository!.validatePromotionCode(
            event.promotionCode,
          );
        } catch (e) {
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
      emit(current);
    }
  }

  Future<void> _onLoadPromotions(
    LoadPromotions event,
    Emitter<RegistrationState> emit,
  ) async {
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

    final courseId = event.courseId ?? savedState.courseId;

    emit(const RegistrationLoading());

    try {
      List<Promotion> promotions;

      if (adminRepository != null) {
        try {
          if (courseId != null) {
            promotions = await adminRepository!.getPromotionsByCourse(courseId);
          } else {
            promotions = await adminRepository!.getActivePromotions();
          }
        } catch (e) {
          promotions = _getMockPromotions();
        }
      } else {
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

          if (current.isNewStudent) {
            if (current.studentName == null || current.phoneNumber == null) {
              throw Exception('Vui lòng nhập tên và số điện thoại học viên');
            }

            final createStudentResponse = await adminRepository!.createStudent(
              name: current.studentName!,
              phoneNumber: current.phoneNumber!,
              email: current.email,
            );

            studentIdInt =
                createStudentResponse['studentId'] ??
                createStudentResponse['id'] ??
                createStudentResponse['mahocvien'] ??
                0;

            if (studentIdInt == 0) {
              throw Exception('Không thể tạo học viên mới');
            }
          } else {
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

          int paymentMethodId;
          switch (current.paymentMethod) {
            case PaymentMethod.cash:
              paymentMethodId = 1; // Tiền mặt
              break;
            case PaymentMethod.transfer:
              paymentMethodId = 3; // Chuyển khoản ngân hàng
              break;
            case PaymentMethod.vnpay:
              paymentMethodId = 2; // VNPay
              break;
            case PaymentMethod.card:
              paymentMethodId = 3; // Chuyển khoản ngân hàng (fallback)
              break;
          }

          final response = await adminRepository!.registerCourses(
            studentId: studentIdInt,
            classIds: classIds,
            paymentMethodId: paymentMethodId,
            notes: current.notes,
          );

          final invoiceId =
              response['invoiceId'] ??
              response['mahoadon'] ??
              DateTime.now().millisecondsSinceEpoch.toString();

          final invoiceIdInt = int.tryParse(invoiceId.toString());

          // Nếu thanh toán tiền mặt hoặc chuyển khoản thì tự động xác nhận thanh toán và gửi email hóa đơn
          if (invoiceIdInt != null &&
              (current.paymentMethod == PaymentMethod.cash ||
                  current.paymentMethod == PaymentMethod.transfer)) {
            try {
              await adminRepository!.confirmCashPayment(invoiceIdInt);
            } catch (e) {
              // Không fail nếu gửi email lỗi, chỉ log warning
              // ignore: avoid_print
              print('Warning: Failed to confirm cash payment: $e');
            }
          }

          final registration = QuickRegistration(
            id: invoiceId.toString(),
            studentName: current.studentName!,
            studentGroup: current.studentGroup,
            phoneNumber: current.phoneNumber!,
            email: current.email,
            classId: current.selectedClasses.map((c) => c.classId).join(','),
            className: current.className ?? '',
            tuitionFee: current.cartPreview != null
                ? current.totalTuitionFee
                : current.tuitionFee,
            discount: current.totalDiscount,
            finalAmount: current.cartPreview != null
                ? current.totalAmount
                : null,
            promotionCode: current.promotionCode,
            paymentMethod: current.paymentMethod,
            notes: current.notes,
            registrationDate: DateTime.now(),
            status: 'completed',
            invoiceId: invoiceIdInt,
          );

          emit(RegistrationSubmitted(registration));
          return;
        } catch (e) {
          emit(RegistrationError('Đăng ký thất bại: ${e.toString()}'));
          emit(current);
          return;
        }
      }

      await Future.delayed(const Duration(seconds: 1));

      final registration = QuickRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentName: current.studentName ?? 'Unknown',
        studentGroup: current.studentGroup,
        phoneNumber: current.phoneNumber ?? '',
        email: current.email,
        classId: current.selectedClasses.map((c) => c.classId).join(','),
        className: current.className ?? '',
        tuitionFee: current.cartPreview != null
            ? current.totalTuitionFee
            : current.tuitionFee,
        discount: current.totalDiscount,
        finalAmount: current.cartPreview != null ? current.totalAmount : null,
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
        tuitionFee: 4500000,
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
        tuitionFee: 5500000,
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
        tuitionFee: 3000000,
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

  Future<void> _onCalculateCartPreview(
    CalculateCartPreview event,
    Emitter<RegistrationState> emit,
  ) async {
    RegistrationInProgress current;
    ClassesLoaded? classesLoadedState;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      classesLoadedState = state as ClassesLoaded;
      current = classesLoadedState.currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }

    if (current.selectedClasses.isEmpty) {
      return;
    }

    final calculatingState = current.copyWith(isCalculatingPreview: true);
    if (classesLoadedState != null) {
      emit(classesLoadedState.copyWith(currentRegistration: calculatingState));
    } else {
      emit(calculatingState);
    }

    try {
      if (adminRepository != null) {
        final classIds = current.selectedClasses
            .map((c) {
              return c.classId.replaceAll(RegExp(r'[^0-9]'), '');
            })
            .where((id) => id.isNotEmpty)
            .toList();

        if (classIds.isEmpty) {
          throw Exception('Không có lớp học hợp lệ để tính toán');
        }

        String? studentIdForPreview;
        if (!current.isNewStudent && current.studentId != null) {
          studentIdForPreview = current.studentId!.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
          if (studentIdForPreview.isEmpty) studentIdForPreview = null;
        }

        final cartPreview = await adminRepository!.previewCart(
          classIds,
          studentId: studentIdForPreview,
        );

        final updatedRegistration = current.copyWith(
          cartPreview: cartPreview,
          isCalculatingPreview: false,

          discount: cartPreview.summary.totalDiscountAmount,
        );

        if (classesLoadedState != null) {
          emit(
            classesLoadedState.copyWith(
              currentRegistration: updatedRegistration,
            ),
          );
        } else {
          emit(updatedRegistration);
        }
      } else {
        final updatedRegistration = current.copyWith(
          isCalculatingPreview: false,
        );
        if (classesLoadedState != null) {
          emit(
            classesLoadedState.copyWith(
              currentRegistration: updatedRegistration,
            ),
          );
        } else {
          emit(updatedRegistration);
        }
      }
    } catch (e) {
      final updatedRegistration = current.copyWith(
        isCalculatingPreview: false,
        cartPreviewError: e.toString().replaceFirst('Exception: ', ''),
      );
      if (classesLoadedState != null) {
        emit(
          classesLoadedState.copyWith(currentRegistration: updatedRegistration),
        );
      } else {
        emit(updatedRegistration);
      }
    }
  }

  void _onClearCartPreviewError(
    ClearCartPreviewError event,
    Emitter<RegistrationState> emit,
  ) {
    RegistrationInProgress current;
    ClassesLoaded? classesLoadedState;

    if (state is RegistrationInProgress) {
      current = state as RegistrationInProgress;
    } else if (state is ClassesLoaded) {
      classesLoadedState = state as ClassesLoaded;
      current = classesLoadedState.currentRegistration;
    } else if (state is PromotionsLoaded) {
      current = (state as PromotionsLoaded).currentRegistration;
    } else {
      return;
    }

    final updatedRegistration = current.copyWith(clearCartPreviewError: true);
    if (classesLoadedState != null) {
      emit(
        classesLoadedState.copyWith(currentRegistration: updatedRegistration),
      );
    } else {
      emit(updatedRegistration);
    }
  }
}
