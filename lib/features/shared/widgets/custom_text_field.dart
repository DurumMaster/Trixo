import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText; //True si es una contraseña
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}