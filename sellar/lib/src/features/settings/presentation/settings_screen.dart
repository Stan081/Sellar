import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AuthRepository _authRepo;
  String _businessName = '';
  String _email = '';
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(
      apiService: AppServices.api,
      storageService: AppServices.storage,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final vendor = await _authRepo.getProfile();
      if (mounted) {
        setState(() {
          _businessName = vendor.businessName;
          _email = vendor.email;
          _profileLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _profileLoaded = true);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _authRepo.logout();

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.store,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _profileLoaded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _businessName.isNotEmpty
                                    ? _businessName
                                    : 'My Business',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email.isNotEmpty
                                    ? _email
                                    : 'vendor@sellar.com',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          )
                        : const SizedBox(
                            height: 36,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.business_outlined,
            title: 'Business Profile',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.payment_outlined,
            title: 'Payment Gateway',
            subtitle: 'Paystack',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'USD',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: 'System default',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'About'),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0+1',
          ),
          _SettingsTile(
            icon: Icons.code_outlined,
            title: 'Open Source Licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Sellar',
                applicationVersion: '1.0.0+1',
              );
            },
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => _handleLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
