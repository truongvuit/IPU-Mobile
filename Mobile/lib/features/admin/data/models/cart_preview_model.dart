import '../../domain/entities/cart_preview.dart';


class InvalidClassIdsException implements Exception {
  final List<String> invalidIds;
  final String message;

  const InvalidClassIdsException({
    required this.invalidIds,
    this.message = 'Một số lớp học không hợp lệ',
  });

  @override
  String toString() => '$message: ${invalidIds.join(', ')}';
}


class CartPreviewRequest {
  final List<int> courseClassIds;

  const CartPreviewRequest({required this.courseClassIds});

  Map<String, dynamic> toJson() => {'courseClassIds': courseClassIds};

  
  
  
  factory CartPreviewRequest.fromClassIds(List<String> classIds) {
    final List<int> validIds = [];
    final List<String> invalidIds = [];

    for (final id in classIds) {
      
      var parsed = int.tryParse(id);
      
      
      if (parsed == null) {
        final normalized = id.replaceAll(RegExp(r'[^0-9]'), '');
        parsed = int.tryParse(normalized);
      }
      
      if (parsed != null && parsed > 0) {
        validIds.add(parsed);
      } else {
        
        invalidIds.add(id);
      }
    }

    
    if (invalidIds.isNotEmpty) {
      throw InvalidClassIdsException(invalidIds: invalidIds);
    }

    
    return CartPreviewRequest(courseClassIds: validIds);
  }

  
  
  factory CartPreviewRequest.fromClassIdsSafe(List<String> classIds) {
    final validIds = classIds
        .map((id) => int.tryParse(id))
        .where((id) => id != null && id > 0)
        .cast<int>()
        .toList();
    return CartPreviewRequest(courseClassIds: validIds);
  }
}


class CartPreviewModel extends CartPreview {
  const CartPreviewModel({required super.items, required super.summary});

  factory CartPreviewModel.fromJson(Map<String, dynamic> json) {
    return CartPreviewModel(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CartPreviewItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      summary: CartPreviewSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  
  CartPreview toEntity() => CartPreview(items: items, summary: summary);
}
