import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool enable;
  final String? errorText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final bool? isPhone;
  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.obscureText = false,
      this.validator,
      this.enable = true,
      this.errorText,
      this.focusNode,
      this.keyboardType,
      this.onFieldSubmitted,
      this.maxLines = 1,
      this.isPhone = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      enabled: enable,
      maxLength: isPhone! ? 10 : null,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
