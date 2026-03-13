import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:sellar/src/config/app_config.dart';
import 'package:sellar/src/features/social/data/social_repository.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Model representing a connected social platform
class SocialAccount {
  final SocialPlatform platform;
  bool isConnected;
  String? username;
  String? profileImageUrl;
  DateTime? connectedAt;

  SocialAccount({
    required this.platform,
    this.isConnected = false,
    this.username,
    this.profileImageUrl,
    this.connectedAt,
  });
}

enum SocialPlatform { facebook, instagram, whatsapp, tiktok }

extension SocialPlatformExt on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.whatsapp:
        return 'WhatsApp Business';
      case SocialPlatform.tiktok:
        return 'TikTok';
    }
  }

  String get description {
    switch (this) {
      case SocialPlatform.facebook:
        return 'Post products to your Facebook Page or feed';
      case SocialPlatform.instagram:
        return 'Share products to your Instagram profile and stories';
      case SocialPlatform.whatsapp:
        return 'Share products via WhatsApp Status and messages';
      case SocialPlatform.tiktok:
        return 'Post product videos to TikTok';
    }
  }

  Color get color {
    switch (this) {
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C);
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SocialPlatform.tiktok:
        return const Color(0xFF010101);
    }
  }

  IconData get icon {
    switch (this) {
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.whatsapp:
        return Icons.message;
      case SocialPlatform.tiktok:
        return Icons.music_video;
    }
  }

  /// OAuth / app connect URL (stubbed — replace with real OAuth endpoints)
  String get connectUrl {
    switch (this) {
      case SocialPlatform.facebook:
        return 'https://www.facebook.com/v18.0/dialog/oauth?client_id=YOUR_FB_APP_ID&redirect_uri=https://sellar.app/auth/facebook/callback&scope=pages_manage_posts,instagram_basic';
      case SocialPlatform.instagram:
        return 'https://api.instagram.com/oauth/authorize?client_id=YOUR_IG_APP_ID&redirect_uri=https://sellar.app/auth/instagram/callback&scope=user_profile,user_media&response_type=code';
      case SocialPlatform.whatsapp:
        return 'https://wa.me/';
      case SocialPlatform.tiktok:
        return 'https://www.tiktok.com/auth/authorize/?client_key=YOUR_TT_CLIENT_KEY&scope=user.info.basic,video.upload&response_type=code&redirect_uri=https://sellar.app/auth/tiktok/callback';
    }
  }
}

/// Screen for managing connected social media accounts
class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() =>
      _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  late final SocialRepository _repo;
  late final AppLinks _appLinks;

  final List<SocialAccount> _accounts = [
    SocialAccount(platform: SocialPlatform.facebook),
    SocialAccount(platform: SocialPlatform.instagram),
    SocialAccount(platform: SocialPlatform.whatsapp),
    SocialAccount(platform: SocialPlatform.tiktok),
  ];

  bool _isLoading = true;
  bool _isConnecting = false;
  SocialPlatform? _connectingPlatform;

  @override
  void initState() {
    super.initState();
    _repo = SocialRepository(
      apiService: AppServices.api,
      storageService: AppServices.storage,
    );
    _appLinks = AppLinks();
    _loadConnections();
    _listenDeepLinks();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    try {
      final connections = await _repo.getConnections();
      if (!mounted) return;
      setState(() {
        for (final conn in connections) {
          final platform = conn.platform == SocialPlatformApi.facebook
              ? SocialPlatform.facebook
              : SocialPlatform.instagram;
          final account = _accounts.firstWhere((a) => a.platform == platform,
              orElse: () => SocialAccount(platform: platform));
          account.isConnected = true;
          account.username = conn.displayName;
          account.connectedAt = conn.connectedAt;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _listenDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;
      // sellar://social/success?platform=facebook&username=...
      if (uri.host == 'social' && uri.pathSegments.firstOrNull == 'success') {
        final platformStr = uri.queryParameters['platform'] ?? '';
        final username = uri.queryParameters['username'] ?? '';
        final platform = platformStr == 'instagram'
            ? SocialPlatform.instagram
            : SocialPlatform.facebook;
        setState(() {
          _isConnecting = false;
          _connectingPlatform = null;
          final account = _accounts.firstWhere((a) => a.platform == platform);
          account.isConnected = true;
          account.username =
              username.isNotEmpty ? username : platform.displayName;
          account.connectedAt = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${platform.displayName} connected!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (uri.host == 'social' &&
          uri.pathSegments.firstOrNull == 'error') {
        final error = uri.queryParameters['error'] ?? 'Unknown error';
        setState(() {
          _isConnecting = false;
          _connectingPlatform = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  Future<void> _connectAccount(SocialAccount account) async {
    // WhatsApp — no OAuth, mark as connected immediately
    if (account.platform == SocialPlatform.whatsapp) {
      setState(() {
        account.isConnected = true;
        account.username = 'WhatsApp Business';
        account.connectedAt = DateTime.now();
      });
      return;
    }

    // TikTok — not yet implemented
    if (account.platform == SocialPlatform.tiktok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TikTok integration coming soon!')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectingPlatform = account.platform;
    });

    final apiPlatform = account.platform == SocialPlatform.instagram
        ? SocialPlatformApi.instagram
        : SocialPlatformApi.facebook;
    final oauthUrl = await _repo.connectUrl(apiPlatform, AppConfig.apiBaseUrl);

    final launched = await launchUrl(
      Uri.parse(oauthUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      setState(() {
        _isConnecting = false;
        _connectingPlatform = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser')),
      );
    }
    // Result arrives via deep link — _listenDeepLinks handles it
  }

  void _disconnectAccount(SocialAccount account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Disconnect ${account.platform.displayName}'),
        content: Text(
          'Are you sure you want to disconnect your '
          '${account.platform.displayName} account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                if (account.platform == SocialPlatform.facebook ||
                    account.platform == SocialPlatform.instagram) {
                  final apiPlatform =
                      account.platform == SocialPlatform.instagram
                          ? SocialPlatformApi.instagram
                          : SocialPlatformApi.facebook;
                  await _repo.disconnect(apiPlatform);
                }
                if (mounted) {
                  setState(() {
                    account.isConnected = false;
                    account.username = null;
                    account.connectedAt = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${account.platform.displayName} disconnected.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to disconnect: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectedCount = _accounts.where((a) => a.isConnected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Accounts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary banner
                _buildSummaryBanner(context, connectedCount),
                const SizedBox(height: 24),

                // Why connect section
                _buildInfoCard(context),
                const SizedBox(height: 24),

                Text(
                  'Social Platforms',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Platform cards
                ..._accounts.map((account) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlatformCard(
                        account: account,
                        isConnecting: _isConnecting &&
                            _connectingPlatform == account.platform,
                        onConnect: () => _connectAccount(account),
                        onDisconnect: () => _disconnectAccount(account),
                      ),
                    )),

                const SizedBox(height: 16),

                // Note about OAuth
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 16, color: AppColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sellar uses official OAuth to connect your accounts. '
                          'We never store your passwords.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.info,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildSummaryBanner(BuildContext context, int connectedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: connectedCount > 0
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              connectedCount > 0 ? Icons.check_circle : Icons.link_off,
              color: connectedCount > 0 ? AppColors.success : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connectedCount == 0
                      ? 'No accounts connected'
                      : '$connectedCount of ${_accounts.length} accounts connected',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  connectedCount == 0
                      ? 'Connect your socials to post products directly'
                      : 'You can post products directly to your connected platforms',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Why connect your accounts?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBenefit(context, Icons.send,
                'Post products directly without copy-pasting'),
            _buildBenefit(context, Icons.auto_fix_high,
                'Auto-generate captions with product details'),
            _buildBenefit(context, Icons.bar_chart,
                'Track which platforms drive the most sales'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ─── Platform Card ────────────────────────────────────────────────────────────

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.account,
    required this.isConnecting,
    required this.onConnect,
    required this.onDisconnect,
  });

  final SocialAccount account;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final platform = account.platform;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Platform icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: platform.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(platform.icon, color: platform.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            platform.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (account.isConnected) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Connected',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.isConnected && account.username != null
                            ? account.username!
                            : platform.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (account.isConnected && account.connectedAt != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 12, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Connected ${_formatDate(account.connectedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: account.isConnected
                  ? OutlinedButton.icon(
                      onPressed: onDisconnect,
                      icon: const Icon(Icons.link_off, size: 16),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: isConnecting ? null : onConnect,
                      icon: isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_link, size: 16),
                      label: Text(isConnecting
                          ? 'Connecting...'
                          : 'Connect ${platform.displayName}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: platform.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}
