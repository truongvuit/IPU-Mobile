import '../../../../core/api/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/promotion.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
  Future<PromotionModel> getPromotionById(String id);
  Future<void> createPromotion(PromotionModel promotion);
  Future<void> updatePromotion(PromotionModel promotion);
  Future<void> deletePromotion(String id);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final DioClient? dioClient;

  PromotionRemoteDataSourceImpl({this.dioClient});

  @override
  Future<List<PromotionModel>> getPromotions() async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.get('/promotions');
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => _mapToPromotionModel(json)).toList();
    }
    throw const ServerException('Không thể lấy danh sách khuyến mãi');
  }

  @override
  Future<PromotionModel> getPromotionById(String id) async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.get('/promotions/$id');
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      return _mapToPromotionModel(response.data['data']);
    }
    throw const ServerException('Không tìm thấy khuyến mãi');
  }

  @override
  Future<void> createPromotion(PromotionModel promotion) async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.post(
      '/promotions',
      data: _toRequestJson(promotion),
    );
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      return;
    }
    throw ServerException(
      response.data['message'] ?? 'Không thể tạo khuyến mãi',
    );
  }

  @override
  Future<void> updatePromotion(PromotionModel promotion) async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.put(
      '/promotions/${promotion.id}',
      data: _toRequestJson(promotion),
    );
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      return;
    }
    throw ServerException(
      response.data['message'] ?? 'Không thể cập nhật khuyến mãi',
    );
  }

  @override
  Future<void> deletePromotion(String id) async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.delete('/promotions/$id');
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      return;
    }
    throw ServerException(
      response.data['message'] ?? 'Không thể xóa khuyến mãi',
    );
  }

  Map<String, dynamic> _toRequestJson(PromotionModel promotion) {
    return {
      'name': promotion.title,
      'code': promotion.code,
      'description': promotion.description,
      'discountPercent': promotion.discountType == DiscountType.percentage
          ? promotion.discountValue.toInt()
          : 0,
      'discountAmount': promotion.discountType == DiscountType.fixedAmount
          ? promotion.discountValue
          : 0,
      'startDate': promotion.startDate.toIso8601String().split('T')[0],
      'endDate': promotion.endDate.toIso8601String().split('T')[0],
      'active': promotion.status == PromotionStatus.active,
      'usageLimit': promotion.usageLimit,
      'minOrderValue': promotion.minOrderValue,
      'applicableCourseIds': promotion.applicableCourseIds
          ?.map((e) => int.tryParse(e) ?? 0)
          .toList(),
      'promotionType': promotion.promotionType.toString().split('.').last,
      'requireAllCourses': promotion.requireAllCourses,
    };
  }

  PromotionModel _mapToPromotionModel(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? 'active').toString().toLowerCase();
    PromotionStatus status;
    switch (statusStr) {
      case 'active':
        status = PromotionStatus.active;
        break;
      case 'expired':
        status = PromotionStatus.expired;
        break;
      case 'upcoming':
        status = PromotionStatus.scheduled;
        break;
      case 'inactive':
        status = PromotionStatus.draft;
        break;
      default:
        status = PromotionStatus.draft;
    }

    
    List<String>? applicableCourseIds;
    List<String>? applicableCourseNames;

    if (json['applicableCourseIds'] != null) {
      applicableCourseIds = (json['applicableCourseIds'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    if (json['applicableCourseNames'] != null) {
      applicableCourseNames = (json['applicableCourseNames'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    return PromotionModel(
      id: (json['id'] ?? '').toString(),
      code: json['code'] ?? json['name'] ?? 'KM${json['id'] ?? ''}',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      discountType: DiscountType.percentage,
      discountValue: (json['discountPercent'] ?? 0).toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      usageLimit: null,
      usageCount: 0,
      status: status,
      applicableCourseIds: applicableCourseIds,
      applicableCourseNames: applicableCourseNames,
    );
  }
}
