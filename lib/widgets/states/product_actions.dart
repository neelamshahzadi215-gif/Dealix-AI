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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFavoriteTap,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? AppColors.secondaryTeal
                  : AppColors.primaryGreen,
            ),
            label: Text(isFavorite ? 'Saved' : 'Save'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onStoreTap,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('View Store'),
          ),
        ),
      ],
    );
  }
}
