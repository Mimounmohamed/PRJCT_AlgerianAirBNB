import 'package:flutter/material.dart';

/// Small step-progress indicator reused across the Create Listing wizard —
/// filled dot for the current/completed step, outline for the rest.
class CreateListingProgressDots extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;

  const CreateListingProgressDots({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2A1B12) : const Color(0xFFE7DCCB),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}