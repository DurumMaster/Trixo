import 'package:flutter/material.dart';
import 'package:trixo_frontend/config/theme/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.onTap,
    this.controller,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    final backgroundColor = isLightMode ? AppColors.white : AppColors.black;
    final borderColor = isLightMode ? AppColors.black : AppColors.white;
    final inputTextColor = isLightMode ? AppColors.black : AppColors.white;
    final hintTextColor = isLightMode
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 1.8),
      borderRadius: BorderRadius.circular(12),
    );

    return TextFormField(
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      validator: widget.validator,
      cursorColor: inputTextColor,
      style: TextStyle(
        color: inputTextColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor,
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorMessage,
        labelStyle: TextStyle(
          color: inputTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        hintStyle: TextStyle(
          color: hintTextColor,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
        ),
        errorMaxLines: 2,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: borderColor, width: 2.5),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 2.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
        suffixIcon:
            widget.showPasswordToggle // Solo mostramos el ojo si es verdadero
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: inputTextColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  )
                : null,
      ),
    );
  }
}
