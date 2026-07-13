import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading skeleton for content placeholders.
///
/// Provides smooth, premium-feeling loading states instead of
/// plain spinners.
class LoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      highlightColor:
          isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Creates a card-shaped skeleton.
  static Widget card({double height = 120}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          highlightColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
          child: Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  /// Creates a list of skeleton items.
  static Widget list({int count = 3, double itemHeight = 72}) {
    return Column(
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Shimmer.fromColors(
                baseColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                highlightColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF8FAFC),
                child: Row(
                  children: [
                    // Avatar skeleton
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text skeletons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Dashboard KPI cards skeleton.
  static Widget dashboardCards() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          highlightColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
