import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/features/settings/presentation/edit_profile_screen.dart';
import 'package:sellar/src/features/settings/presentation/help_support_screen.dart';
import 'package:sellar/src/features/settings/presentation/privacy_policy_screen.dart';
import 'package:sellar/src/features/settings/presentation/terms_of_service_screen.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/theme/app_spacing.dart';

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
  String _currency = 'USD';
  String _initials = 'S';
  bool _profileLoaded = false;
  bool _notificationsEnabled = true;
  String _themeMode = 'System default';
  String _appVersion = '1.0.0';

  static const _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'NGN', 'name': 'Nigerian Naira', 'symbol': '₦'},
    {'code': 'GHS', 'name': 'Ghanaian Cedi', 'symbol': 'GH₵'},
    {'code': 'KES', 'name': 'Kenyan Shilling', 'symbol': 'KSh'},
    {'code': 'ZAR', 'name': 'South African Rand', 'symbol': 'R'},
  ];

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository(
      apiService: AppServices.api,
      storageService: AppServices.storage,
    );
    _loadProfile();
    _loadPreferences();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  Future<void> _loadPreferences() async {
    final notifs = AppServices.storage.getBool('notifications_enabled');
    final theme = AppServices.storage.getString('theme_preference');
    final currency = AppServices.storage.getString('preferred_currency');
    if (mounted) {
      setState(() {
        _notificationsEnabled = notifs ?? true;
        _themeMode = theme ?? 'System default';
        if (currency != null) _currency = currency;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final vendor = await _authRepo.getProfile();
      if (mounted) {
        setState(() {
          _businessName = vendor.businessName;
          _email = vendor.email;
          _currency = vendor.currency ?? _currency;
          _initials = _getInitials(vendor.businessName);
          _profileLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _profileLoaded = true);
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'S';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Select Currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...(_currencies.map((c) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c['symbol']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(c['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(c['code']!,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  trailing: _currency == c['code']
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 22)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _currency = c['code']!);
                    await AppServices.storage
                        .setString('preferred_currency', c['code']!);
                    // Also update on server
                    try {
                      await _authRepo.updateProfile(currency: c['code']!);
                    } catch (_) {}
                  },
                ))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = ['System default', 'Light', 'Dark'];
        final icons = [
          Icons.brightness_auto,
          Icons.light_mode,
          Icons.dark_mode
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Choose Theme',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...List.generate(
                  options.length,
                  (i) => ListTile(
                        leading: Icon(icons[i], color: AppColors.primary),
                        title: Text(options[i],
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: _themeMode == options[i]
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 22)
                            : null,
                        onTap: () async {
                          Navigator.pop(context);
                          setState(() => _themeMode = options[i]);
                          await AppServices.storage
                              .setString('theme_preference', options[i]);
                        },
                      )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _toggleNotifications() async {
    final newValue = !_notificationsEnabled;
    setState(() => _notificationsEnabled = newValue);
    await AppServices.storage.setBool('notifications_enabled', newValue);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              newValue ? 'Notifications enabled' : 'Notifications disabled'),
          backgroundColor:
              newValue ? AppColors.success : AppColors.textSecondary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _navigateTo(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    // Reload profile if coming back from edit screen
    if (result == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        children: [
          // Profile Card
          Card(
            child: InkWell(
              onTap: () => _navigateTo(const EditProfileScreen()),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: _profileLoaded
                          ? Text(
                              _initials,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            )
                          : const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _profileLoaded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _businessName.isNotEmpty
                                      ? _businessName
                                      : 'My Business',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _email.isNotEmpty
                                      ? _email
                                      : 'vendor@sellar.com',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 160,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Account Section
          const _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.business_outlined,
            title: 'Business Profile',
            subtitle: _businessName.isNotEmpty ? _businessName : null,
            onTap: () => _navigateTo(const EditProfileScreen()),
          ),
          _SettingsTile(
            icon: Icons.payment_outlined,
            title: 'Payment Gateway',
            subtitle: 'Paystack',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Additional payment gateways coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: _currency,
            onTap: _showCurrencyPicker,
          ),
          const SizedBox(height: 20),

          // Preferences Section
          const _SectionHeader(title: 'Preferences'),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Additional languages coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _themeMode,
            onTap: _showThemePicker,
          ),
          _SettingsTile(
            icon: _notificationsEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            title: 'Notifications',
            subtitle: _notificationsEnabled ? 'On' : 'Off',
            trailing: Switch.adaptive(
              value: _notificationsEnabled,
              onChanged: (_) => _toggleNotifications(),
              activeColor: AppColors.primary,
            ),
            onTap: _toggleNotifications,
          ),
          const SizedBox(height: 20),

          // Support Section
          const _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => _navigateTo(const HelpSupportScreen()),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _navigateTo(const PrivacyPolicyScreen()),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _navigateTo(const TermsOfServiceScreen()),
          ),
          const SizedBox(height: 20),

          // About Section
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '$_appVersion (Beta)',
          ),
          _SettingsTile(
            icon: Icons.code_outlined,
            title: 'Open Source Licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Sellar',
                applicationVersion: _appVersion,
              );
            },
          ),
          const SizedBox(height: 28),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 20)
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
