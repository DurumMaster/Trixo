import 'package:flutter/material.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:trixo_frontend/features/post/presentation/views/home_view.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_elevated_button.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
  
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('M', style: TextStyle(fontSize: 64, color: Colors.pink, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('¡Hola!\nBienvenido a Trixo 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 32),
              
              CustomTextField(
                hintText: 'Correo electrónico',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                hintText: 'Contraseña',
                obscureText: true,
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
              ),
              
              const SizedBox(height: 24),
              
              CustomElevatedButton(
                text: "Iniciar Sesión",
                onPressed: (){
                  signInWithEmail(emailController, passwordController, context);
                }
              ),

              const SizedBox(height: 16),
              
              IconButton(
                onPressed: (){
                  signInWithGoogle(context);
                }, 
                icon: Image.asset(
                  "assets/images/google_icon.png",
                   width: 100, height: 100,
                ),
                color: Colors.white,
              ),
              
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              
              CustomElevatedButton(
                text: "Crear Cuenta",
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                }
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signInWithGoogle(BuildContext context) {
    AuthService authService = AuthService();
    
    authService.signInWithGoogle();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
  }

  void signInWithEmail(TextEditingController emailController, TextEditingController passwordController, BuildContext context) async{
    if(emailController.text.trim().isNotEmpty){
      String email = emailController.text.trim();
    
      if(passwordController.text.trim().isNotEmpty){
        String password = passwordController.text.trim();
    
        AuthService authService = AuthService();
    
        await authService.signIn(email: email, password: password);

        final bool isEmailVerified = await authService.isEmailVerified();

        if(!isEmailVerified){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Por favor, verifica tu correo electrónico."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeView(),
            ),
          );
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu correo electrónico."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
      }
    }
  }
}
