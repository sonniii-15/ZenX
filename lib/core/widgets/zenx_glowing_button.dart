import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/zenx_colors.dart';

class ZenXGlowingButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isRecording;

  const ZenXGlowingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          color: isRecording ? ZenXColors.error : ZenXColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? ZenXColors.error : ZenXColors.primary).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scaleXY(end: 1.05, duration: 1000.ms),
    );
  }
}
