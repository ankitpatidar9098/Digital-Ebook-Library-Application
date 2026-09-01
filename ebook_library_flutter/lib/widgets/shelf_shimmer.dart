// lib/widgets/shelf_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Loading skeleton that mimics the shelf layout
class ShelfShimmer extends StatelessWidget {
  const ShelfShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:     AppTheme.surfaceVariant,
      highlightColor: const Color(0xFF2A3045),
      child: Column(
        children: List.generate(3, (_) => _ShimmerShelfRow()),
      ),
    );
  }
}

class _ShimmerShelfRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              4,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: 130 + (i % 3) * 20.0,
                    decoration: BoxDecoration(
                      color:        AppTheme.surfaceVariant,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 18,
          color:  AppTheme.shelfWood.withOpacity(0.4),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
