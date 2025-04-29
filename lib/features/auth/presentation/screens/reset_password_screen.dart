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
            const SizedBox(height: 22),
            Row(
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const Center(
              child: Text(
                'T', 
                style: TextStyle(
                  fontSize: 64, 
                  color: Colors.pink,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            const SizedBox(height: 16),

            const Text('Te llegará un correo para restablecer tu contraseña\n¡Estate atento!',
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