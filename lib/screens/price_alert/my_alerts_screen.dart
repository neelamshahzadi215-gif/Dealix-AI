import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/alert/price_alert.dart';
import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';

class MyAlertsScreen extends StatefulWidget {
  // Jo alerts pichli screen se aayenge
  final List<PriceAlert> savedAlerts;

  const MyAlertsScreen({
    super.key, 
    required this.savedAlerts, // Required kar diya
  });

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends State<MyAlertsScreen> {
  int _selectedTabIndex = 0; // 0 = Price Alerts, 1 = Watchlist
  bool _isLoading = true;
  
  List<Product> _watchlist = [];
  final MockDataService _dataService = MockDataService();

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  // Sirf watchlist ka mock data fetch kar rahe hain
  Future<void> _fetchWatchlist() async {
    try {
      final products = await _dataService.getProducts();
      if (mounted) {
        setState(() {
          _watchlist = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showNotConnectedMessage(String section) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$section screen is not connected yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.secondaryTeal,
        ),
      );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(PriceAlert alert, int index) {
    final dropPercentage = _calculateDrop(alert.currentPrice, alert.targetPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.headphones_outlined,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(alert.targetPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Notify me at $dropPercentage% drop',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: alert.isEnabled,
            onChanged: (value) {
              setState(() {
                widget.savedAlerts[index] = PriceAlert(
                  id: alert.id,
                  productId: alert.productId,
                  productName: alert.productName,
                  currentPrice: alert.currentPrice,
                  targetPrice: alert.targetPrice,
                  isEnabled: value,
                );
              });
            },
            activeColor: AppColors.white,
            activeTrackColor: AppColors.secondaryTeal,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: AppColors.secondaryTeal),
            onPressed: () => _showNotConnectedMessage('Set Price Alert from Watchlist'),
            tooltip: 'Set Alert',
          ),
        ],
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
                color: selected ? AppColors.secondaryTeal : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.secondaryTeal : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryTeal.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
              onTap: () => _showNotConnectedMessage('Saved'),
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () => _showNotConnectedMessage('Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Price Alerts', 0),
                    _buildTabButton('Watchlist', 1),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondaryTeal,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      // Index 0 pe humari aayi hui savedAlerts list, Index 1 pe Watchlist (mockdata)
                      itemCount: _selectedTabIndex == 0 ? widget.savedAlerts.length : _watchlist.length,
                      itemBuilder: (context, index) {
                        if (_selectedTabIndex == 0) {
                          return _buildAlertCard(widget.savedAlerts[index], index);
                        } else {
                          return _buildWatchlistCard(_watchlist[index]);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}