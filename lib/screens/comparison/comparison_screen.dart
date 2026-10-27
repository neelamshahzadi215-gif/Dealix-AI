//
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product/product.dart';
import '../../models/store/store_offer.dart';
import '../../services/mock/mock_data_service.dart';
import '../../widgets/common/store_price_card.dart';

class ComparisonScreen extends StatefulWidget {
  final Product product;

  const ComparisonScreen({super.key, required this.product});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final MockDataService _mockDataService = MockDataService();

  List<StoreOffer> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'Price';

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offers = await _mockDataService.getStoreOffers(widget.product.id);

      if (!mounted) return;

      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not load store offers. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<StoreOffer> get _sortedOffers {
    final offers = _offers.where((offer) => offer.isAvailable).toList();

    if (_selectedFilter == 'Rating') {
      offers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else if (_selectedFilter == 'Store') {
      offers.sort((a, b) => a.storeName.compareTo(b.storeName));
    } else {
      offers.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    }

    return offers;
  }

  StoreOffer? get _bestPriceOffer {
    final available = _offers.where((offer) => offer.isAvailable);

    if (available.isEmpty) return null;

    return available.reduce((a, b) => a.totalPrice <= b.totalPrice ? a : b);
  }

  double get _highestAvailablePrice {
    final available = _offers.where((offer) => offer.isAvailable);

    if (available.isEmpty) return 0;

    return available
        .map((offer) => offer.totalPrice)
        .reduce((a, b) => a > b ? a : b);
  }

  double get _savingAmount {
    final bestOffer = _bestPriceOffer;

    if (bestOffer == null) return 0;

    return _highestAvailablePrice - bestOffer.totalPrice;
  }

  double get _savingPercentage {
    if (_highestAvailablePrice <= 0) return 0;

    return (_savingAmount / _highestAvailablePrice) * 100;
  }

  String _formatPrice(double price) {
    return '${widget.product.currency} ${price.toStringAsFixed(0)}';
  }

  Future<void> _openStore(StoreOffer offer) async {
    if (!offer.isAvailable) {
      _showMessage('This store is currently unavailable.');
      return;
    }

    final uri = Uri.tryParse(offer.storeUrl.trim());

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      _showMessage('This store link is invalid.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        _showMessage('Could not open ${offer.storeName}.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not open ${offer.storeName}.');
      }
    }
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Price Comparison'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : _errorMessage != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final offers = _sortedOffers;
    final bestOffer = _bestPriceOffer;

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildProductHeader(),
          const SizedBox(height: 18),

          if (bestOffer != null) ...[
            _buildBestDealCard(bestOffer),
            const SizedBox(height: 24),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  'Compare store prices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                ),
                child: Text(
                  '${_offers.length} offers',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.secondaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _buildFilters(),
          const SizedBox(height: 16),

          if (offers.isEmpty)
            _buildEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850
                    ? 3
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;

                if (columns == 1) {
                  return Column(
                    children: offers.map((offer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StorePriceCard(
                          offer: offer,
                          isBestPrice: bestOffer?.id == offer.id,
                          onStoreTap: () => _openStore(offer),
                        ),
                      );
                    }).toList(),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 300,
                  ),
                  itemBuilder: (context, index) {
                    final offer = offers[index];

                    return StorePriceCard(
                      offer: offer,
                      isBestPrice: bestOffer?.id == offer.id,
                      onStoreTap: () => _openStore(offer),
                    );
                  },
                );
              },
            ),

          _buildUnavailableSection(bestOffer),

          // Saving button at the bottom of the comparison screen.
          _buildSavingsButton(),
        ],
      ),
    );
  }

  Widget _buildUnavailableSection(StoreOffer? bestOffer) {
    final unavailable = _offers.where((offer) => !offer.isAvailable).toList();

    if (unavailable.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currently unavailable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...unavailable.map(
            (offer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StorePriceCard(
                offer: offer,
                isBestPrice: bestOffer?.id == offer.id,
                onStoreTap: () => _openStore(offer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.softMint,
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 36,
              color: AppColors.secondaryTeal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.product.brand} • ${widget.product.model}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.product.rating} '
                        '(${widget.product.reviewCount} reviews)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestDealCard(StoreOffer offer) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, AppColors.secondaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'BEST AVAILABLE DEAL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.trending_down_rounded, color: AppColors.white),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatPrice(offer.totalPrice),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Available at ${offer.storeName}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openStore(offer),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('View Best Deal'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryButtonGreen,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Price', 'Rating', 'Store'].map((filter) {
          final selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              selectedColor: AppColors.secondaryTeal,
              backgroundColor: AppColors.white,
              side: BorderSide(
                color: selected ? AppColors.secondaryTeal : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavingsButton() {
    final bestOffer = _bestPriceOffer;

    if (bestOffer == null || _savingAmount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _openStore(bestOffer),
          icon: const Icon(Icons.savings_outlined),
          label: Text(
            'Save ${_formatPrice(_savingAmount)} '
            '(${_savingPercentage.toStringAsFixed(1)}%) '
            'at ${bestOffer.storeName}',
            textAlign: TextAlign.center,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryButtonGreen,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            minimumSize: const Size(double.infinity, 52),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOffers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No available store offers found.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Pull down to refresh the offers.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
