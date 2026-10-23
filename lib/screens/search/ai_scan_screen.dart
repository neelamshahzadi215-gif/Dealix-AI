import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product/product.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> {
  final TextEditingController _productNameController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  List<Product> _results = [];

  String _searchedName = '';
  _ScanDetails? _searchedDetails;
  final bool _isLoading = false;
  bool _hasError = false;
  bool _hasAnalyzed = false;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
  }

  Future<void> _recoverLostImage() async {
    try {
      final LostDataResponse response = await _imagePicker.retrieveLostData();

      if (response.isEmpty) return;

      final List<XFile>? files = response.files;

      if (files != null && files.isNotEmpty) {
        if (!mounted) return;
        await _setSelectedImage(File(files.first.path));
      } else if (response.exception != null) {
        if (!mounted) return;
        _showMessage('Camera image recover nahi hui. Dobara try karein.');
      }
    } catch (e) {
      debugPrint('Lost image recovery error: $e');
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  // CAMERA
  Future<void> _openCamera() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await prefs.setBool('restore_ai_scan_after_camera', true);

      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (pickedImage != null && mounted) {
        await _setSelectedImage(File(pickedImage.path));
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Camera open nahi hua: $e');
      }
    } finally {
      await prefs.remove('restore_ai_scan_after_camera');
    }
  }

  // GALLERY
  Future<void> _openGallery() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (!mounted || pickedImage == null) return;

      await _setSelectedImage(File(pickedImage.path));
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gallery open nahi hui: $e');
    }
  }

  // Validate selected image.
  Future<void> _setSelectedImage(File image) async {
    try {
      final int fileSize = await image.length();

      if (!mounted) return;

      if (fileSize == 0) {
        _showMessage('Selected image empty hai. Dobara try karein.');
        return;
      }

      if (fileSize > 5 * 1024 * 1024) {
        _showMessage('5 MB se choti image select karein.');
        return;
      }

      setState(() {
        _selectedImage = image;
        _results = [];
        _hasAnalyzed = false;
        _hasError = false;
        _searchedName = '';
        _searchedDetails = null;
      });

      _showMessage('Product photo selected');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Image open nahi ho saki. Dobara try karein.');
    }
  }

  // Remove selected image.
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });

    _showMessage('Product photo removed');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // Details popup.
  Future<_ScanDetails?> _showDetailsSheet() {
    return showModalBottomSheet<_ScanDetails>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DetailsSheet(),
    );
  }

  // Open analysis route.
  Future<void> _analyzeWithAI() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final _ScanDetails? details = await _showDetailsSheet();

    if (!mounted) return;

    // Skip ya Back se popup band ho to analysis open na ho.
    if (details == null) return;

    final String rawName = _productNameController.text.trim();

    final List<String> detailTerms = [
      if (details.brand.trim().isNotEmpty) details.brand.trim(),
      if (details.model.trim().isNotEmpty) details.model.trim(),
      if (details.variant.trim().isNotEmpty) details.variant.trim(),
    ];

    if (rawName.isEmpty && _selectedImage == null && detailTerms.isEmpty) {
      _showMessage('Product name, photo ya details mein se kuch add karein.');
      return;
    }

    setState(() {
      _searchedName = rawName;
      _searchedDetails = details;
    });

    Navigator.of(context).pushNamed(AppRouter.analysis);
  }

  void _clearResults() {
    setState(() {
      _results = [];
      _hasAnalyzed = false;
      _hasError = false;
      _searchedName = '';
      _searchedDetails = null;
      _selectedImage = null;
      _productNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: const Text(
            'AI Product Scan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUploadCard(),
                      const SizedBox(height: 14),
                      _buildCameraGalleryButtons(),
                      const SizedBox(height: 14),
                      _buildProductNameField(),
                      const SizedBox(height: 14),
                      _buildTipCard(),
                      if (_isLoading) ...[
                        const SizedBox(height: 24),
                        _buildLoading(),
                      ],
                      if (_hasError) ...[
                        const SizedBox(height: 24),
                        _buildError(),
                      ],
                      if (_hasAnalyzed && !_isLoading && !_hasError) ...[
                        const SizedBox(height: 24),
                        _buildSearchSummary(),
                        _buildResults(),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeWithAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryTeal,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Searching...' : 'Analyze with AI',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Upload area and selected-photo preview.
  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondaryTeal.withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      child: _selectedImage == null
          ? const Column(
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 42,
                  color: AppColors.secondaryTeal,
                ),
                SizedBox(height: 12),
                Text(
                  'Upload a product photo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Choose Camera or Gallery below (up to 5 MB)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    key: ValueKey(_selectedImage!.path),
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: AppColors.error,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Product photo selected',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove image',
                      onPressed: _removeImage,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // Camera and Gallery buttons.
  Widget _buildCameraGalleryButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryTeal,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondaryTeal,
              backgroundColor: AppColors.white,
              side: const BorderSide(
                color: AppColors.secondaryTeal,
                width: 1.4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Product name field.
  Widget _buildProductNameField() {
    return TextField(
      controller: _productNameController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _analyzeWithAI(),
      decoration: InputDecoration(
        hintText: 'Product name (optional)',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        suffixIcon: IconButton(
          tooltip: 'Search',
          onPressed: _isLoading ? null : _analyzeWithAI,
          icon: const Icon(Icons.search, color: AppColors.secondaryTeal),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '💡 Keep the product in good light and fully in frame.',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 14),
            Text(
              'Finding matching products...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 38, color: AppColors.error),
          const SizedBox(height: 10),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _analyzeWithAI, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildSearchSummary() {
    final details = _searchedDetails;

    final items = <MapEntry<String, String>>[
      if (_searchedName.isNotEmpty) MapEntry('Product', _searchedName),
      if (details?.brand.trim().isNotEmpty == true)
        MapEntry('Brand', details!.brand.trim()),
      if (details?.model.trim().isNotEmpty == true)
        MapEntry('Model', details!.model.trim()),
      if (details?.variant.trim().isNotEmpty == true)
        MapEntry('Variant', details!.variant.trim()),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your search',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${item.key}: ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: item.value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_outlined,
              color: AppColors.secondaryTeal,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'No matching products found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another product name or different details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearResults,
              child: const Text('Clear search'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Matching products',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${_results.length} found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._results.map(_buildProductCard),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clearResults,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('New search'),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: double.infinity,
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${product.brand} • ${product.category}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  product.price.toString(),
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// Product details model.
class _ScanDetails {
  final String brand;
  final String model;
  final String variant;

  const _ScanDetails({this.brand = '', this.model = '', this.variant = ''});
}

// Details popup.
class _DetailsSheet extends StatefulWidget {
  const _DetailsSheet();

  @override
  State<_DetailsSheet> createState() => _DetailsSheetState();
}

class _DetailsSheetState extends State<_DetailsSheet> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();

  final _modelFocus = FocusNode();
  final _variantFocus = FocusNode();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _variantController.dispose();
    _modelFocus.dispose();
    _variantFocus.dispose();
    super.dispose();
  }

  void _addVariantHint(String label) {
    final text = _variantController.text;
    final prefix = text.isEmpty || text.endsWith(' ') ? text : '$text ';

    final newText = '$prefix$label: ';

    _variantController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    _variantFocus.requestFocus();
  }

  void _submit() {
    Navigator.of(context).pop(
      _ScanDetails(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        variant: _variantController.text.trim(),
      ),
    );
  }

  void _skip() {
    Navigator.of(context).pop(const _ScanDetails());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.softMint,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'Want more accurate results?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Add product details so we can find the exact model '
                    'and best prices. You can skip this.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _label('Brand'),
                _field(
                  controller: _brandController,
                  hint: 'e.g. Sony',
                  onSubmitted: (_) => _modelFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                _label('Model / Variant'),
                _field(
                  controller: _modelController,
                  focusNode: _modelFocus,
                  hint: 'e.g. WH-1000XM5',
                  onSubmitted: (_) => _variantFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                _label('Color / Storage / Size'),
                _field(
                  controller: _variantController,
                  focusNode: _variantFocus,
                  hint: 'e.g. Black, 256GB',
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('+ Model no.', () => _modelFocus.requestFocus()),
                    _chip('+ Color', () => _addVariantHint('Color')),
                    _chip('+ Storage', () => _addVariantHint('Storage')),
                    _chip('+ Condition', () => _addVariantHint('Condition')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryTeal,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Analyze with Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip & Analyze',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(
              text: ' (optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.softMint,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
