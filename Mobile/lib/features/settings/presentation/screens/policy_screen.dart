import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_constants.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chính sách bảo mật',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: AppSizes.textLg,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Giới thiệu',
                'Chính sách bảo mật này mô tả cách chúng tôi thu thập, sử dụng, và bảo vệ thông tin cá nhân của bạn khi sử dụng ứng dụng Trung Tâm Ngoại Ngữ.',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Thu thập thông tin',
                'Chúng tôi thu thập các thông tin sau:\n\n'
                    '• Thông tin cá nhân: Họ tên, email, số điện thoại, địa chỉ\n'
                    '• Thông tin học tập: Lịch học, điểm số, tiến độ học tập\n'
                    '• Thông tin thanh toán: Lịch sử giao dịch, phương thức thanh toán\n'
                    '• Thông tin thiết bị: Loại thiết bị, hệ điều hành, IP address',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Sử dụng thông tin',
                'Thông tin thu thập được sử dụng để:\n\n'
                    '• Cung cấp và cải thiện dịch vụ\n'
                    '• Quản lý tài khoản và lịch học\n'
                    '• Xử lý thanh toán\n'
                    '• Gửi thông báo quan trọng\n'
                    '• Phân tích và cải thiện trải nghiệm người dùng',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Bảo vệ thông tin',
                'Chúng tôi cam kết bảo vệ thông tin của bạn thông qua:\n\n'
                    '• Mã hóa dữ liệu khi truyền tải\n'
                    '• Lưu trữ an toàn trên server\n'
                    '• Kiểm soát truy cập nghiêm ngặt\n'
                    '• Cập nhật bảo mật thường xuyên',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Quyền của bạn',
                'Bạn có quyền:\n\n'
                    '• Truy cập và xem thông tin cá nhân\n'
                    '• Yêu cầu chỉnh sửa hoặc xóa thông tin\n'
                    '• Từ chối nhận thông báo marketing\n'
                    '• Khiếu nại về việc xử lý dữ liệu',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Liên hệ',
                'Nếu có thắc mắc về chính sách bảo mật, vui lòng liên hệ:\n\n'
                    '• Email: ${AppConstants.supportEmail}\n'
                    '• Điện thoại: ${AppConstants.supportPhone}',
              ),
              SizedBox(height: AppSizes.paddingExtraLarge),
              Text(
                'Cập nhật lần cuối: 20/11/2025',
                style: TextStyle(
                  fontSize: AppSizes.textSm,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppSizes.textLg,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Lexend',
          ),
        ),
        SizedBox(height: AppSizes.paddingSmall),
        Text(
          content,
          style: TextStyle(
            fontSize: AppSizes.textBase,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.6,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
