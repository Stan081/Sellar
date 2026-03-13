import 'package:flutter/material.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/features/settings/presentation/settings_screen.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';

/// Analytics screen - business insights and metrics
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  String _businessName = 'My Business';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBusinessName();
  }

  Future<void> _loadBusinessName() async {
    try {
      final repo = AuthRepository(
        apiService: AppServices.api,
        storageService: AppServices.storage,
      );
      final vendor = await repo.getProfile();
      if (mounted) setState(() => _businessName = vendor.businessName);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(context),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Today', child: Text('Today')),
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
              PopupMenuItem(value: 'This Year', child: Text('This Year')),
            ],
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Products'),
            Tab(text: 'Links'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(period: _selectedPeriod),
          _ProductsTab(period: _selectedPeriod),
          _LinksTab(period: _selectedPeriod),
          _CustomersTab(period: _selectedPeriod),
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
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.period});
  final String period;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + mediaQuery.viewPadding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPIGrid(context),
          const SizedBox(height: 16),
          _buildTrendCard(context),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    final cards = <Widget>[
      const _MetricCard(
        title: 'Revenue',
        value: '\$12,450',
        change: '+12%',
        icon: Icons.payments_outlined,
        color: AppColors.primary,
      ),
      const _MetricCard(
        title: 'Orders',
        value: '187',
        change: '+8%',
        icon: Icons.shopping_bag_outlined,
        color: AppColors.info,
      ),
      const _MetricCard(
        title: 'Conversion',
        value: '4.6%',
        change: '+0.4%',
        icon: Icons.trending_up,
        color: AppColors.success,
      ),
      const _MetricCard(
        title: 'Avg Order',
        value: '\$66.58',
        change: '+3%',
        icon: Icons.attach_money,
        color: AppColors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = availableWidth >= 900
            ? 4
            : availableWidth >= 600
                ? 3
                : 2;
        const gap = 12.0;
        final itemWidth =
            (availableWidth - gap * (crossAxisCount - 1)) / crossAxisCount;
        final targetHeight = availableWidth >= 900
            ? 160.0
            : availableWidth >= 600
                ? 170.0
                : 190.0;
        final aspectRatio = itemWidth / targetHeight;

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

  Widget _buildTrendCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const _SimpleTrendChart(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Revenue', AppColors.primary),
                _buildLegendItem('Orders', AppColors.info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

// Products Tab
class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.period});
  final String period;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Total Products',
                  value: '22',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Sold',
                  value: '11',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Active',
                  value: '8',
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Low Stock',
                  value: '3',
                  icon: Icons.warning_outlined,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Sellers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const _TopProductItem('Wireless Headphones', '\$4,200', 0.9),
                  const _TopProductItem('Leather Wallet', '\$2,800', 0.6),
                  const _TopProductItem('Running Shoes', '\$1,900', 0.4),
                  const _TopProductItem('Smart Watch', '\$1,650', 0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Links Tab
class _LinksTab extends StatelessWidget {
  const _LinksTab({required this.period});
  final String period;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Public Links',
                  value: '72',
                  icon: Icons.link,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Private Links',
                  value: '48',
                  icon: Icons.lock_outline,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  const _FunnelItem('Created', 120, AppColors.info),
                  const _FunnelItem('Opened', 95, AppColors.primary),
                  const _FunnelItem('Initiated', 63, AppColors.secondary),
                  const _FunnelItem('Completed', 47, AppColors.success),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CTR: 21%',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Conv: 49%',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Avg: 3.4m',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Customers Tab
class _CustomersTab extends StatelessWidget {
  const _CustomersTab({required this.period});
  final String period;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Total',
                  value: '512',
                  icon: Icons.group_outlined,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'New',
                  value: '38',
                  icon: Icons.person_add_alt,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Returning',
                  value: '34%',
                  icon: Icons.repeat,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Email',
                  value: '58%',
                  icon: Icons.email_outlined,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Customers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const _CustomerItem('Alex Johnson', '6 orders', '\$520'),
                  const _CustomerItem('Mary Lee', '4 orders', '\$410'),
                  const _CustomerItem('Samir Khan', '3 orders', '\$305'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared Widgets
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  change,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
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
        padding: const EdgeInsets.all(16),
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

class _SimpleTrendChart extends StatelessWidget {
  const _SimpleTrendChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(14, (index) {
          final heights = [
            45.0,
            60.0,
            35.0,
            50.0,
            75.0,
            70.0,
            90.0,
            80.0,
            95.0,
            85.0,
            88.0,
            92.0,
            96.0,
            100.0
          ];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: heights[index],
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
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
              value: percent,
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
  const _FunnelItem(this.label, this.value, this.color);

  final String label;
  final int value;
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
              value: value / 120,
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

class _CustomerItem extends StatelessWidget {
  const _CustomerItem(this.name, this.orders, this.spent);

  final String name;
  final String orders;
  final String spent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
      title: Text(name),
      subtitle: Text(orders),
      trailing:
          Text(spent, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
