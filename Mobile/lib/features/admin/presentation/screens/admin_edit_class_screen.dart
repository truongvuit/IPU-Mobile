import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../../domain/entities/admin_class.dart';

class AdminEditClassScreen extends StatefulWidget {
  final AdminClass classInfo;

  const AdminEditClassScreen({super.key, required this.classInfo});

  @override
  State<AdminEditClassScreen> createState() => _AdminEditClassScreenState();
}

class _AdminEditClassScreenState extends State<AdminEditClassScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _classNameController;
  late TextEditingController _capacityController;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedRoom;
  final Set<int> _selectedDays = {};

  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = true;

  
  bool get _isClassStarted {
    return widget.classInfo.startDate.isBefore(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.classInfo.name);
    _capacityController = TextEditingController(
      text: widget.classInfo.maxStudents.toString(),
    );
    _startDate = widget.classInfo.startDate;

    
    _parseTimeRange(widget.classInfo.timeRange);

    
    _parseSchedule(widget.classInfo.schedule);

    
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await context.read<AdminBloc>().adminRepository.getRooms();
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
        
        
        final currentRoom = widget.classInfo.room;
        final roomExists = _rooms.any((r) => r['name'] == currentRoom);
        _selectedRoom = roomExists ? currentRoom : null;
      });
    } catch (e) {
      setState(() {
        _isLoadingRooms = false;
        
        _rooms = [
          {'id': 1, 'name': 'Phòng 101'},
          {'id': 2, 'name': 'Phòng 102'},
          {'id': 3, 'name': 'Phòng 103'},
        ];
      });
    }
  }

  void _parseTimeRange(String timeRange) {
    try {
      final parts = timeRange.split(' - ');
      if (parts.length == 2) {
        final startParts = parts[0].split(':');
        final endParts = parts[1].split(':');

        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      }
    } catch (e) {
      
      _startTime = const TimeOfDay(hour: 18, minute: 0);
      _endTime = const TimeOfDay(hour: 20, minute: 0);
    }
  }

  void _parseSchedule(String schedule) {
    // Clear trước khi parse
    _selectedDays.clear();
    
    // Format 1: "T2-T4-T6" hoặc "T2T4T6"
    if (schedule.contains('T2') || schedule.contains('Thứ 2')) _selectedDays.add(1);
    if (schedule.contains('T3') || schedule.contains('Thứ 3')) _selectedDays.add(2);
    if (schedule.contains('T4') || schedule.contains('Thứ 4')) _selectedDays.add(3);
    if (schedule.contains('T5') || schedule.contains('Thứ 5')) _selectedDays.add(4);
    if (schedule.contains('T6') || schedule.contains('Thứ 6')) _selectedDays.add(5);
    if (schedule.contains('T7') || schedule.contains('Thứ 7')) _selectedDays.add(6);
    if (schedule.contains('CN') || schedule.contains('Chủ nhật')) _selectedDays.add(7);
    
    // Format 2: "3-5-7" hoặc "2-4-6" (chỉ số ngày trong tuần, 2=Thứ 2, 7=CN)
    if (_selectedDays.isEmpty) {
      // Parse theo format số, ví dụ "3-5-7"
      final parts = schedule.split('-');
      for (final part in parts) {
        final dayNum = int.tryParse(part.trim());
        if (dayNum != null && dayNum >= 2 && dayNum <= 8) {
          // dayNum: 2=Thứ 2, 3=Thứ 3, ..., 7=Thứ 7, 8=CN
          // Chuyển thành: 1=Thứ 2, 2=Thứ 3, ..., 6=Thứ 7, 7=CN
          _selectedDays.add(dayNum - 1);
        }
      }
    }
  }

  String _getDayLabel(int day) {
    switch (day) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  String _formatSchedule() {
    if (_selectedDays.isEmpty) return '';

    final sortedDays = _selectedDays.toList()..sort();
    return sortedDays
        .map((d) {
          if (d == 7) return 'CN';
          return 'T$d';
        })
        .join('-');
  }

  String _formatTimeRange() {
    if (_startTime == null || _endTime == null) return '';

    return '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} - ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    
    if (_isClassStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể thay đổi ngày khai giảng khi lớp đã bắt đầu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)), 
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn ngày khai giảng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 18, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 20, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _incrementCapacity() {
    final current = int.tryParse(_capacityController.text) ?? 0;
    if (current < 30) {
      _capacityController.text = (current + 1).toString();
    }
  }

  void _decrementCapacity() {
    final current = int.tryParse(_capacityController.text) ?? 0;
    if (current > widget.classInfo.totalStudents) {
      _capacityController.text = (current - 1).toString();
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updates = {
        'name': _classNameController.text,
        'startDate': _startDate?.toIso8601String(),
        'schedule': _formatSchedule(),
        'timeRange': _formatTimeRange(),
        'room': _selectedRoom,
        'maxStudents':
            int.tryParse(_capacityController.text) ??
            widget.classInfo.maxStudents,
      };

      context.read<AdminBloc>().add(
        UpdateClass(classId: widget.classInfo.id, updates: updates),
      );

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thay đổi'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Cập nhật thông tin lớp học')),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is ClassUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật lớp học thành công'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildLabel('Tên lớp'),
                SizedBox(height: AppSizes.p8),
                TextFormField(
                  controller: _classNameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên lớp học',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên lớp';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.p20),

                
                _buildLabel('Ngày khai giảng'),
                SizedBox(height: AppSizes.p8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'Chọn ngày khai giảng',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _startDate != null
                                ? null
                                : (isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20.sp,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.p20),

                
                _buildLabel('Lịch học'),
                SizedBox(height: AppSizes.p8),
                Wrap(
                  spacing: AppSizes.p8,
                  runSpacing: AppSizes.p8,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final isSelected = _selectedDays.contains(day);

                    return ChoiceChip(
                      label: Text(_getDayLabel(day)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    );
                  }),
                ),
                SizedBox(height: AppSizes.p20),

                
                _buildLabel('Khung giờ'),
                SizedBox(height: AppSizes.p8),
                InkWell(
                  onTap: () => _selectTime(true),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTimeRange()),
                        Icon(
                          Icons.access_time,
                          size: 20.sp,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.p20),

                
                _buildLabel('Phòng học'),
                SizedBox(height: AppSizes.p8),
                _isLoadingRooms
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.p16,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text('Đang tải danh sách phòng...'),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedRoom,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _rooms.map((room) {
                          final roomName = room['name'] as String;
                          return DropdownMenuItem(value: roomName, child: Text(roomName));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoom = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn phòng học';
                          }
                          return null;
                        },
                      ),
                SizedBox(height: AppSizes.p20),

                
                _buildLabel('Sức chứa'),
                SizedBox(height: AppSizes.p8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập sức chứa';
                          }
                          final capacity = int.tryParse(value);
                          if (capacity == null) {
                            return 'Sức chứa phải là số';
                          }
                          if (capacity < widget.classInfo.totalStudents) {
                            return 'Sức chứa không được nhỏ hơn số học viên hiện tại (${widget.classInfo.totalStudents})';
                          }
                          if (capacity > 30) {
                            return 'Sức chứa không được vượt quá 30 học viên';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: AppSizes.p12),
                    IconButton(
                      onPressed: _decrementCapacity,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.error,
                    ),
                    IconButton(
                      onPressed: _incrementCapacity,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),

                
                if (int.tryParse(_capacityController.text) != null &&
                    int.parse(_capacityController.text) > 30)
                  Padding(
                    padding: EdgeInsets.only(top: AppSizes.p8),
                    child: Text(
                      'Sức chứa không được vượt quá 30 học viên',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),

                SizedBox(height: 32.h),

                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text(
                      'Lưu thay đổi',
                      style: TextStyle(
                        fontSize: AppSizes.textBase,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: AppSizes.textBase,
      ),
    );
  }
}
