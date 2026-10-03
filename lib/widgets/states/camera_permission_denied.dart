import 'package:flutter/material.dart';

class CameraPermissionDenied extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const CameraPermissionDenied({super.key, this.onTryAgain});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 60),
            const SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please allow camera permission to scan a product.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onTryAgain,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
