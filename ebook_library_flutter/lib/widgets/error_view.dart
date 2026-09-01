// lib/widgets/error_view.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorView extends StatelessWidget {
  final String    message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.error, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontFamily:  'Georgia',
              fontSize:    18,
              fontWeight:  FontWeight.bold,
              color:       AppTheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize:   13,
              color:      AppTheme.onSurface,
              height:     1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}
