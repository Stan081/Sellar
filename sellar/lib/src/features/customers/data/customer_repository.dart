import 'package:sellar/src/constants/app_constants.dart';
import 'package:sellar/src/features/customers/domain/entities/customer.dart';
import 'package:sellar/src/services/api_service.dart';

/// Repository for customer operations
class CustomerRepository {
  CustomerRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  /// Fetch all customers for the current vendor
  Future<List<Customer>> getCustomers() async {
    final response = await _apiService.get(AppConstants.customersPath);
    if (response.statusCode == 200 && response.data != null) {
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.data?['error'] ?? 'Failed to fetch customers');
  }

  /// Fetch a single customer with full purchase history
  Future<Customer> getCustomer(String id) async {
    final response =
        await _apiService.get('${AppConstants.customersPath}/$id');
    if (response.statusCode == 200 && response.data != null) {
      return Customer.fromJson(
          response.data['data'] as Map<String, dynamic>);
    }
    throw Exception(
        response.data?['error'] ?? 'Failed to fetch customer details');
  }
}
