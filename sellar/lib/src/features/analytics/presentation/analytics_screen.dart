import 'package:flutter/material.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/features/customers/data/customer_repository.dart';
import 'package:sellar/src/features/customers/domain/entities/customer.dart';
import 'package:sellar/src/features/links/data/link_repository.dart';
import 'package:sellar/src/features/products/data/product_repository.dart';
import 'package:sellar/src/features/products/domain/entities/product.dart';
import 'package:sellar/src/features/settings/presentation/settings_screen.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/theme/app_spacing.dart';

/// Analytics screen - business insights and metrics
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _businessName = 'My Business';

  List<Product> _products = [];
  List<LinkModel> _links = [];
  List<Customer> _customers = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final authRepo = AuthRepository(
        apiService: AppServices.api,
        storageService: AppServices.storage,
      );
      final productRepo = ProductRepository(apiService: AppServices.api);
      final linkRepo = LinkRepository(apiService: AppServices.api);

      final customerRepo = CustomerRepository(apiService: AppServices.api);

      final results = await Future.wait([
        authRepo.getProfile(),
        productRepo.getProducts(),
        linkRepo.getLinks(),
        customerRepo.getCustomers(),
      ]);

      if (!mounted) return;
      setState(() {
        _businessName = (results[0] as dynamic).businessName;
        _products = results[1] as List<Product>;
        _links = results[2] as List<LinkModel>;
        _customers = results[3] as List<Customer>;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Computed metrics
  int get _totalProducts => _products.length;
  int get _activeProducts => _products.where((p) => p.isPending).length;
  int get _soldProducts => _products.where((p) => p.isSold).length;
  int get _lowStockProducts => _products.where((p) => p.isLowStock).length;

  int get _totalLinks => _links.length;
  int get _activeLinks =>
      _links.where((l) => l.isActive && !l.isExpired).length;
  int get _publicLinks => _links.where((l) => l.isPublic).length;
  int get _privateLinks => _links.where((l) => !l.isPublic).length;
  int get _totalViews => _links.fold(0, (s, l) => s + l.viewCount);
  int get _totalPayments => _links.fold(0, (s, l) => s + l.paymentCount);
  double get _totalRevenue =>
      _links.fold(0.0, (s, l) => s + (l.amount * l.paymentCount));
  int get _totalCustomers => _customers.length;
  double get _customerRevenue =>
      _customers.fold(0.0, (s, c) => s + c.totalSpent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Products'),
            Tab(text: 'Links'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildProductsTab(),
                    _buildLinksTab(),
                    _buildCustomersTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or tap retry',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          _businessName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Overview Tab ──────────────────────────────────────────
  Widget _buildOverviewTab() {
    final mediaQuery = MediaQuery.of(context);
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.fromLTRB(16, 16, 16, 16 + mediaQuery.viewPadding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKPIGrid(context),
            const SizedBox(height: 20),
            _buildQuickInsights(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    final cards = <Widget>[
      _MetricCard(
        title: 'Products',
        value: _totalProducts.toString(),
        subtitle: '$_activeProducts active',
        icon: Icons.inventory_2_outlined,
        color: AppColors.primary,
      ),
      _MetricCard(
        title: 'Links',
        value: _totalLinks.toString(),
        subtitle: '$_activeLinks active',
        icon: Icons.link,
        color: AppColors.info,
      ),
      _MetricCard(
        title: 'Views',
        value: _totalViews.toString(),
        subtitle: 'Total link views',
        icon: Icons.visibility_outlined,
        color: AppColors.success,
      ),
      _MetricCard(
        title: 'Payments',
        value: _totalPayments.toString(),
        subtitle: '\$${_totalRevenue.toStringAsFixed(0)} revenue',
        icon: Icons.payments_outlined,
        color: AppColors.secondary,
      ),
      _MetricCard(
        title: 'Customers',
        value: _totalCustomers.toString(),
        subtitle: '\$${_customerRevenue.toStringAsFixed(0)} total spent',
        icon: Icons.people_outline,
        color: AppColors.accent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth >= 600 ? 4 : 2;
        const gap = 12.0;
        final itemWidth =
            (availableWidth - gap * (crossAxisCount - 1)) / crossAxisCount;
        final aspectRatio = itemWidth / 140;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatio: aspectRatio,
          children: cards,
        );
      },
    );
  }

  Widget _buildQuickInsights(BuildContext context) {
    final convRate = _totalViews > 0
        ? (_totalPayments / _totalViews * 100).toStringAsFixed(1)
        : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _InsightRow(
              icon: Icons.trending_up,
              label: 'Conversion Rate',
              value: '$convRate%',
              color: AppColors.success,
            ),
            _InsightRow(
              icon: Icons.inventory_2,
              label: 'Low Stock Items',
              value: _lowStockProducts.toString(),
              color:
                  _lowStockProducts > 0 ? AppColors.warning : AppColors.success,
            ),
            _InsightRow(
              icon: Icons.link,
              label: 'Public / Private Links',
              value: '$_publicLinks / $_privateLinks',
              color: AppColors.info,
            ),
            _InsightRow(
              icon: Icons.check_circle_outline,
              label: 'Products Sold',
              value: _soldProducts.toString(),
              color: AppColors.primary,
            ),
            _InsightRow(
              icon: Icons.people_outline,
              label: 'Customers',
              value: _totalCustomers.toString(),
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Products Tab ──────────────────────────────────────────
  Widget _buildProductsTab() {
    final topProducts = List<Product>.from(_products)
      ..sort((a, b) => b.price.compareTo(a.price));
    final top5 = topProducts.take(5).toList();
    final maxPrice = top5.isNotEmpty ? top5.first.price : 1.0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Total Products',
                    value: _totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Sold',
                    value: _soldProducts.toString(),
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Active',
                    value: _activeProducts.toString(),
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Low Stock',
                    value: _lowStockProducts.toString(),
                    icon: Icons.warning_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Products by Price',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (top5.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No products yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      )
                    else
                      ...top5.map((p) => _TopProductItem(
                            p.name,
                            '\$${p.price.toStringAsFixed(2)}',
                            p.price / maxPrice,
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Customers Tab ──────────────────────────────────────────
  Widget _buildCustomersTab() {
    final topCustomers = List<Customer>.from(_customers)
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    final top5 = topCustomers.take(5).toList();
    final maxSpent = top5.isNotEmpty ? top5.first.totalSpent : 1.0;

    final avgSpend =
        _customers.isNotEmpty ? _customerRevenue / _customers.length : 0.0;
    final repeatCustomers = _customers.where((c) => c.purchaseCount > 1).length;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Total Customers',
                    value: _totalCustomers.toString(),
                    icon: Icons.people_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Repeat Buyers',
                    value: repeatCustomers.toString(),
                    icon: Icons.repeat,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Avg Spend',
                    value: '\$${avgSpend.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Total Revenue',
                    value: '\$${_customerRevenue.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Customers by Spend',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (top5.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No customers yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...top5.map((c) => _TopProductItem(
                            c.displayName,
                            '\$${c.totalSpent.toStringAsFixed(2)}',
                            c.totalSpent / maxSpent,
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Links Tab ─────────────────────────────────────────────
  Widget _buildLinksTab() {
    final totalCreated = _totalLinks;
    final maxFunnel = totalCreated > 0 ? totalCreated : 1;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Public Links',
                    value: _publicLinks.toString(),
                    icon: Icons.link,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Private Links',
                    value: _privateLinks.toString(),
                    icon: Icons.lock_outline,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Link Funnel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _FunnelItem(
                        'Created', totalCreated, maxFunnel, AppColors.info),
                    _FunnelItem(
                        'Viewed', _totalViews, maxFunnel, AppColors.primary),
                    _FunnelItem(
                        'Paid', _totalPayments, maxFunnel, AppColors.success),
                    const SizedBox(height: 12),
                    if (_totalViews > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'View rate: ${(_totalViews / totalCreated * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Conversion: ${(_totalPayments / _totalViews * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    else
                      Center(
                        child: Text(
                          'Create links to see funnel data',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TopProductItem extends StatelessWidget {
  const _TopProductItem(this.name, this.value, this.percent);

  final String name;
  final String value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelItem extends StatelessWidget {
  const _FunnelItem(this.label, this.value, this.maxValue, this.color);

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
