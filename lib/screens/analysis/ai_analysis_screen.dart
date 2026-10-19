import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final MockDataService _mockDataService = MockDataService();

  Product? _product;
  Timer? _analysisTimer;

  int _currentStep = 0;
  bool _isLoading = true;
  bool _isConfirmed = false;
  bool _hasError = false;

  final List<String> _steps = const [
    'Image uploaded',
    'Brand and model identified',
    'Fetching prices from stores',
    'Filtering and matching results',
  ];

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    _analysisTimer?.cancel();

    setState(() {
      _product = null;
      _currentStep = 0;
      _isLoading = true;
      _isConfirmed = false;
      _hasError = false;
    });

    try {
      final products = await _mockDataService.getProducts();

      if (!mounted) return;

      if (products.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Use existing product from MockDataService.
      final product = products.firstWhere(
        (item) => item.id == 'p2',
        orElse: () => products.first,
      );

      setState(() {
        _product = product;
      });

      _analysisTimer = Timer.periodic(const Duration(milliseconds: 1000), (
        timer,
      ) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_currentStep < _steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        } else {
          timer.cancel();

          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _confirmProduct() {
    setState(() {
      _isConfirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product confirmed successfully.')),
    );
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _hasError
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildAnalysisHeader(),
                          const SizedBox(height: 24),
                          _buildAnalysisStatus(),
                          const SizedBox(height: 24),
                          _buildProgressSteps(),
                          const SizedBox(height: 24),
                          if (_product != null)
                            _buildProductCard(_product!)
                          else
                            _buildProductLoadingCard(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              'AI Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAnalysisHeader() {
    return Column(
      children: [
        // AI Analysis Icon
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            color: AppColors.softMint,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 42,
                color: AppColors.secondaryTeal,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          _isConfirmed
              ? 'Product Confirmed'
              : _isLoading
              ? 'Analyzing Your Product'
              : 'Analysis Complete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 8),

        Text(
          _isConfirmed
              ? 'Your product identification has been confirmed.'
              : _isLoading
              ? 'AI is identifying your product and checking available information.'
              : 'AI has finished identifying your product.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAnalysisStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: _isLoading
                ? const CircularProgressIndicator(strokeWidth: 3)
                : const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isLoading ? _steps[_currentStep] : 'Product analysis completed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final bool completed = index < _currentStep;
          final bool active = index == _currentStep && _isLoading;

          return _buildProgressStep(
            index: index,
            title: _steps[index],
            completed: completed,
            active: active,
            isLast: index == _steps.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildProgressStep({
    required int index,
    required String title,
    required bool completed,
    required bool active,
    required bool isLast,
  }) {
    final Color circleColor = completed
        ? AppColors.primaryGreen
        : active
        ? AppColors.softMint
        : AppColors.border;

    final Color iconColor = completed
        ? AppColors.white
        : active
        ? AppColors.primaryGreen
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 18,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: completed ? AppColors.primaryGreen : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: completed || active
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: completed || active
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identified Product',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildProductIcon(product.category),
                const SizedBox(width: 14),
                Expanded(child: _buildProductInfo(product)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(AppTheme.smallRadius),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Brand: ${product.brand}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Model: ${product.model}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProductIcon(String category) {
    IconData icon = Icons.devices_other_rounded;

    if (category.toLowerCase().contains('audio')) {
      icon = Icons.headphones_rounded;
    } else if (category.toLowerCase().contains('phone')) {
      icon = Icons.phone_android_rounded;
    } else if (category.toLowerCase().contains('laptop')) {
      icon = Icons.laptop_rounded;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
      ),
      child: Icon(icon, color: AppColors.secondaryTeal, size: 32),
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading || _product == null) {
      return const SizedBox.shrink();
    }

    if (_isConfirmed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.softMint,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Product identification confirmed.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _confirmProduct,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirm Product'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _startAnalysis,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Analysis'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We could not identify the product. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startAnalysis,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
