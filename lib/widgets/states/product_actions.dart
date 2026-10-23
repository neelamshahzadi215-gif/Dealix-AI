import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProductActions extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onStoreTap;

  const ProductActions({
    super.key,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onStoreTap,
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Visit Best-Priced Store'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButtonGreen,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onFavoriteTap,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.error : AppColors.primaryGreen,
          ),
          label: Text(isFavorite ? 'Saved to Favorites' : 'Add to Favorites'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: AppColors.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
