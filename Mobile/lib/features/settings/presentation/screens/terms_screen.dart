import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Điều khoản sử dụng',
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
                'Chấp nhận điều khoản',
                'Bằng việc sử dụng ứng dụng Trung Tâm Ngoại Ngữ, bạn đồng ý tuân thủ các điều khoản và điều kiện sử dụng dưới đây. Nếu không đồng ý, vui lòng không sử dụng ứng dụng.',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Tài khoản người dùng',
                'Khi đăng ký tài khoản, bạn cam kết:\n\n'
                    '• Cung cấp thông tin chính xác và đầy đủ\n'
                    '• Bảo mật thông tin đăng nhập\n'
                    '• Không chia sẻ tài khoản cho người khác\n'
                    '• Thông báo ngay nếu phát hiện truy cập trái phép\n'
                    '• Chịu trách nhiệm về mọi hoạt động từ tài khoản',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Sử dụng dịch vụ',
                'Bạn cam kết:\n\n'
                    '• Sử dụng dịch vụ cho mục đích học tập hợp pháp\n'
                    '• Không sao chép, phát tán tài liệu không phép\n'
                    '• Không spam, quấy rối người dùng khác\n'
                    '• Không hack, phá hoại hệ thống\n'
                    '• Tuân thủ quy định của trung tâm',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Thanh toán và hoàn tiền',
                'Chính sách thanh toán:\n\n'
                    '• Học phí được công bố rõ ràng trước khi đăng ký\n'
                    '• Thanh toán qua các phương thức được hỗ trợ\n'
                    '• Hóa đơn điện tử được gửi sau mỗi giao dịch\n'
                    '• Hoàn tiền theo quy định của trung tâm\n'
                    '• Không hoàn tiền sau khi khóa học đã bắt đầu 2 tuần',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Quyền sở hữu trí tuệ',
                'Tất cả nội dung trong ứng dụng:\n\n'
                    '• Thuộc quyền sở hữu của Trung Tâm Ngoại Ngữ\n'
                    '• Được bảo vệ bởi luật sở hữu trí tuệ\n'
                    '• Không được sao chép, phát tán khi chưa có phép\n'
                    '• Chỉ sử dụng cho mục đích học tập cá nhân',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Giới hạn trách nhiệm',
                'Trung tâm không chịu trách nhiệm về:\n\n'
                    '• Gián đoạn dịch vụ do sự cố kỹ thuật\n'
                    '• Thiệt hại gián tiếp từ việc sử dụng app\n'
                    '• Nội dung do người dùng khác tạo ra\n'
                    '• Mất mát dữ liệu do lỗi thiết bị người dùng',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Thay đổi điều khoản',
                'Chúng tôi có quyền:\n\n'
                    '• Cập nhật điều khoản bất kỳ lúc nào\n'
                    '• Thông báo qua email hoặc trong app\n'
                    '• Yêu cầu chấp thuận lại nếu thay đổi quan trọng\n'
                    '• Tiếp tục sử dụng = đồng ý với điều khoản mới',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Chấm dứt sử dụng',
                'Tài khoản có thể bị khóa nếu:\n\n'
                    '• Vi phạm điều khoản sử dụng\n'
                    '• Không thanh toán học phí\n'
                    '• Có hành vi gian lận\n'
                    '• Yêu cầu của cơ quan chức năng\n'
                    '• Theo yêu cầu của chính bạn',
              ),
              SizedBox(height: AppSizes.paddingLarge),
              _buildSection(
                context,
                'Liên hệ',
                'Nếu có thắc mắc về điều khoản sử dụng:\n\n'
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
