/// Product entity
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> images;
  final String category;
  final int? quantity;
  final List<String> tags;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime? soldAt;
  final int soldCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'USD',
    this.images = const [],
    required this.category,
    this.quantity,
    this.tags = const [],
    this.status = ProductStatus.pending,
    required this.createdAt,
    this.soldAt,
    this.soldCount = 0,
  });

  String? get imageUrl => images.isNotEmpty ? images.first : null;

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>?)?.cast<String>() ?? [];
    final legacyImageUrl = json['imageUrl'] as String?;
    final resolvedImages = images.isNotEmpty
        ? images
        : (legacyImageUrl != null && legacyImageUrl.isNotEmpty)
            ? [legacyImageUrl]
            : <String>[];
    final tags = (json['tags'] as List<dynamic>?)?.cast<String>() ?? [];
    final isActive = json['isActive'] as bool? ?? true;
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: 'USD',
      images: resolvedImages,
      category: json['category'] as String,
      quantity: json['quantity'] as int?,
      tags: tags,
      status: isActive ? ProductStatus.pending : ProductStatus.sold,
      createdAt: DateTime.parse(json['createdAt'] as String),
      soldCount: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'tags': tags,
        'quantity': quantity,
        'images': images,
      };

  bool get isSold => status == ProductStatus.sold;
  bool get isPending => status == ProductStatus.pending;
  bool get isLowStock => quantity != null && quantity! < 5;
}

/// Product status enum
enum ProductStatus {
  pending,
  sold,
  outOfStock,
}
