import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: Colors.white),
        ),
      ),
      child: Text(text),
    );
  }
}

// ElevatedButton(
//                 onPressed: () {
//                   //TODO: Implementar login con email y contraseña
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white10, 
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     side: const BorderSide(color: Colors.white),
//                   ),
//                 ),
//                 child: const Text('Ingresar'),
//               ),