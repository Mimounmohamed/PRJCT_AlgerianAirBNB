import 'package:flutter/material.dart';

/// Reusable segmented step progress bar with a "STEP X OF N" label.
///
/// Usage:
/// ```dart
/// StepProgressIndicator(currentStep: 2, totalSteps: 3)
/// ```
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeSegmentWidth = 40,
    this.inactiveSegmentWidth = 16,
    this.segmentHeight = 6,
    this.segmentSpacing = 5,
  });

  final int currentStep; // 1-indexed
  final int totalSteps;
  final double activeSegmentWidth;
  final double inactiveSegmentWidth;
  final double segmentHeight;
  final double segmentSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isCurrent = index == currentStep - 1;
              final isCompleted = index < currentStep - 1;
              final width = isCurrent ? activeSegmentWidth : inactiveSegmentWidth;
              return Container(
                margin: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : segmentSpacing,
                ),
                width: width,
                height: segmentHeight,
                decoration: BoxDecoration(
                  color: (isCurrent || isCompleted)
                      ? const Color(0xFF0F4C4C)
                      : const Color(0xFFDCD3C4),
                  borderRadius: BorderRadius.circular(segmentHeight / 2),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          Text(
            'STEP $currentStep OF $totalSteps',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }
}