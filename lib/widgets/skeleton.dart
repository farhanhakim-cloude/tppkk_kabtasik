// lib/widgets/skeleton.dart
// Skeleton loading standar dinas — dipakai di semua layar Dasawisma.
// Biru-abu lembut, tanpa spinner.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, required this.width, required this.height, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6ECF2),
      highlightColor: const Color(0xFFF4F6F9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: const Color(0xFFE6ECF2), borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < count - 1 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1E7EE)),
              ),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color(0xFFE6ECF2),
                    highlightColor: const Color(0xFFF4F6F9),
                    child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6ECF2), borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140, height: 13),
                        SizedBox(height: 6),
                        SkeletonBox(width: 200, height: 11, radius: 7),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E7EE))),
              child: const Column(
                children: [
                  SkeletonBox(width: 44, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: 56, height: 10, radius: 6),
                ],
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class SkeletonForm extends StatelessWidget {
  const SkeletonForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: double.infinity, height: 52),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 52),
        SizedBox(height: 10),
        SkeletonBox(width: 220, height: 16),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 52),
      ],
    );
  }
}
