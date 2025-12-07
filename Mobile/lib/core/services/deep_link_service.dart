import 'dart:async';
import 'package:app_links/app_links.dart'; 
import '../../features/payment/domain/vnpay_models.dart';


class DeepLinkService {
  
  final _appLinks = AppLinks();
  
  StreamSubscription? _linkSubscription;
  final _paymentResultController = StreamController<VNPayPaymentResult>.broadcast();

  
  Stream<VNPayPaymentResult> get paymentResultStream => _paymentResultController.stream;

  
  Future<void> initialize() async {
    
    await _handleInitialLink();
    
    
    _listenForLinks();
  }

  
  Future<Uri?> getInitialLink() async {
    try {
      
      return await _appLinks.getInitialLink();
    } catch (e) {
      return null;
    }
  }

  
  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      
    }
  }

  
  void _listenForLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        
        print('DeepLink Error: $err');
      },
    );
  }

  
  void _handleDeepLink(Uri uri) {
    print("Received DeepLink: $uri"); 
    
    
    if (_isVNPayCallback(uri)) {
      final result = VNPayPaymentResult.fromUri(uri);
      _paymentResultController.add(result);
    }
  }

  
  bool _isVNPayCallback(Uri uri) {
    
    return uri.scheme == 'ipumobile' &&
        uri.host == 'payment' &&
        uri.path.contains('vnpay-return');
  }

  
  VNPayPaymentResult? parsePaymentResult(String url) {
    try {
      final uri = Uri.parse(url);
      if (_isVNPayCallback(uri)) {
        return VNPayPaymentResult.fromUri(uri);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  
  void dispose() {
    _linkSubscription?.cancel();
    _paymentResultController.close();
  }
}