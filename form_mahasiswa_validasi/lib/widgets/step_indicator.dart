import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalStep, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: currentStep == index ? 28 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: currentStep >= index
                ? Colors.white
                : Colors.white38,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
