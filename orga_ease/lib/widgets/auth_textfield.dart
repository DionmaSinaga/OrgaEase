import 'package:flutter/material.dart';
import 'package:orga_ease/app_color.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.ink(context);
    final hintColor = AppColors.subInk(context, 0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontSize: 13.5, fontWeight: FontWeight.w600,
          color: ink)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: ink, fontSize: 14.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor, fontSize: 14),
            prefixIcon: Icon(prefixIcon,
              color: AppColors.primary(context), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.field(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 15),
            border: _border(null),
            enabledBorder: _border(AppColors.fieldBorder(context)),
            focusedBorder: _border(AppColors.primary(context), 1.6),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.6),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color? c, [double w = 1.0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: c == null
        ? BorderSide.none
        : BorderSide(color: c, width: w),
    );
  }
}

