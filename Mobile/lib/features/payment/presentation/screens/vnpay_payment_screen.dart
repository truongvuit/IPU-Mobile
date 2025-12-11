import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/vnpay_models.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final int invoiceId;

  const VNPayPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.invoiceId,
  });

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      ) 
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('VNPay WebView Started: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            debugPrint('VNPay WebView Finished: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'VNPay WebView Error: ${error.description}, Code: ${error.errorCode}',
            );
            
            if (error.errorCode == -10 ||
                error.description.contains('net::ERR_UNKNOWN_URL_SCHEME')) {
              return;
            }

            if (error.isForMainFrame ?? false) {
              setState(() {
                _hasError = true;
                _isLoading = false;
                _errorMessage = error.description;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('VNPay WebView Navigation: $url');

            
            if (url.startsWith('ipumobile://payment/vnpay-return')) {
              debugPrint('VNPay Callback Detected: $url');
              _handlePaymentCallback(url);
              return NavigationDecision.prevent;
            }

            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..clearCache()
      ..clearLocalStorage()
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentCallback(String url) {
    try {
      final uri = Uri.parse(url);
      final result = VNPayPaymentResult.fromUri(uri);

      Navigator.of(
        context,
      ).pushReplacementNamed('/payment/vnpay-result', arguments: result);
    } catch (e) {
      Navigator.of(context).pushReplacementNamed(
        '/payment/vnpay-result',
        arguments: VNPayPaymentResult(
          status: 'failed',
          invoiceId: widget.invoiceId,
          error: 'Không thể xử lý kết quả thanh toán: ${e.toString()}',
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text(
          'Bạn có chắc muốn hủy thanh toán? Giao dịch sẽ không được hoàn thành.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_hasError)
              _buildErrorWidget()
            else
              WebViewWidget(controller: _controller),

            if (_isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text(
                        'Đang tải trang thanh toán...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Không thể tải trang thanh toán',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? 'Vui lòng kiểm tra kết nối mạng và thử lại',
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Quay lại',
                style: TextStyle(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
