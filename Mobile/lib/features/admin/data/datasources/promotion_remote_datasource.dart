import '../../../../core/api/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/promotion.dart';
import '../models/promotion_model.dart';

abstract class PromotionRemoteDataSource {
  Future<List<PromotionModel>> getPromotions();
  Future<List<PromotionModel>> getPromotionsByCourse(String courseId);
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
  Future<List<PromotionModel>> getPromotionsByCourse(String courseId) async {
    if (dioClient == null) {
      throw const ServerException('Chưa khởi tạo API client');
    }

    final response = await dioClient!.get('/promotions/course/$courseId');
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => _mapToPromotionModel(json)).toList();
    }
    throw const ServerException('Không thể lấy khuyến mãi theo khóa học');
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

    
    if (promotion.id.isEmpty) {
      throw const ServerException('ID khuyến mãi không được để trống');
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

    
    final response = await dioClient!.put('/promotions/$id/toggle');
    if (response.statusCode == 200 && response.data['code'] == 1000) {
      return;
    }
    throw ServerException(
      response.data['message'] ?? 'Không thể xóa khuyến mãi',
    );
  }

  Map<String, dynamic> _toRequestJson(PromotionModel promotion) {
    
    int promotionTypeId;
    switch (promotion.promotionType) {
      case PromotionType.single:
        promotionTypeId = 1;
        break;
      case PromotionType.combo:
        promotionTypeId = 2;
        break;
    }

    return {
      'name': promotion.title, 
      'description': promotion.description,
      'discountPercent': promotion.discountValue
          .toInt(), 
      'startDate': promotion.startDate.toIso8601String().split('T')[0],
      'endDate': promotion.endDate.toIso8601String().split('T')[0],
      'promotionTypeId': promotionTypeId, 
      'courseIds': promotion.applicableCourseIds != null
          ? promotion.applicableCourseIds!
                .map((e) => int.tryParse(e))
                .where(
                  (id) => id != null,
                ) 
                .toList()
          : null,
    };
    
  }

  PromotionModel _mapToPromotionModel(Map<String, dynamic> json) {
    
    
    PromotionStatus status;
    if (json.containsKey('active')) {
      final isActive = json['active'] ?? false;
      status = isActive ? PromotionStatus.active : PromotionStatus.draft;
    } else {
      final statusStr = (json['status'] ?? 'active').toString().toLowerCase();
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
    }

    
    List<String>? applicableCourseIds;
    List<String>? applicableCourseNames;

    if (json['courses'] != null) {
      final coursesList = json['courses'] as List<dynamic>;
      applicableCourseIds = coursesList
          .map((c) => (c['courseId'] ?? '').toString())
          .toList();
      applicableCourseNames = coursesList
          .map((c) => (c['courseName'] ?? '').toString())
          .toList();
    } else if (json['applicableCourseIds'] != null) {
      
      applicableCourseIds = (json['applicableCourseIds'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      if (json['applicableCourseNames'] != null) {
        applicableCourseNames = (json['applicableCourseNames'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }

    return PromotionModel(
      id: (json['id'] ?? '').toString(),
      code:
          json['name'] ??
          'KM${json['id'] ?? ''}', 
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
