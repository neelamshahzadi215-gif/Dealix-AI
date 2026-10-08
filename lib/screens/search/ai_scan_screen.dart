import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product/product.dart';
import '../../services/mock/mock_data_service.dart';
import '../../widgets/states/camera_permission_denied.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../../widgets/states/loading_skeleton.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> {
  final TextEditingController _productNameController =
      TextEditingController();

  final MockDataService _mockDataService = MockDataService();

  List<Product> _results = [];

  bool _isLoading = false;
  bool _hasError = false;
  bool _cameraPermissionDenied = false;
  bool _hasResults = false;

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // CAMERA
  // ------------------------------------------------------------

  void _openCamera() {
    setState(() {
      _cameraPermissionDenied = true;
    });
  }

  void _tryCameraAgain() {
    setState(() {
      _cameraPermissionDenied = false;
    });
  }

  // ------------------------------------------------------------
  // GALLERY
  // ------------------------------------------------------------

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery selection will be connected here.'),
      ),
    );
  }

  // ------------------------------------------------------------
  // MOCK PRODUCT RESULTS
  // ------------------------------------------------------------

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _hasResults = false;
    });

    try {
      final products = await _mockDataService.getProducts();

      if (!mounted) return;

      setState(() {
        _results = products;
        _isLoading = false;
        _hasResults = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ------------------------------------------------------------
  // CLEAR RESULTS
  // ------------------------------------------------------------

  void _clearResults() {
    setState(() {
      _results = [];
      _hasResults = false;
      _hasError = false;
    });
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'AI Product Scan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: _cameraPermissionDenied
            ? CameraPermissionDenied(
                onTryAgain: _tryCameraAgain,
              )
            : _buildContent(),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN CONTENT
  // ------------------------------------------------------------

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadBox(),

          const SizedBox(height: 10),

          _buildCameraGalleryButtons(),

          const SizedBox(height: 12),

          _buildProductNameField(),

          const SizedBox(height: 6),

          _buildHelperText(),

          const SizedBox(height: 10),

          _buildTipCard(),

          const SizedBox(height: 18),

          _buildResults(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UPLOAD BOX
  // ------------------------------------------------------------

  Widget _buildUploadBox() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.border,
        radius: 12,
        dashWidth: 6,
        dashSpace: 4,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.softMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryGreen,
                size: 26,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Upload a product photo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'Pick or drag, up to 5 MB',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CAMERA + GALLERY
  // ------------------------------------------------------------

  Widget _buildCameraGalleryButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 17,
              ),
              label: const Text(
                'Camera',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _openGallery,
              icon: const Icon(
                Icons.photo_library_outlined,
                size: 17,
              ),
              label: const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.white,
                side: const BorderSide(
                  color: AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PRODUCT NAME
  // ------------------------------------------------------------

  Widget _buildProductNameField() {
    return TextField(
      controller: _productNameController,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Product name (optional)',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HELPER TEXT
  // ------------------------------------------------------------

  Widget _buildHelperText() {
    return const Padding(
      padding: EdgeInsets.only(left: 2),
      child: Text(
        'Adding a name improves the AI result.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TIP CARD
  // ------------------------------------------------------------

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb,
            color: AppColors.accent,
            size: 25,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Keep the product in good light and fully in frame. Make sure the brand name is visible.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RESULTS
  // ------------------------------------------------------------

  Widget _buildResults() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return ErrorState(
        title: 'Unable to load products',
        message: 'Something went wrong while loading mock results.',
        onRetry: _loadResults,
      );
    }

    if (!_hasResults) {
      return EmptyState(
        title: 'Ready to scan',
        message:
            'Upload a product photo or enter a product name to prepare results.',
        icon: Icons.document_scanner_outlined,
        actionText: 'Load Mock Results',
        onAction: _loadResults,
      );
    }

    if (_results.isEmpty) {
      return EmptyState(
        title: 'No products found',
        message: 'No matching products are available.',
        icon: Icons.search_off_outlined,
        actionText: 'Clear',
        onAction: _clearResults,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        ..._results.map(
          (product) => _buildResultCard(product),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  Widget _buildLoadingState() {
    return const Column(
      children: [
        LoadingSkeleton(
          height: 90,
          borderRadius: 12,
        ),
        SizedBox(height: 10),
        LoadingSkeleton(
          height: 90,
          borderRadius: 12,
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // RESULT CARD
  // ------------------------------------------------------------

  Widget _buildResultCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryGreen,
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
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  product.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

// ============================================================
// DASHED BORDER PAINTER
// ============================================================

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(
          0,
          metric.length,
        );

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}