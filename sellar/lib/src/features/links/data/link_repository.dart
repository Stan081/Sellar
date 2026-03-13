import 'package:sellar/src/constants/app_constants.dart';
import 'package:sellar/src/services/api_service.dart';

/// Local model matching the backend PaymentLink shape
class LinkModel {
  final String id;
  final String? productId;
  final String? productName;
  final double amount;
  final String currency;
  final bool isPublic;
  final bool isReusable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String shortCode;
  final int viewCount;
  final int paymentCount;

  const LinkModel({
    required this.id,
    this.productId,
    this.productName,
    required this.amount,
    required this.currency,
    required this.isPublic,
    required this.isReusable,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    required this.shortCode,
    this.viewCount = 0,
    this.paymentCount = 0,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final count = json['_count'] as Map<String, dynamic>?;
    return LinkModel(
      id: json['id'] as String,
      productId: product?['id'] as String?,
      productName: product?['name'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      isPublic: (json['linkType'] as String?) == 'PUBLIC',
      isReusable: json['isReusable'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      shortCode: json['shortCode'] as String,
      viewCount: count?['linkViews'] as int? ?? 0,
      paymentCount: count?['transactions'] as int? ?? 0,
    );
  }

  String get url => 'https://sellar.app/pay/$shortCode';

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

/// Repository for payment link operations
class LinkRepository {
  LinkRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<LinkModel>> getLinks() async {
    final response = await _apiService.get(AppConstants.linksPath);
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => LinkModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data?['error'] ?? 'Failed to fetch links');
  }

  Future<LinkModel> createLink({
    String? productId,
    required double amount,
    required String currency,
    bool isPublic = true,
    bool isReusable = false,
    DateTime? expiresAt,
  }) async {
    final response = await _apiService.post(
      AppConstants.linksPath,
      data: {
        if (productId != null) 'productId': productId,
        'amount': amount,
        'currency': currency,
        'linkType': isPublic ? 'PUBLIC' : 'PRIVATE',
        'isReusable': isReusable,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      },
    );
    if (response.statusCode == 201 && response.data != null) {
      return LinkModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data?['error'] ?? 'Failed to create link');
  }

  Future<void> deleteLink(String id) async {
    final response =
        await _apiService.delete('${AppConstants.linksPath}/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete link');
    }
  }

  Future<void> deactivateLink(String id) async {
    final response = await _apiService.put(
      '${AppConstants.linksPath}/$id/deactivate',
    );
    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to deactivate link');
    }
  }
}
