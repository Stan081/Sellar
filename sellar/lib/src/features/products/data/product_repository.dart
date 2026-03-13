import 'package:sellar/src/constants/app_constants.dart';
import 'package:sellar/src/features/products/domain/entities/product.dart';
import 'package:sellar/src/services/api_service.dart';

/// Repository for product CRUD operations
class ProductRepository {
  ProductRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<Product>> getProducts() async {
    final response = await _apiService.get(AppConstants.productsPath);
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data?['error'] ?? 'Failed to fetch products');
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    int? quantity,
    List<String> tags = const [],
    List<String> images = const [],
  }) async {
    final response = await _apiService.post(
      AppConstants.productsPath,
      data: {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        if (quantity != null) 'quantity': quantity,
        'tags': tags,
        'images': images,
      },
    );
    if (response.statusCode == 201 && response.data != null) {
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data?['error'] ?? 'Failed to create product');
  }

  Future<Product> updateProduct(
    String id, {
    String? name,
    String? description,
    String? category,
    double? price,
    int? quantity,
    List<String>? tags,
    List<String>? images,
    bool? isActive,
  }) async {
    final response = await _apiService.put(
      '${AppConstants.productsPath}/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
        if (quantity != null) 'quantity': quantity,
        if (tags != null) 'tags': tags,
        if (images != null) 'images': images,
        if (isActive != null) 'isActive': isActive,
      },
    );
    if (response.statusCode == 200 && response.data != null) {
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(response.data?['error'] ?? 'Failed to update product');
  }

  Future<void> deleteProduct(String id) async {
    final response =
        await _apiService.delete('${AppConstants.productsPath}/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete product');
    }
  }
}
