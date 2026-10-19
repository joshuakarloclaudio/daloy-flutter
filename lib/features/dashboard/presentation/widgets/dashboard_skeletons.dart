import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/skeleton.dart';

class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SkeletonPulse(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DaloySpace.s5),
        decoration: BoxDecoration(
          color: c.muted.withValues(alpha: 0.3),
          border: Border.all(color: c.border.withValues(alpha: 0.6)),
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 64, height: 16, radius: DaloyRadii.full),
            SizedBox(height: DaloySpace.s4),
            SkeletonBox(widthFactor: 0.6, height: 28, radius: DaloyRadii.lg),
            SizedBox(height: DaloySpace.s3),
            SkeletonBox(widthFactor: 0.4, height: 16, radius: DaloyRadii.lg),
            SizedBox(height: DaloySpace.s6),
            SkeletonBox(width: 112, height: 44, radius: DaloyRadii.xl),
          ],
        ),
      ),
    );
  }
}

class RowSkeletons extends StatelessWidget {
  const RowSkeletons({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: DaloySpace.s3_5),
              child: Row(
                children: [
                  SkeletonBox(width: 40, height: 40, radius: DaloyRadii.xl),
                  SizedBox(width: DaloySpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(widthFactor: 0.55, height: 14, radius: 4),
                        SizedBox(height: DaloySpace.s2),
                        SkeletonBox(widthFactor: 0.35, height: 12, radius: 4),
                      ],
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
