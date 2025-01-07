import 'package:flutter/material.dart';

class StoryIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final double progress;
  final Color? indicatorColor;
  final Color? indicatorValueColor;
  final double indicatorHeight;
  final EdgeInsets? padding;

  const StoryIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.progress,
    this.indicatorColor,
    this.indicatorValueColor,
    this.indicatorHeight = 3,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(
          itemCount,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LinearProgressIndicator(
                value: index == currentIndex
                    ? progress
                    : index < currentIndex
                        ? 1.0
                        : 0.0,
                backgroundColor: indicatorColor ?? Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(
                  indicatorValueColor ?? Colors.white,
                ),
                minHeight: indicatorHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
