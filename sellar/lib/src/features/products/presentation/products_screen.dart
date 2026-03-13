import 'package:flutter/material.dart';
import 'package:sellar/src/features/auth/domain/auth_repository.dart';
import 'package:sellar/src/features/products/data/product_repository.dart';
import 'package:sellar/src/features/products/presentation/add_product_screen.dart';
import 'package:sellar/src/features/settings/presentation/settings_screen.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';
import 'package:sellar/src/features/products/domain/entities/product.dart';
import 'package:sellar/src/features/products/presentation/widgets/product_card.dart';

/// Products screen - manage product catalog
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ProductRepository _repo;
  late final AuthRepository _authRepo;

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _businessName = 'My Business';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repo = ProductRepository(apiService: AppServices.api);
    _authRepo = AuthRepository(
      apiService: AppServices.api,
      storageService: AppServices.storage,
    );
    _loadProducts();
    _loadBusinessName();
  }

  Future<void> _loadBusinessName() async {
    try {
      final vendor = await _authRepo.getProfile();
      if (mounted) setState(() => _businessName = vendor.businessName);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _repo.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
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

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (result != null && mounted) {
      setState(() => _products.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingProducts = _products.where((p) => p.isPending).toList();
    final soldProducts = _products.where((p) => p.isSold).toList();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load products',
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
                  onPressed: _loadProducts,
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
        title: _buildAppBarTitle(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
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
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Active'),
                  const SizedBox(width: 8),
                  _buildBadge(pendingProducts.length),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sold'),
                  const SizedBox(width: 8),
                  _buildBadge(soldProducts.length),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductGrid(pendingProducts, isPending: true),
          _buildProductGrid(soldProducts, isPending: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'products-fab',
        onPressed: _navigateToAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
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

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, {required bool isPending}) {
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildEmptyState(isPending),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.66,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isPending) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending
                    ? Icons.inventory_2_outlined
                    : Icons.check_circle_outline,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPending ? 'No active products' : 'No sold products yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'Add products to start selling'
                  : 'Your sold products will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
