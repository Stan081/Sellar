import 'package:sellar/src/services/api_service.dart';
import 'package:sellar/src/services/storage_service.dart';

enum SocialPlatformApi { facebook, instagram }

class SocialConnectionModel {
  final SocialPlatformApi platform;
  final String? platformUsername;
  final String? pageName;
  final String? pageId;
  final DateTime connectedAt;

  const SocialConnectionModel({
    required this.platform,
    this.platformUsername,
    this.pageName,
    this.pageId,
    required this.connectedAt,
  });

  factory SocialConnectionModel.fromJson(Map<String, dynamic> json) {
    final p = (json['platform'] as String).toUpperCase();
    return SocialConnectionModel(
      platform: p == 'INSTAGRAM'
          ? SocialPlatformApi.instagram
          : SocialPlatformApi.facebook,
      platformUsername: json['platformUsername'] as String?,
      pageName: json['pageName'] as String?,
      pageId: json['pageId'] as String?,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
    );
  }

  String get displayName => pageName ?? platformUsername ?? platform.name;
}

class SocialRepository {
  SocialRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _api = apiService,
        _storage = storageService;

  final ApiService _api;
  final StorageService _storage;

  static const _base = '/api/social';

  Future<List<SocialConnectionModel>> getConnections() async {
    final res = await _api.get('$_base/connections');
    if (res.statusCode == 200) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => SocialConnectionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load social connections');
  }

  /// Returns the OAuth URL to open in the browser.
  /// Appends the vendor JWT as ?token= so the backend can identify the vendor
  /// without relying on an Authorization header (which browsers can't send on redirects).
  Future<String> connectUrl(
      SocialPlatformApi platform, String apiBaseUrl) async {
    final p =
        platform == SocialPlatformApi.instagram ? 'instagram' : 'facebook';
    final base = '$apiBaseUrl/api/social/$p/connect';
    // Try Dio headers first (fastest), fall back to secure storage
    final token = _api.getAuthToken() ?? await _storage.getUserToken();
    if (token != null && token.isNotEmpty) {
      return '$base?token=${Uri.encodeComponent(token)}';
    }
    return base;
  }

  Future<void> disconnect(SocialPlatformApi platform) async {
    final p = platform.name;
    final res = await _api.delete('$_base/$p/disconnect');
    if (res.statusCode != 200) {
      throw Exception('Failed to disconnect $p');
    }
  }

  Future<String> postToFacebook({
    required String message,
    String? imageUrl,
  }) async {
    final res = await _api.post(
      '$_base/facebook/post',
      data: {
        'message': message,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
    );
    if (res.statusCode == 200) return res.data['postId'] as String;
    throw Exception(res.data?['error'] ?? 'Facebook post failed');
  }

  Future<String> postToInstagram({
    required String caption,
    required String imageUrl,
  }) async {
    final res = await _api.post(
      '$_base/instagram/post',
      data: {'caption': caption, 'imageUrl': imageUrl},
    );
    if (res.statusCode == 200) return res.data['postId'] as String;
    throw Exception(res.data?['error'] ?? 'Instagram post failed');
  }
}
