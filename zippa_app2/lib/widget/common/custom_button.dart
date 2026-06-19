import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onPressed;
  final bool     isLoading;
  final Color?   color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width : double.infinity,
      height: 52,
      child : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style    : ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFE94560),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width : 22,
          height: 22,
          child : CircularProgressIndicator(
            color      : Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize  : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}