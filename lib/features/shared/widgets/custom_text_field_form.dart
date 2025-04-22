import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key, 
    this.label, 
    this.hint, 
    this.errorMessage, 
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged, 
    this.onFieldSubmitted,
    this.validator, 
    this.controller
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final border = OutlineInputBorder(
      borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(15),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withValues(alpha: 0.7),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        onChanged: onChanged,
        cursorColor: colors.secondary,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          fillColor: colors.surface,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary),
          ),
          errorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error),
          ),
          isDense: true,
          labelText: label,
          hintText: hint,
          errorText: errorMessage,
          hintStyle: textTheme.bodyLarge,
          labelStyle: textTheme.bodyLarge,
        ),
      ),
    );
  }
}