import 'package:equatable/equatable.dart';

/// Vendor domain model representing authenticated user data.
class Vendor extends Equatable {
  const Vendor({
    required this.id,
    required this.email,
    this.phone,
    required this.businessName,
    required this.firstName,
    required this.lastName,
    required this.country,
    this.currency,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      businessName: json['businessName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      country: json['country'] as String,
      currency: json['currency'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
    );
  }

  final String id;
  final String email;
  final String? phone;
  final String businessName;
  final String firstName;
  final String lastName;
  final String country;
  final String? currency;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        businessName,
        firstName,
        lastName,
        country,
        currency,
        isEmailVerified,
        isPhoneVerified,
      ];
}
