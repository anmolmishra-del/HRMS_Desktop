import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Color? fillColor;
  final String? errorText;

  const CustomTextFormField({
    super.key,
    this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.fillColor,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!,
              style:  TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: errorText != null ? Border.all(color: AppColors.red, width: 1) : null,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: AppColors.iconGrey),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.iconGrey, fontSize: 14),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
