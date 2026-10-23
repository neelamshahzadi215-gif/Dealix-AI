import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '${product.brand} • ${product.model}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${product.currency} '
            '${product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.star_rounded, size: 20, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '(${product.reviewCount} reviews)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(color: AppColors.border),
          const SizedBox(height: 8),

          const Text(
            'Product Information',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoRow('Brand', product.brand),
          _buildInfoRow('Model', product.model),
          _buildInfoRow('Category', product.category),

          if (product.barcode.isNotEmpty)
            _buildInfoRow('Barcode', product.barcode),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: product.isAvailable
                  ? AppColors.softMint
                  : AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  product.isAvailable
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 19,
                  color: product.isAvailable
                      ? AppColors.primaryGreen
                      : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  product.isAvailable
                      ? 'Product Available'
                      : 'Product Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: product.isAvailable
                        ? AppColors.primaryGreen
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
