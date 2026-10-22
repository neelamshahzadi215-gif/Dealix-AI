import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProductDetails {
  final String brand;
  final String model;
  final String variant;

  const ProductDetails({
    this.brand = '',
    this.model = '',
    this.variant = '',
  });
}

Future<ProductDetails?> showProductDetailsSheet(BuildContext context) {
  return showModalBottomSheet<ProductDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProductDetailsSheet(),
  );
}

class _ProductDetailsSheet extends StatefulWidget {
  const _ProductDetailsSheet();

  @override
  State<_ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<_ProductDetailsSheet> {
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
      ProductDetails(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        variant: _variantController.text.trim(),
      ),
    );
  }

  void _skip() => Navigator.of(context).pop(null);

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
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Analyze with Details'),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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