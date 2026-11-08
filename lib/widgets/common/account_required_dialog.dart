import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

Future<void> showAccountRequiredDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.error,
            size: 32,
          ),
        ),
        title: const Text('Free searches used'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You have used both demo searches. Create an account or log in to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRouter.signup);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryTeal,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRouter.login);
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
