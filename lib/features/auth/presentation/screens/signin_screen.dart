import 'package:flutter/material.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/auth_service.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_elevated_button.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_text_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

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

            const Text('Introduce los datos para poder\nempezar a compartir tus ideas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 40),

            CustomTextField(
              hintText: 'Introduce su correo electrónico',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 20),

            CustomTextField(
              hintText: 'Nombre de usuario',
              controller: usernameController,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Contraseña',
              obscureText: true,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
            ),

            const SizedBox(height: 20),
            CustomTextField(
              hintText: 'Repite la contraseña',
              obscureText: true,
              controller: confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 115),

            CustomElevatedButton(
              text: "Resgistrarse",
              onPressed: () {
                singIn(
                  emailController,
                  usernameController,
                  passwordController,
                  confirmPasswordController,
                  context
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  void singIn(TextEditingController emailController, TextEditingController usernameController, TextEditingController passwordController, TextEditingController confirmPasswordController, BuildContext context) {
    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    
    if(email.isNotEmpty){
      if(username.isNotEmpty){
        if(password.isNotEmpty){
          if(confirmPassword.isNotEmpty){
            if(password == confirmPassword){
              AuthService authService = AuthService();
    
              authService.signUp(email: email, password: password);
              
              notifyUser(context, "Usuario registrado con éxito");
            } else {
    
              notifyUser(context, "Las contraseñas no coinciden");
            }
          } else {
    
            notifyUser(context, "Introduce la contraseña de nuevo");
          }
        } else {
    
          notifyUser(context, "Introduce una contraseña");
        }
      } else {
    
        notifyUser(context, "Introduce un nombre de usuario");
      }
    } else {
      
      notifyUser(context, "Introduce un correo electrónico");
    }
  }

  void notifyUser(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
