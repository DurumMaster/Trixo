import 'package:flutter/material.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_elevated_button.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white10,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'M', 
                style: TextStyle(
                  fontSize: 64, 
                  color: Colors.pink,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            const SizedBox(height: 16),

            const Text('Introduce los datos para poder\nempezar a compartir tus ideas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 24),

            CustomTextField(
              hintText: 'Introduce su correo electrónico',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            
            CustomElevatedButton(
              text: "Recuperar contraseña",
              onPressed: () {
                resetPassword(emailController, context);
              }
            ),
            
            const SizedBox(height: 16),

            TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                "Volver a iniciar sesión",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetPassword(TextEditingController emailController, BuildContext context) {
    String email = emailController.text.trim();
    if(email.isNotEmpty){
      AuthService authService = AuthService();
      authService.resetPassword(email: email);
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha enviado un correo de recuperación de contraseña'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor introduce su correo electrónico'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}