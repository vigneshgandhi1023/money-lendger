import 'package:flutter/material.dart';

/// Animated counter that smoothly interpolates between values.
///
/// Used in dashboard KPI cards for a polished counting animation
/// when values change.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          formatter(animatedValue),
          style: style ?? Theme.of(context).textTheme.headlineSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
