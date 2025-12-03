import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/api/dio_client.dart';
import '../../../domain/entities/course_detail.dart';
import 'package:dio/dio.dart';

/// Screen chỉnh sửa khóa học cho Admin
class AdminCourseEditScreen extends StatefulWidget {
  final CourseDetail course;

  const AdminCourseEditScreen({super.key, required this.course});

  @override
  State<AdminCourseEditScreen> createState() => _AdminCourseEditScreenState();
}

class _AdminCourseEditScreenState extends State<AdminCourseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  bool _isUploadingImage = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _totalHoursController;
  late TextEditingController _tuitionFeeController;
  late TextEditingController _videoUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _entryRequirementController;
  late TextEditingController _exitRequirementController;

  String? _selectedCategoryId;
  bool _isActive = true;
  
  // Image
  String? _imageUrl;
  File? _selectedImage;

  List<Map<String, dynamic>> _categories = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Gọi API lấy danh sách danh mục
      final dioClient = getIt<DioClient>();
      final response = await dioClient.get('/categories');
      
      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _categories = data.map((item) => {
              'id': item['id'].toString(),
              'name': item['name'] ?? '',
            }).toList();
            
            // Đảm bảo selectedCategoryId nằm trong danh sách
            if (_selectedCategoryId != null && 
                !_categories.any((c) => c['id'] == _selectedCategoryId)) {
              _selectedCategoryId = null;
            }
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      // Nếu lỗi thì dùng danh sách mặc định
      if (mounted) {
        setState(() {
          _categories = [
            {'id': '1', 'name': 'Tiếng Anh Giao Tiếp'},
            {'id': '2', 'name': 'TOEIC'},
            {'id': '3', 'name': 'IELTS'},
            {'id': '4', 'name': 'Tiếng Anh Thiếu Nhi'},
          ];
          if (_selectedCategoryId != null && 
              !_categories.any((c) => c['id'] == _selectedCategoryId)) {
            _selectedCategoryId = null;
          }
          _isLoadingCategories = false;
        });
      }
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.course.name);
    _totalHoursController = TextEditingController(
      text: widget.course.totalHours.toString(),
    );
    _tuitionFeeController = TextEditingController(
      text: widget.course.tuitionFee.toInt().toString(),
    );
    _videoUrlController = TextEditingController(text: widget.course.videoUrl);
    _descriptionController = TextEditingController(
      text: widget.course.description,
    );
    _entryRequirementController = TextEditingController(
      text: widget.course.entryRequirement,
    );
    _exitRequirementController = TextEditingController(
      text: widget.course.exitRequirement,
    );

    _selectedCategoryId = widget.course.categoryId;
    _isActive = widget.course.isActive;
    _imageUrl = widget.course.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalHoursController.dispose();
    _tuitionFeeController.dispose();
    _videoUrlController.dispose();
    _descriptionController.dispose();
    _entryRequirementController.dispose();
    _exitRequirementController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chụp ảnh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_selectedImage != null || _imageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Xóa ảnh', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _imageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _imageUrl;
    
    setState(() => _isUploadingImage = true);
    
    try {
      final dioClient = getIt<DioClient>();
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ),
      });
      
      final response = await dioClient.post('/files', data: formData);
      
      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final fileUrl = response.data['data']['fileUrl'] as String;
        return fileUrl;
      }
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image if selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadImage();
        if (finalImageUrl == null && _selectedImage != null) {
          throw Exception('Không thể upload ảnh');
        }
      }

      // Prepare request data matching CourseUpdateRequest
      final requestData = {
        'courseName': _nameController.text.trim(),
        'studyHours': int.parse(_totalHoursController.text.trim()),
        'tuitionFee': double.parse(_tuitionFeeController.text.trim()),
        'video': _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
        'image': finalImageUrl,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'entryLevel': _entryRequirementController.text.trim().isEmpty
            ? null
            : _entryRequirementController.text.trim(),
        'targetLevel': _exitRequirementController.text.trim().isEmpty
            ? null
            : _exitRequirementController.text.trim(),
        'categoryId': _selectedCategoryId != null 
            ? int.tryParse(_selectedCategoryId!) 
            : null,
      };

      // Call API
      final dioClient = getIt<DioClient>();
      final response = await dioClient.put(
        '/courses/${widget.course.id}',
        data: requestData,
      );

      if (!mounted) return;
      
      if (response.statusCode == 200 && response.data['code'] == 1000) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật khóa học thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Cập nhật thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chỉnh sửa khóa học'),
        actions: [
          if (_isLoading || _isUploadingImage)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveCourse,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSizes.p20, 
              AppSizes.p20, 
              AppSizes.p20, 
              AppSizes.p20 + bottomPadding + 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin cơ bản', isDark),
                SizedBox(height: AppSizes.p16),

                // Course name
                TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên khóa học *',
                  hintText: 'Nhập tên khóa học',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên khóa học';
                  }
                  if (value.trim().length < 3) {
                    return 'Tên khóa học phải có ít nhất 3 ký tự';
                  }
                  return null;
                },
                maxLength: 200,
              ),
              SizedBox(height: AppSizes.p16),

              // Category dropdown
              _isLoadingCategories
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _categories.any((c) => c['id'] == _selectedCategoryId) 
                          ? _selectedCategoryId 
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      hint: const Text('Chọn danh mục'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'] as String,
                          child: Text(
                            category['name'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                      },
                    ),
              SizedBox(height: AppSizes.p16),

              // Total hours and tuition fee in row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalHoursController,
                      decoration: InputDecoration(
                        labelText: 'Số giờ học *',
                        hintText: '60',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bắt buộc';
                        }
                        final hours = int.tryParse(value.trim());
                        if (hours == null || hours <= 0) {
                          return 'Số giờ không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: TextFormField(
                      controller: _tuitionFeeController,
                      decoration: InputDecoration(
                        labelText: 'Học phí (đ) *',
                        hintText: '3500000',
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bắt buộc';
                        }
                        final fee = double.tryParse(value.trim());
                        if (fee == null || fee <= 0) {
                          return 'Học phí không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p16),

              // Status switch
              SwitchListTile(
                title: const Text('Trạng thái khóa học'),
                subtitle: Text(_isActive ? 'Đang mở' : 'Đã đóng'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
                activeColor: AppColors.success,
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: AppSizes.p24),

              // Media section
              _buildSectionTitle('Hình ảnh & Video', isDark),
              SizedBox(height: AppSizes.p16),

              // Image picker
              _buildImagePicker(isDark),
              SizedBox(height: AppSizes.p16),

              // Video URL
              TextFormField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'URL video giới thiệu',
                  hintText: 'https://youtube.com/watch?v=...',
                  prefixIcon: const Icon(Icons.video_library),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.isAbsolute) {
                      return 'URL không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.p24),

              // Description section
              _buildSectionTitle('Mô tả & Yêu cầu', isDark),
              SizedBox(height: AppSizes.p16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả khóa học',
                  hintText: 'Nhập mô tả chi tiết về khóa học...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                maxLines: 5,
                maxLength: 1000,
              ),
              SizedBox(height: AppSizes.p16),

              // Entry requirement
              TextFormField(
                controller: _entryRequirementController,
                decoration: InputDecoration(
                  labelText: 'Yêu cầu đầu vào',
                  hintText: 'Ví dụ: Không yêu cầu kiến thức đầu vào',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              SizedBox(height: AppSizes.p16),

              // Exit requirement
              TextFormField(
                controller: _exitRequirementController,
                decoration: InputDecoration(
                  labelText: 'Mục tiêu đầu ra',
                  hintText: 'Ví dụ: Có thể giao tiếp cơ bản...',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              SizedBox(height: AppSizes.p32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isUploadingImage) ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                  child: (_isLoading || _isUploadingImage)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: AppSizes.p16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (_isLoading || _isUploadingImage) ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: const BorderSide(color: AppColors.gray400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isDark ? AppColors.gray600 : AppColors.gray300,
            width: 1,
          ),
        ),
        child: _buildImageContent(isDark),
      ),
    );
  }

  Widget _buildImageContent(bool isDark) {
    if (_isUploadingImage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Đang tải ảnh...'),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      final dioClient = getIt<DioClient>();
      final fullUrl = _imageUrl!.startsWith('http') 
          ? _imageUrl! 
          : '${dioClient.baseUrl}/files/$_imageUrl';
      
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Image.network(
              fullUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _imageUrl = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48.sp,
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
        SizedBox(height: AppSizes.p8),
        Text(
          'Nhấn để chọn hình ảnh',
          style: TextStyle(
            color: isDark ? AppColors.gray400 : AppColors.gray500,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Hỗ trợ JPG, PNG (tối đa 5MB)',
          style: TextStyle(
            color: isDark ? AppColors.gray500 : AppColors.gray400,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}
