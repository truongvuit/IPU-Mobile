






class VNPayCreatePaymentRequest {
  final String amount;
  final String? orderInfo;
  final int invoiceId;

  const VNPayCreatePaymentRequest({
    required this.amount,
    this.orderInfo,
    required this.invoiceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      if (orderInfo != null) 'orderInfo': orderInfo,
      'invoiceId': invoiceId,
    };
  }
}

class VNPayCreatePaymentResponse {
  final String txnRef;
  final String amount;
  final String payUrl;

  const VNPayCreatePaymentResponse({
    required this.txnRef,
    required this.amount,
    required this.payUrl,
  });

  factory VNPayCreatePaymentResponse.fromJson(Map<String, dynamic> json) {
    return VNPayCreatePaymentResponse(
      txnRef: json['txnRef'] as String? ?? '',
      amount: json['amount']?.toString() ?? '0',
      payUrl: json['payUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txnRef': txnRef,
      'amount': amount,
      'payUrl': payUrl,
    };
  }
}

class VNPayPaymentResult {
  final String status;
  final int? invoiceId;
  final String? transactionNo;
  final String? amount;
  final String? responseCode;
  final String? error;
  
  final String? message;
  
  final String? userRole;

  const VNPayPaymentResult({
    required this.status,
    this.invoiceId,
    this.transactionNo,
    this.amount,
    this.responseCode,
    this.error,
    this.message,
    this.userRole,
  });

  
  factory VNPayPaymentResult.fromUri(Uri uri) {
    final params = uri.queryParameters;
    return VNPayPaymentResult(
      status: params['status'] ?? 'unknown',
      invoiceId: int.tryParse(params['invoiceId'] ?? ''),
      transactionNo: params['transactionNo'],
      amount: params['amount'],
      responseCode: params['responseCode'],
      error: params['error'],
      message: params['message'],
      userRole: params['userRole'],
    );
  }
  
  
  VNPayPaymentResult copyWith({
    String? status,
    int? invoiceId,
    String? transactionNo,
    String? amount,
    String? responseCode,
    String? error,
    String? message,
    String? userRole,
  }) {
    return VNPayPaymentResult(
      status: status ?? this.status,
      invoiceId: invoiceId ?? this.invoiceId,
      transactionNo: transactionNo ?? this.transactionNo,
      amount: amount ?? this.amount,
      responseCode: responseCode ?? this.responseCode,
      error: error ?? this.error,
      message: message ?? this.message,
      userRole: userRole ?? this.userRole,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  
  
  bool get isStudentPayment => userRole?.toUpperCase() == 'STUDENT';
  
  
  bool get isAdminPayment => userRole?.toUpperCase() == 'ADMIN' || userRole == null;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (invoiceId != null) 'invoiceId': invoiceId,
      if (transactionNo != null) 'transactionNo': transactionNo,
      if (amount != null) 'amount': amount,
      if (responseCode != null) 'responseCode': responseCode,
      if (error != null) 'error': error,
      if (message != null) 'message': message,
      if (userRole != null) 'userRole': userRole,
    };
  }

  @override
  String toString() {
    return 'VNPayPaymentResult(status: $status, invoiceId: $invoiceId, transactionNo: $transactionNo, amount: $amount, responseCode: $responseCode, error: $error, message: $message, userRole: $userRole)';
  }
}
