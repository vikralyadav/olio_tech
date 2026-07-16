import 'package:flutter/material.dart';

/// A rounded, animated progress bar with an accent colour.
class AppProgressBar extends StatelessWidget {
  final double value; // 0..1 (may exceed for over-budget visuals, clamped)
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(
            height: height,
            color: color.withValues(alpha: 0.15),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v,
              child: Container(height: height, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
