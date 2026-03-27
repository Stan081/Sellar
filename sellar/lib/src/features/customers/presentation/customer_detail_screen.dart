import 'package:flutter/material.dart';
import 'package:sellar/src/features/customers/data/customer_repository.dart';
import 'package:sellar/src/features/customers/domain/entities/customer.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/theme/app_spacing.dart';

/// Customer detail screen — shows customer info, insights, and purchase history
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomerRepository _repo;
  Customer? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = CustomerRepository(apiService: AppServices.api);
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final customer = await _repo.getCustomer(widget.customerId);
      if (mounted) {
        setState(() {
          _customer = customer;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_customer?.displayName ?? 'Customer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _customer != null
                  ? _buildContent()
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load customer',
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
              onPressed: _loadCustomer,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final c = _customer!;
    final purchases = c.purchases ?? [];

    return RefreshIndicator(
      onRefresh: _loadCustomer,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        children: [
          _buildProfileHeader(c),
          const SizedBox(height: 20),
          _buildInsightsRow(c),
          const SizedBox(height: 24),
          _buildContactInfo(c),
          const SizedBox(height: 24),
          _buildPurchaseHistory(purchases, c.currency),
        ],
      ),
    );
  }

  // ─── Profile Header ─────────────────────────────────────────────────────

  Widget _buildProfileHeader(Customer c) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: _avatarColor(c.id),
          child: Text(
            c.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          c.displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          c.identifier,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Customer since ${_formatDate(c.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
              ),
        ),
      ],
    );
  }

  // ─── Insights Row ───────────────────────────────────────────────────────

  Widget _buildInsightsRow(Customer c) {
    final avgOrder = c.purchaseCount > 0 ? c.totalSpent / c.purchaseCount : 0.0;
    final daysSinceLastPurchase = c.lastPurchaseAt != null
        ? DateTime.now().difference(c.lastPurchaseAt!).inDays
        : null;

    return Row(
      children: [
        _buildInsightCard(
          icon: Icons.attach_money,
          value: _formatCurrency(c.totalSpent, c.currency),
          label: 'Total Spent',
          color: AppColors.success,
        ),
        const SizedBox(width: 10),
        _buildInsightCard(
          icon: Icons.shopping_bag_outlined,
          value: '${c.purchaseCount}',
          label: 'Purchases',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _buildInsightCard(
          icon: Icons.receipt_long_outlined,
          value: _formatCurrency(avgOrder, c.currency),
          label: 'Avg Order',
          color: AppColors.accent,
        ),
        if (daysSinceLastPurchase != null) ...[
          const SizedBox(width: 10),
          _buildInsightCard(
            icon: Icons.schedule,
            value: daysSinceLastPurchase == 0
                ? 'Today'
                : '${daysSinceLastPurchase}d',
            label: 'Last Buy',
            color: AppColors.info,
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contact Info ───────────────────────────────────────────────────────

  Widget _buildContactInfo(Customer c) {
    final items = <_ContactItem>[];
    if (c.email != null && c.email!.isNotEmpty) {
      items.add(_ContactItem(Icons.email_outlined, 'Email', c.email!));
    }
    if (c.phone != null && c.phone!.isNotEmpty) {
      items.add(_ContactItem(Icons.phone_outlined, 'Phone', c.phone!));
    }
    if (c.billingAddress != null && c.billingAddress!.isNotEmpty) {
      items.add(_ContactItem(
          Icons.location_on_outlined, 'Billing', c.billingAddress!));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: items.map((item) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: AppColors.primary),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                subtitle: Text(
                  item.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Purchase History ───────────────────────────────────────────────────

  Widget _buildPurchaseHistory(List<Purchase> purchases, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Purchase History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              '${purchases.length} transactions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (purchases.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 40, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(
                      'No purchase records available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...purchases
              .map((p) => _PurchaseTile(purchase: p, currency: currency)),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatCurrency(double amount, String currency) {
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
    if (amount >= 1000) {
      return '$sym${amount.toStringAsFixed(0)}';
    }
    return '$sym${amount.toStringAsFixed(2)}';
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
}

// ─── Supporting Types ─────────────────────────────────────────────────────────

class _ContactItem {
  const _ContactItem(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({required this.purchase, required this.currency});
  final Purchase purchase;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon, size: 20, color: _statusColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.productName ?? 'Payment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDateTime(purchase.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(purchase.amount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    if (purchase.isCompleted) return AppColors.success;
    if (purchase.isPending) return AppColors.warning;
    return AppColors.error;
  }

  IconData get _statusIcon {
    if (purchase.isCompleted) return Icons.check_circle_outline;
    if (purchase.isPending) return Icons.schedule;
    return Icons.cancel_outlined;
  }

  String get _statusLabel {
    if (purchase.isCompleted) return 'Completed';
    if (purchase.isPending) return 'Pending';
    return 'Failed';
  }

  String _formatAmount(double amount) {
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

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute $amPm';
  }
}
