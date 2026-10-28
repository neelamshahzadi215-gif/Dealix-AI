import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/history/price_history.dart';
import '../../services/mock/mock_data_service.dart';
import '../../widgets/states/loading_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import 'widgets/product_header_section.dart';
import 'widgets/price_trend_chart.dart';
import 'widgets/price_stats_row.dart';
import 'widgets/price_insight_banner.dart';
import 'widgets/alternatives_button.dart';
import 'widgets/bottom_menu_items.dart';

class PriceHistoryScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const PriceHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  final MockDataService _mockDataService = MockDataService();

  PriceHistory? _priceHistory;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedTimeRange = '6M';

  @override
  void initState() {
    super.initState();
    _loadPriceHistory();
  }

  Future<void> _loadPriceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final history = await _mockDataService.getPriceHistory(widget.productId);
      setState(() {
        _priceHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load price history. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showWorkingMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action feature is being connected to backend...'),
        backgroundColor: AppColors.secondaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Price History',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => _showWorkingMessage('Notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showWorkingMessage('More Options'),
          ),
        ],
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: LoadingSkeleton());
    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _loadPriceHistory);
    }
    if (_priceHistory == null || _priceHistory!.points.isEmpty) {
      return const EmptyState(
        title: 'No price history available',
        message: 'Price history will appear here once the product is tracked.',
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadPriceHistory,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductHeaderSection(
              productName: widget.productName,
              brand: 'Sony',
              rating: 4.6,
              reviewCount: 8200,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price Trend',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () => _showWorkingMessage('Time Range Picker'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Last $_selectedTimeRange',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PriceTrendChart(priceHistory: _priceHistory!, timeRange: _selectedTimeRange),
            const SizedBox(height: 20),
            PriceStatsRow(priceHistory: _priceHistory!),
            const SizedBox(height: 16),
            PriceInsightBanner(priceHistory: _priceHistory!),
            const SizedBox(height: 20),

            // ✅ YEH LINE FIX KAR DI GAYI HAI:
            AlternativesButton(
              onTap: () => _showWorkingMessage('Finding Cheaper Alternatives'),
            ),

            const SizedBox(height: 12),

            // ✅ YEH LINE BHI UPDATE HAI:
            BottomMenuItems(
              productId: widget.productId,
              onSetAlert: () => _showWorkingMessage('Setting Price Alert'),
              onShare: () => _showWorkingMessage('Sharing Product'),
            ),
          ],
        ),
      ),
    );
  }
}