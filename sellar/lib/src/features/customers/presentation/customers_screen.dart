import 'package:flutter/material.dart';
import 'package:sellar/src/features/customers/data/customer_repository.dart';
import 'package:sellar/src/features/customers/domain/entities/customer.dart';
import 'package:sellar/src/features/customers/presentation/customer_detail_screen.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';

/// Customers screen — view and manage all customers
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late final CustomerRepository _repo;

  List<Customer> _customers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  _SortOption _sortBy = _SortOption.recent;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repo = CustomerRepository(apiService: AppServices.api);
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final customers = await _repo.getCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
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

  List<Customer> get _filteredCustomers {
    var filtered = _customers;

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((c) =>
              (c.name?.toLowerCase().contains(q) ?? false) ||
              (c.email?.toLowerCase().contains(q) ?? false) ||
              (c.phone?.contains(q) ?? false))
          .toList();
    }

    // Sort
    switch (_sortBy) {
      case _SortOption.recent:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOption.topSpenders:
        filtered.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case _SortOption.mostPurchases:
        filtered.sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
        break;
      case _SortOption.alphabetical:
        filtered.sort(
            (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        break;
    }

    return filtered;
  }

  void _showSortSheet() {
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
                    'Sort Customers',
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
            ..._SortOption.values.map((option) => ListTile(
                  leading: Icon(
                    option.icon,
                    color: _sortBy == option
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight:
                          _sortBy == option ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: _sortBy == option
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 22)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _sortBy = option);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
        appBar: AppBar(title: const Text('Customers')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load customers',
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
                  onPressed: _loadCustomers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _filteredCustomers;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: _customers.isEmpty
          ? _buildEmptyState()
          : filtered.isEmpty
              ? _buildNoResultsState()
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length + 1, // +1 for summary header
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSummaryHeader();
                      return _CustomerCard(
                        customer: filtered[index - 1],
                        onTap: () => _openCustomerDetail(filtered[index - 1]),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalCustomers = _customers.length;
    final totalRevenue = _customers.fold<double>(
        0, (sum, c) => sum + c.totalSpent);
    final totalPurchases = _customers.fold<int>(
        0, (sum, c) => sum + c.purchaseCount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildSummaryChip(
            icon: Icons.people_outline,
            label: '$totalCustomers',
            subtitle: 'Customers',
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _buildSummaryChip(
            icon: Icons.shopping_bag_outlined,
            label: '$totalPurchases',
            subtitle: 'Purchases',
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          _buildSummaryChip(
            icon: Icons.attach_money,
            label: _formatCompact(totalRevenue),
            subtitle: 'Revenue',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadCustomers,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No customers yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Customers will appear here when they make purchases through your payment links.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No customers match "$_searchQuery"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomerDetail(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customerId: customer.id),
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';
    return '\$${value.toStringAsFixed(0)}';
  }
}

// ─── Sort Options ─────────────────────────────────────────────────────────────

enum _SortOption {
  recent('Most Recent', Icons.schedule),
  topSpenders('Top Spenders', Icons.trending_up),
  mostPurchases('Most Purchases', Icons.shopping_cart_outlined),
  alphabetical('Alphabetical', Icons.sort_by_alpha);

  const _SortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─── Customer Card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap});
  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _avatarColor(customer.id),
                child: Text(
                  customer.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      customer.identifier,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildMiniStat(
                          Icons.shopping_bag_outlined,
                          '${customer.purchaseCount} purchases',
                        ),
                        const SizedBox(width: 12),
                        _buildMiniStat(
                          Icons.attach_money,
                          _formatAmount(customer.totalSpent, customer.currency),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _avatarColor(String id) {
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.accent,
      AppColors.info,
      AppColors.secondary,
      AppColors.warning,
    ];
    return colors[id.hashCode.abs() % colors.length];
  }

  String _formatAmount(double amount, String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'NGN': '₦',
      'GHS': 'GH₵',
      'KES': 'KSh',
      'ZAR': 'R',
    };
    final sym = symbols[currency] ?? '\$';
    return '$sym${amount.toStringAsFixed(2)}';
  }
}
