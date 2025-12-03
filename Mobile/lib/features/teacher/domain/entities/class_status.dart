import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ClassStatus {
  ongoing,
  upcoming,
  completed,
}

extension ClassStatusExtension on ClassStatus {
  String get displayName {
    switch (this) {
      case ClassStatus.ongoing:
        return 'Đang diễn ra';
      case ClassStatus.upcoming:
        return 'Sắp diễn ra';
      case ClassStatus.completed:
        return 'Đã kết thúc';
    }
  }
  
  Color get color {
    switch (this) {
      case ClassStatus.ongoing:
        return AppColors.success;
      case ClassStatus.upcoming:
        return AppColors.info;
      case ClassStatus.completed:
        return AppColors.gray500;
    }
  }
  
  static ClassStatus fromString(String value) {
    return ClassStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClassStatus.ongoing,
    );
  }
}
