import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String        label;
  final String?       hint;
  final bool          obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData?     prefixIcon;
  final Widget?       suffix;
  final String?       Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText    = false,
    this.keyboardType   = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller    : controller,
      obscureText   : obscureText,
      keyboardType  : keyboardType,
      validator     : validator,
      decoration    : InputDecoration(
        labelText   : label,
        hintText    : hint,
        prefixIcon  : prefixIcon != null ? Icon(prefixIcon) : null,
        suffix      : suffix,
        filled      : true,
        fillColor   : Colors.grey.shade100,
        border      : OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : const BorderSide(color: Color(0xFFE94560), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}