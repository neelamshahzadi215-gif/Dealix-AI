
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/section_header.dart';

class AlternativesScreen extends StatefulWidget {
  const AlternativesScreen({super.key});

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen> {
  final MockDataService _mockDataService = MockDataService();

  List<Product> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _mockDataService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Cheaper Alternatives',
          textAlign: TextAlign.left,
          style: (theme.textTheme.titleLarge ??
                  AppTheme.lightTheme.textTheme.titleLarge)
              ?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -55,
            left: -45,
            child: _buildMintDecoration(170),
          ),
          Positioned(
            bottom: -75,
            right: -55,
            child: _buildMintDecoration(210),
          ),
          SafeArea(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: colors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load products.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: _loadProducts,
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Text(
          'No alternatives available.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    final visibleProducts =
        _showAll ? _products : _products.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          'Find similar products at better prices.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(title: 'Similar Products'),
        const SizedBox(height: 14),
        ...visibleProducts.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProductCard(context, product),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          text: _showAll ? 'Show Less' : 'See More Alternatives',
      
          onPressed: () {
            setState(() {
              _showAll = !_showAll;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final currentPrice = product.price.round();

    // Display estimated savings of 40%.
    // Replace this calculation with actual offer data when available.
    final savings = (currentPrice * 2 / 3).round();
    final originalPrice = currentPrice + savings;
    final discount = originalPrice > 0
        ? ((savings / originalPrice) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 86,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shopping_bag_outlined,
                          size: 38,
                          color: colors.primary,
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      size: 38,
                      color: colors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Price: Rs. ${_formatPrice(currentPrice)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Savings: Save Rs. ${_formatPrice(savings)} ($discount%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMintDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.softMint.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}
