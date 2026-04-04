import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sellar/src/features/links/data/link_repository.dart';
import 'package:sellar/src/features/products/data/product_repository.dart';
import 'package:sellar/src/features/products/domain/entities/product.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/theme/app_spacing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sellar/src/features/links/presentation/widgets/product_search_dropdown.dart';

/// Links screen - payment link management
class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final LinkRepository _repo;

  List<LinkModel> _links = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repo = LinkRepository(apiService: AppServices.api);
    _loadLinks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLinks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final links = await _repo.getLinks();
      if (mounted) {
        setState(() {
          _links = links;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<LinkModel> get _activeLinks =>
      _links.where((l) => l.isActive && !l.isExpired).toList();
  List<LinkModel> get _expiredLinks =>
      _links.where((l) => l.isExpired || !l.isActive).toList();

  void _showCreateLinkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateLinkSheet(
        repo: _repo,
        productRepo: ProductRepository(apiService: AppServices.api),
        onCreated: (link) {
          setState(() => _links.insert(0, link));
        },
      ),
    );
  }

  void _showLinkActions(LinkModel link) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LinkActionsSheet(link: link),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load links',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadLinks,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Links'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Active (${_activeLinks.length})'),
            Tab(text: 'Expired (${_expiredLinks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _activeLinks.isEmpty
              ? _buildEmptyState()
              : _buildLinkList(_activeLinks),
          _expiredLinks.isEmpty
              ? _buildEmptyState(isExpired: true)
              : _buildLinkList(_expiredLinks),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'links-fab',
        onPressed: _showCreateLinkSheet,
        icon: const Icon(Icons.add_link),
        label: const Text('Create Link'),
      ),
    );
  }

  Widget _buildLinkList(List<LinkModel> links) {
    return RefreshIndicator(
      onRefresh: _loadLinks,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, 100),
        itemCount: links.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _LinkCard(
          link: links[index],
          onTap: () => _showLinkActions(links[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isExpired = false}) {
    return RefreshIndicator(
      onRefresh: _loadLinks,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpired ? Icons.link_off : Icons.add_link,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isExpired ? 'No expired links' : 'No payment links yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isExpired
                          ? 'Expired links will appear here'
                          : 'Create a payment link and share it with customers to start receiving payments',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (!isExpired) ...[
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: _showCreateLinkSheet,
                        icon: const Icon(Icons.add_link),
                        label: const Text('Create Your First Link'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Link Card ────────────────────────────────────────────────────────────────

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.link, required this.onTap});
  final LinkModel link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      link.productName ?? 'Custom Link',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypeBadge(),
                  if (link.isExpired) ...[
                    const SizedBox(width: 6),
                    _buildExpiredBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${link.currency} ${link.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                link.url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(context, Icons.visibility_outlined,
                      '${link.viewCount} views'),
                  const SizedBox(width: 16),
                  _buildStat(context, Icons.check_circle_outline,
                      '${link.paymentCount} paid'),
                  const Spacer(),
                  Text(
                    _formatDate(link.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link.url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final box = context.findRenderObject() as RenderBox?;
                        final origin = box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : Rect.fromCenter(
                                center: MediaQuery.of(context)
                                    .size
                                    .center(Offset.zero),
                                width: 1,
                                height: 1,
                              );

                        Share.share(
                          link.url,
                          sharePositionOrigin: origin,
                        );
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: link.isPublic
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            link.isPublic ? Icons.public : Icons.lock_outline,
            size: 12,
            color: link.isPublic ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 4),
          Text(
            link.isPublic ? 'Public' : 'Private',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: link.isPublic ? AppColors.success : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Expired',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

// ─── Link Actions Sheet ───────────────────────────────────────────────────────

class _LinkActionsSheet extends StatelessWidget {
  const _LinkActionsSheet({required this.link});
  final LinkModel link;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Share "${link.productName ?? 'Link'}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            link.url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          _buildAction(
            context,
            icon: Icons.copy,
            label: 'Copy Link',
            color: AppColors.primary,
            onTap: () {
              Clipboard.setData(ClipboardData(text: link.url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied to clipboard')),
              );
            },
          ),
          _buildAction(
            context,
            icon: Icons.share,
            label: 'Share',
            color: AppColors.primary,
            onTap: () {
              final box = context.findRenderObject() as RenderBox?;
              final origin = box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : Rect.fromCenter(
                      center: MediaQuery.of(context).size.center(Offset.zero),
                      width: 1,
                      height: 1,
                    );
              Navigator.pop(context);
              Share.share(link.url, sharePositionOrigin: origin);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

// ─── Create Link Sheet ────────────────────────────────────────────────────────

class _CreateLinkSheet extends StatefulWidget {
  const _CreateLinkSheet({
    required this.repo,
    required this.productRepo,
    required this.onCreated,
  });
  final LinkRepository repo;
  final ProductRepository productRepo;
  final void Function(LinkModel) onCreated;

  @override
  State<_CreateLinkSheet> createState() => _CreateLinkSheetState();
}

class _CreateLinkSheetState extends State<_CreateLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // Products
  List<Product> _products = [];
  bool _loadingProducts = true;
  bool _productsError = false;
  Product? _selectedProduct;

  // Fields
  String _currency = 'USD';
  bool _isPublic = true;
  bool _isReusable = false;
  bool _hasExpiry = false;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  bool _isCreating = false;

  static const _currencies = ['USD', 'EUR', 'GBP', 'NGN', 'GHS', 'KES', 'ZAR'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.productRepo.getProducts().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout loading products'),
          );
      if (mounted) {
        setState(() {
          _products = products;
          _loadingProducts = false;
          _productsError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingProducts = false;
          _productsError = true;
        });
        debugPrint('Failed to load products: $e');
      }
    }
  }

  void _onProductSelected(Product? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null) {
        _amountController.text = product.price.toStringAsFixed(2);
        _currency = product.currency.isNotEmpty ? product.currency : 'USD';
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);

    try {
      final link = await widget.repo.createLink(
        productId: _selectedProduct?.id,
        amount: double.parse(_amountController.text.trim()),
        currency: _currency,
        isPublic: _isPublic,
        isReusable: _isReusable,
        expiresAt: _hasExpiry ? _expiryDate : null,
      );

      if (mounted) {
        widget.onCreated(link);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment link created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Create Payment Link',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Link to a product or set a custom amount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),

                // ── Product picker ──────────────────────────────────────
                const _SectionLabel(label: 'Product (optional)'),
                const SizedBox(height: 8),
                _loadingProducts
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : _productsError
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 16, color: AppColors.error),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Failed to load products',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadProducts,
                                  child: const Text('Retry',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          )
                        : ProductSearchDropdown(
                            products: _products,
                            selectedProduct: _selectedProduct,
                            onSelected: _onProductSelected,
                            hintText: 'Search products...',
                          ),
                const SizedBox(height: 16),

                // ── Amount + Currency ───────────────────────────────────
                const _SectionLabel(label: 'Amount'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(hintText: '0.00'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) {
                            return 'Invalid';
                          }
                          if (double.parse(v.trim()) <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration:
                            const InputDecoration(labelText: 'Currency'),
                        items: _currencies
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _currency = v ?? 'USD'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Link type ───────────────────────────────────────────
                const _SectionLabel(label: 'Link type'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Public'),
                      selected: _isPublic,
                      onSelected: (_) => setState(() => _isPublic = true),
                      selectedColor: AppColors.success.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: _isPublic
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Private'),
                      selected: !_isPublic,
                      onSelected: (_) => setState(() => _isPublic = false),
                      selectedColor: AppColors.accent.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: !_isPublic
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isPublic
                      ? 'Anyone with the link can pay'
                      : 'Only shared with specific customers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),

                // ── Reusable toggle ─────────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reusable link'),
                  subtitle: Text(
                    _isReusable
                        ? 'Can be paid multiple times'
                        : 'Single use — deactivates after first payment',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: _isReusable,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isReusable = v),
                ),

                // ── Expiry toggle ───────────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set expiry date'),
                  subtitle: _hasExpiry
                      ? Text(
                          'Expires ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        )
                      : null,
                  value: _hasExpiry,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) async {
                    if (v) {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiryDate,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _hasExpiry = true;
                          _expiryDate = picked;
                        });
                      }
                    } else {
                      setState(() => _hasExpiry = false);
                    }
                  },
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _create,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Generate Link'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
