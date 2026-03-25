import 'package:equatable/equatable.dart';

/// Represents a single purchase/transaction by a customer
class Purchase extends Equatable {
  const Purchase({
    required this.id,
    this.productId,
    this.productName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.linkId,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return Purchase(
      id: json['id'] as String,
      productId: product?['id'] as String? ?? json['productId'] as String?,
      productName: product?['name'] as String? ?? json['productName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['createdAt'] as String),
      linkId: json['linkId'] as String?,
    );
  }

  final String id;
  final String? productId;
  final String? productName;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? linkId;

  bool get isCompleted => status == 'completed' || status == 'COMPLETED';
  bool get isPending => status == 'pending' || status == 'PENDING';
  bool get isFailed => status == 'failed' || status == 'FAILED';

  @override
  List<Object?> get props => [id, productId, amount, currency, status, createdAt];
}

/// Customer entity — created when a buyer makes a purchase through a payment link.
/// Phone or email serves as the unique identifier for repeat purchases.
class Customer extends Equatable {
  const Customer({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.billingAddress,
    required this.totalSpent,
    required this.purchaseCount,
    required this.currency,
    required this.createdAt,
    this.lastPurchaseAt,
    this.purchases,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    final purchases = (json['transactions'] as List<dynamic>?)
        ?.map((e) => Purchase.fromJson(e as Map<String, dynamic>))
        .toList();

    final stats = json['_stats'] as Map<String, dynamic>?;
    final count = json['_count'] as Map<String, dynamic>?;

    return Customer(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      billingAddress: json['billingAddress'] as String?,
      totalSpent: (stats?['totalSpent'] as num?)?.toDouble() ??
          (json['totalSpent'] as num?)?.toDouble() ??
          0.0,
      purchaseCount: count?['transactions'] as int? ??
          (json['purchaseCount'] as int?) ??
          purchases?.length ??
          0,
      currency: json['currency'] as String? ?? 'USD',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPurchaseAt: json['lastPurchaseAt'] != null
          ? DateTime.tryParse(json['lastPurchaseAt'] as String)
          : null,
      purchases: purchases,
    );
  }

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? billingAddress;
  final double totalSpent;
  final int purchaseCount;
  final String currency;
  final DateTime createdAt;
  final DateTime? lastPurchaseAt;
  final List<Purchase>? purchases;

  /// Display name — falls back to email or phone
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'Unknown Customer';
  }

  /// The primary contact identifier
  String get identifier {
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return '—';
  }

  /// Initials for avatar
  String get initials {
    if (name != null && name!.isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) return email![0].toUpperCase();
    return '?';
  }

  @override
  List<Object?> get props => [id, email, phone, name, totalSpent, purchaseCount];
}
