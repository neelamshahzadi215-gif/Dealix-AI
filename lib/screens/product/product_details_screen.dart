import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product/product.dart';
import '../../models/store/store_offer.dart';
import '../../services/mock/mock_data_service.dart';
import '../../services/favorites/favorites_store.dart';
import '../../widgets/states/product_actions.dart';
import '../../widgets/states/product_image_section.dart';
import '../../widgets/states/product_info_section.dart';
import '../favorites/favorites_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final MockDataService _mockDataService = MockDataService();

  Product? _product;
  List<StoreOffer> _storeOffers = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    FavoritesStore.instance.addListener(_onFavoritesChanged);
    _loadProductDetails();
  }

  void _onFavoritesChanged() {
    if (!mounted) return;

    setState(() {
      _isFavorite =
          _product != null && FavoritesStore.instance.isFavorite(_product!.id);
    });
  }

  @override
  void dispose() {
    FavoritesStore.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      final products = await _mockDataService.getProducts();

      final selectedProduct =
          widget.product ?? (products.isNotEmpty ? products.first : null);

      if (selectedProduct == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final offers = await _mockDataService.getStoreOffers(selectedProduct.id);

      if (!mounted) return;

      setState(() {
        _product = selectedProduct;
        _storeOffers = offers;
        _isFavorite = FavoritesStore.instance.isFavorite(selectedProduct.id);
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

  Future<void> _openStore() async {
    final availableOffers = _storeOffers
        .where((offer) => offer.isAvailable && offer.storeUrl.trim().isNotEmpty)
        .toList();

    if (availableOffers.isEmpty) {
      _showMessage('No available store link found.');
      return;
    }

    availableOffers.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));

    await _openSpecificStore(availableOffers.first);
  }

  Future<void> _openSpecificStore(StoreOffer offer) async {
    if (!offer.isAvailable) {
      _showMessage('${offer.storeName} is currently unavailable.');
      return;
    }

    final uri = Uri.tryParse(offer.storeUrl.trim());

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      _showMessage('The store link is invalid.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage('Could not open ${offer.storeName}.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not open ${offer.storeName}.');
      }
    }
  }

  void _toggleFavorite() {
    final product = _product;
    if (product == null) return;

    FavoritesStore.instance.toggleFavorite(product);

    final isNowFavorite = FavoritesStore.instance.isFavorite(product.id);

    _showMessage(
      isNowFavorite ? 'Added to favorites.' : 'Removed from favorites.',
    );
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'My Favorites',
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite, color: AppColors.error),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (_hasError || _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text(
                'Unable to load product details.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadProductDetails();
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadProductDetails,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProductImageSection(product: product),
          const SizedBox(height: 16),

          ProductInfoSection(product: product),
          const SizedBox(height: 20),

          _buildStoreSummary(),
          const SizedBox(height: 20),

          ProductActions(
            isFavorite: _isFavorite,
            onFavoriteTap: _toggleFavorite,
            onStoreTap: _openStore,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStoreSummary() {
    final availableOffers =
        _storeOffers.where((offer) => offer.isAvailable).toList()
          ..sort((a, b) => a.totalPrice.compareTo(b.totalPrice));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Stores',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (_storeOffers.isEmpty)
            const Text(
              'No store offers available.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ..._storeOffers.map((offer) {
              final isBestPrice =
                  availableOffers.isNotEmpty &&
                  offer.id == availableOffers.first.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isBestPrice ? AppColors.softMint : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBestPrice
                        ? AppColors.primaryGreen
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primaryGreen,
                      size: 28,
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.storeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            offer.isAvailable ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: offer.isAvailable
                                  ? AppColors.primaryGreen
                                  : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            '${offer.currency} '
                            '${offer.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          if (offer.deliveryFee != null &&
                              offer.deliveryFee! > 0)
                            Text(
                              'Delivery: ${offer.currency} '
                              '${offer.deliveryFee!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),

                          if (isBestPrice)
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                'Best Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      tooltip: 'Visit ${offer.storeName}',
                      onPressed: offer.isAvailable
                          ? () => _openSpecificStore(offer)
                          : null,
                      icon: const Icon(
                        Icons.open_in_new,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
