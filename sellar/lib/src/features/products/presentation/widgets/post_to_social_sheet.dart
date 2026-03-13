import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sellar/src/features/products/domain/entities/product.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

/// Bottom sheet for composing and posting a product to social media
class PostToSocialSheet extends StatefulWidget {
  const PostToSocialSheet({super.key, required this.product});

  final Product product;

  @override
  State<PostToSocialSheet> createState() => _PostToSocialSheetState();
}

class _PostToSocialSheetState extends State<PostToSocialSheet> {
  late TextEditingController _captionController;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: _defaultCaption());
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Downloads the product image to a temp file and returns an XFile.
  /// Returns null if the image URL is empty or download fails.
  Future<XFile?> _downloadImage() async {
    final imageUrl = widget.product.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return null;
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;
      final dir = await getTemporaryDirectory();
      final ext = imageUrl.split('.').last.split('?').first;
      final file =
          File('${dir.path}/share_product.${ext.isNotEmpty ? ext : 'jpg'}');
      await file.writeAsBytes(response.bodyBytes);
      return XFile(file.path);
    } catch (_) {
      return null;
    }
  }

  String _defaultCaption() {
    final price =
        '${widget.product.currency} ${widget.product.price.toStringAsFixed(2)}';
    final tags = widget.product.tags.map((t) => '#$t').join(' ');
    return '✨ ${widget.product.name}\n\n'
        '${widget.product.description}\n\n'
        '💰 $price\n\n'
        '🛒 Order now: https://sellar.app/p/${widget.product.id}\n\n'
        '${tags.isNotEmpty ? '$tags\n' : ''}'
        '#sellar #shop #buy';
  }

  // ── Native OS share (image + text) ────────────────────────────────────────

  Future<void> _nativeShare() async {
    final caption = _captionController.text.trim();
    // Compute share origin for iOS (required to avoid PlatformException)
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromCenter(
            center: MediaQuery.of(context).size.center(Offset.zero),
            width: 1,
            height: 1,
          );
    setState(() {
      _isPosting = true;
    });
    try {
      final imageFile = await _downloadImage();
      if (imageFile != null) {
        await Share.shareXFiles(
          [imageFile],
          text: caption,
          sharePositionOrigin: origin,
        );
      } else {
        await Share.share(caption, sharePositionOrigin: origin);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (widget.product.imageUrl != null &&
                widget.product.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Header row + product image thumbnail
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFF43F5E)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Product',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.product.imageUrl != null &&
                    widget.product.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.imageUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Caption composer
            Text(
              'Caption',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 8,
                    minLines: 5,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Write your post caption...',
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _captionController.text = _defaultCaption();
                          }),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _captionController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Caption copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPosting ? null : _nativeShare,
                icon: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
