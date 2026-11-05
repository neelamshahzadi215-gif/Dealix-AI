import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';
import '../../models/alert/price_alert.dart';
import 'my_alerts_screen.dart';

class SetPriceAlertScreen extends StatefulWidget {
  final String productName;
  final double currentPrice;

  const SetPriceAlertScreen({
    super.key,
    this.productName = 'Sony WH-1000XM5',
    this.currentPrice = 96400,
  });

  @override
  State<SetPriceAlertScreen> createState() => _SetPriceAlertScreenState();
}

class _SetPriceAlertScreenState extends State<SetPriceAlertScreen> {
  double _targetPrice = 85000;
  
  // Yahan alerts save honge
  final List<PriceAlert> _savedAlerts = [];

  @override
  void initState() {
    super.initState();
    _targetPrice = widget.currentPrice * 0.88;
  }

  String _formatPrice(double price) {
    final value = price.round().toString();
    return 'Rs ${value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    )}';
  }

  int get _discountPercentage {
    if (widget.currentPrice <= 0) return 0;
    return (((widget.currentPrice - _targetPrice) / widget.currentPrice) * 100).round();
  }

  void _showMessage(String message) {
    if (!mounted) return;
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

  void _updateTarget(double value) {
    setState(() {
      _targetPrice = value;
    });
  }

  void _saveAlert() {
    if (widget.currentPrice <= 0 ||
        _targetPrice <= 0 ||
        _targetPrice >= widget.currentPrice) {
      _showMessage('Target price must be lower than the current price.');
      return;
    }

    setState(() {
      _savedAlerts.insert(
        0,
        PriceAlert(
          id: DateTime.now().toString(),
          productId: 'p_temp',
          productName: widget.productName,
          currentPrice: widget.currentPrice,
          targetPrice: _targetPrice,
          isEnabled: true,
        ),
      );
    });

    _showMessage('Alert saved successfully!');
  }

  void _openMyAlerts() {
    // Saved alerts ki list MyAlertsScreen mein pass ki ja rahi hai
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAlertsScreen(savedAlerts: _savedAlerts),
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
              onTap: _openMyAlerts, // Yahan se bhi My Alerts khulega
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          title: const Text(
            'Set Price Alert',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: 'My Alerts',
              onPressed: _openMyAlerts,
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.notifications_active,
                  color: AppColors.secondaryTeal,
                  size: 58,
                ),
                const SizedBox(height: 12),
                const Text(
                  "We'll notify you when\nthe price drops",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProductCard(),
                const SizedBox(height: 24),
                const Text(
                  'Target price',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(_targetPrice),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryTeal,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '-$_discountPercentage%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: AppColors.secondaryTeal,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.secondaryTeal,
                    overlayColor: AppColors.softMint,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _targetPrice.clamp(1.0, widget.currentPrice),
                    min: 1,
                    max: widget.currentPrice,
                    onChanged: _updateTarget,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You'll get an alert when the price\nreaches your target.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    text: 'Save Alert',
                    onPressed: _saveAlert,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _openMyAlerts,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryTeal,
                      side: const BorderSide(color: AppColors.secondaryTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'View My Alerts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              Icons.headphones,
              size: 28,
              color: AppColors.secondaryTeal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current price: ${_formatPrice(widget.currentPrice)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}