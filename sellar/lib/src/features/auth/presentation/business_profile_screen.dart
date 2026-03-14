import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/core/utils/error_handler.dart';

/// Business profile setup screen - collect business information
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({
    super.key,
    required this.credentials,
  });

  final Map<String, dynamic> credentials;

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _isLoading = false;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      apiService: AppServices.api,
      storageService: AppServices.storage,
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vendor = await _authRepository.register(
        email: widget.credentials['email'] as String,
        phone: widget.credentials['phone'] as String?,
        password: widget.credentials['password'] as String,
        businessName: _businessNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        country: _countryController.text.trim(),
        currency: _currencyController.text.trim().isEmpty
            ? null
            : _currencyController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to main app
      context.go('/');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${vendor.firstName}!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Get user-friendly error message
      String userMessage;
      try {
        final apiException = ErrorHandler.handleError(e);
        userMessage = ErrorHandler.getUserMessage(apiException);
      } catch (_) {
        userMessage = 'Something went wrong. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tell us about your business',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This information will appear on your payment links',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                // Business Name
                TextFormField(
                  controller: _businessNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    hintText: 'My Awesome Store',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Country
                TextFormField(
                  controller: _countryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'United States',
                    prefixIcon: Icon(Icons.public_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Currency (optional)
                TextFormField(
                  controller: _currencyController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Currency (Optional)',
                    hintText: 'USD',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 32),
                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Complete Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
