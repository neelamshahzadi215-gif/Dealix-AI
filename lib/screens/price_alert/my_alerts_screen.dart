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

  const MyAlertsScreen({super.key, required this.savedAlerts});

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  int _selectedTabIndex = 0;

  final MockDataService _mockDataService = MockDataService();

  List<Product> _watchlistProducts = [];
  bool _isLoadingWatchlist = true;

  final Set<String> _disabledAlertIds = {};

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

    return 'Rs ${value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  int _calculateDrop(double currentPrice, double targetPrice) {
    if (currentPrice <= 0) return 0;

    return (((currentPrice - targetPrice) / currentPrice) * 100).round();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.secondaryTeal,
        ),
      );
  }

  void _openSetAlert(BuildContext context, Product product) {
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

  void _deleteAlert(BuildContext context, int index) {
    final alertId = widget.savedAlerts[index].id;

    setState(() {
      widget.savedAlerts.removeAt(index);
      _disabledAlertIds.remove(alertId);
    });

    _showMessage(context, 'Alert removed successfully.');
  }

  Widget _buildTabButton(BuildContext context, String title, int index) {
    final isSelected = _selectedTabIndex == index;
    final textTheme = Theme.of(context).textTheme;

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
            color: isSelected ? AppColors.secondaryTeal : AppColors.white,
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            border: Border.all(
              color: isSelected ? AppColors.secondaryTeal : AppColors.border,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, PriceAlert alert, int index) {
    final textTheme = Theme.of(context).textTheme;

    final drop = _calculateDrop(alert.currentPrice, alert.targetPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
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
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.secondaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(alert.productName, style: textTheme.titleSmall),
              ),
              Switch(
                value: alert.isEnabled && !_disabledAlertIds.contains(alert.id),
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.secondaryTeal,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: Theme.of(
                  context,
                ).colorScheme.outlineVariant,
                onChanged: (value) => _toggleAlert(index, value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceInfo(
                  context,
                  'Current Price',
                  _formatPrice(alert.currentPrice),
                ),
              ),
              Expanded(
                child: _buildPriceInfo(
                  context,
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
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                ),
                child: Text(
                  '$drop% price drop',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryTeal,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _deleteAlert(context, index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                label: Text(
                  'Remove',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context, String title, String price) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.bodySmall),
        const SizedBox(height: 5),
        Text(price, style: textTheme.titleSmall),
      ],
    );
  }

  Widget _buildWatchlistCard(BuildContext context, Product product) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
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
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(product.price.toDouble()),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _openSetAlert(context, product),
                  child: const Text('Set Alert'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAlerts(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 55),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 58,
              color: AppColors.secondaryTeal,
            ),
            const SizedBox(height: 14),
            Text('No Price Alerts Yet', style: textTheme.titleLarge),
            const SizedBox(height: 7),
            Text(
              'Set an alert to get notified when\nyour product price drops.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: const Text('Explore Watchlist'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoadingWatchlist) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(35),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_watchlistProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Text(
            'No products available in Watchlist.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: _watchlistProducts
          .map((product) => _buildWatchlistCard(context, product))
          .toList(),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
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
              context,
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.home);
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.notifications_active_rounded,
              label: 'Alerts',
              selected: true,
              onTap: () {},
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.aiScan);
                },
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
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
                          borderRadius: BorderRadius.circular(
                            AppTheme.mediumRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildNavItem(
              context,
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
              context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppColors.secondaryTeal
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: selected
                      ? AppColors.secondaryTeal
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
      child: Builder(
        builder: (themeContext) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'My Alerts',
                style: Theme.of(themeContext).textTheme.titleLarge,
              ),
            ),
            bottomNavigationBar: _buildBottomNavigation(themeContext),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Row(
                      children: [
                        _buildTabButton(themeContext, 'Price Alerts', 0),
                        const SizedBox(width: 10),
                        _buildTabButton(themeContext, 'Watchlist', 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? widget.savedAlerts.isEmpty
                              ? _buildEmptyAlerts(themeContext)
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    20,
                                  ),
                                  itemCount: widget.savedAlerts.length,
                                  itemBuilder: (context, index) {
                                    return _buildAlertCard(
                                      themeContext,
                                      widget.savedAlerts[index],
                                      index,
                                    );
                                  },
                                )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            children: [_buildWatchlistContent(themeContext)],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
