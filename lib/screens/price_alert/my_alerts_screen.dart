import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert/price_alert.dart';
import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';
import 'set_price_alert_screen.dart';

class MyAlertsScreen extends StatefulWidget {
  final List<PriceAlert> savedAlerts;

  const MyAlertsScreen({
    super.key,
    required this.savedAlerts,
  });

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  int _selectedTabIndex = 0;

  final MockDataService _mockDataService = MockDataService();

  List<Product> _watchlistProducts = [];
  bool _isLoadingWatchlist = true;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  Future<void> _fetchWatchlist() async {
    try {
      final products = await _mockDataService.getProducts();

      if (!mounted) return;

      setState(() {
        _watchlistProducts = products;
        _isLoadingWatchlist = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingWatchlist = false;
      });
    }
  }

  String _formatPrice(double price) {
    final value = price.round().toString();

    return 'Rs ${value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    )}';
  }

  int _calculateDrop(double currentPrice, double targetPrice) {
    if (currentPrice <= 0) return 0;

    return (((currentPrice - targetPrice) / currentPrice) * 100).round();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.secondaryTeal,
        ),
      );
  }

  void _openSetAlert(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetPriceAlertScreen(
          productName: product.name,
          currentPrice: product.price.toDouble(),
          productId: product.id,
          savedAlerts: widget.savedAlerts,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  final Set<String> _disabledAlertIds = {};

void _toggleAlert(int index, bool value) {
  final alertId = widget.savedAlerts[index].id;

  setState(() {
    if (value) {
      _disabledAlertIds.remove(alertId);
    } else {
      _disabledAlertIds.add(alertId);
    }
  });
}

  void _deleteAlert(int index) {
    setState(() {
      widget.savedAlerts.removeAt(index);
    });

    _showMessage('Alert removed successfully.');
  }

  Widget _buildTabButton(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondaryTeal
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(PriceAlert alert, int index) {
    final drop = _calculateDrop(
      alert.currentPrice,
      alert.targetPrice,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.secondaryTeal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert.productName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Switch(
                value: alert.isEnabled && !_disabledAlertIds.contains(alert.id),
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.secondaryTeal,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor:
                    AppTheme.lightTheme.colorScheme.outlineVariant,
                onChanged: (value) => _toggleAlert(index, value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceInfo(
                  'Current Price',
                  _formatPrice(alert.currentPrice),
                ),
              ),
              Expanded(
                child: _buildPriceInfo(
                  'Target Price',
                  _formatPrice(alert.targetPrice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$drop% price drop',
                  style: const TextStyle(
                    color: AppColors.secondaryTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _deleteAlert(index),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String title, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.secondaryTeal,
              size: 28,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(product.price.toDouble()),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () => _openSetAlert(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryTeal,
                      side: const BorderSide(
                        color: AppColors.secondaryTeal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Set Alert',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAlerts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: Column(
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 58,
              color: AppColors.secondaryTeal,
            ),
            const SizedBox(height: 14),
            const Text(
              'No Price Alerts Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Set an alert to get notified when\nyour product price drops.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryTeal,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Explore Watchlist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistContent() {
    if (_isLoadingWatchlist) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(35),
          child: CircularProgressIndicator(
            color: AppColors.secondaryTeal,
          ),
        ),
      );
    }

    if (_watchlistProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(35),
          child: Text(
            'No products available in Watchlist.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: _watchlistProducts
          .map((product) => _buildWatchlistCard(product))
          .toList(),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.home);
              },
            ),
            _buildNavItem(
              icon: Icons.notifications_active_rounded,
              label: 'Alerts',
              selected: true,
              onTap: () {},
            ),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRouter.aiScan),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 49,
                        height: 43,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryTeal,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildNavItem(
              icon: Icons.bookmark_border_rounded,
              label: 'Saved',
              selected: _selectedTabIndex == 1,
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () => _showMessage('Profile screen not connected'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 23,
                color: selected
                    ? AppColors.secondaryTeal
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.secondaryTeal
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          title: const Text(
            'My Alerts',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBar: _buildBottomNavigation(),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Row(
                  children: [
                    _buildTabButton('Price Alerts', 0),
                    const SizedBox(width: 10),
                    _buildTabButton('Watchlist', 1),
                  ],
                ),
              ),
              Expanded(
                child: _selectedTabIndex == 0
                    ? widget.savedAlerts.isEmpty
                        ? _buildEmptyAlerts()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: widget.savedAlerts.length,
                            itemBuilder: (context, index) {
                              return _buildAlertCard(
                                widget.savedAlerts[index],
                                index,
                              );
                            },
                          )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        children: [
                          _buildWatchlistContent(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}