import 'package:flutter/material.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:trixo_frontend/features/auth/presentation/screens/signin_screen.dart';
import 'package:trixo_frontend/features/post/presentation/views/home_view.dart';
import 'package:trixo_frontend/features/shared/widgets/auth_animation_widget.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_elevated_button.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_text_field.dart';
import 'package:sign_button/sign_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});    
  final GlobalKey<AuthAnimationWidgetState> animationKey = GlobalKey();
  void switchAnimations(bool isFocus, String animation) async {
    final current = animationKey.currentState?.currentAnimation;
    if(isFocus){
      if(animation == "email"){
        if(current != "Hands_up"){
          await animationKey.currentState?.switchAnimation("hands_down", 500);
          await animationKey.currentState?.switchAnimation("idle", 250);
        } else {
          await animationKey.currentState?.switchAnimation("idle", 250);
        }
      } else if(animation == "password"){
        if(current == "Hands_up"){
          await animationKey.currentState?.switchAnimation("Hands_up", 500);
        }
      }
    } else {
      if(animation == "fail"){
        if(current != "fail"){
          await animationKey.currentState?.switchAnimation("fail", 500);
        }
      } else if(animation == "success"){
        if(current != "success"){
          await animationKey.currentState?.switchAnimation("success", 500);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode emailFocusNode = FocusNode();
    final FocusNode passwordNode = FocusNode();

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
              AuthAnimationWidget(key: animationKey,),
              const SizedBox(height: 16),
              const Text('¡Hola!\nBienvenido a Trixo 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 32),
              
              CustomTextField(
                hintText: 'Correo electrónico',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                focusNode: emailFocusNode,
                onFocusChange: (value) => switchAnimations(true, "email"),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                hintText: 'Contraseña',
                obscureText: true,
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                focusNode: passwordNode,
                onFocusChange: (value) => switchAnimations(true, "password"),
              ),
              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),
              
              CustomElevatedButton(
                width: 285,
                text: "Iniciar Sesión",
                onPressed: () {
                  signInWithEmail(emailController, passwordController, context);
                }
              ),

              const SizedBox(height: 90),
              
              SignInButton(
                width: 257,
                buttonType: ButtonType.google,
                onPressed: (){
                  signInWithGoogle(context);
                },
              ),
              
              const SizedBox(height: 18),
              
              CustomElevatedButton(
                width: 285,
                text: "Registrarse",
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
            ],
          ),
        ),
      ),
    );
  }



  void signInWithGoogle(BuildContext context) async {
    AuthService authService = AuthService();
    
    bool success = await authService.signInWithGoogle();
    
    if(success){
      switchAnimations(false, "success");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeView(),
        ),
      );
    } else {
      switchAnimations(false, "fail");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al iniciar sesión con Google."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
    }
    return;
  }

  void signInWithEmail(TextEditingController emailController, TextEditingController passwordController, BuildContext context) async{
    if(emailController.text.trim().isNotEmpty){
      String email = emailController.text.trim();
    
      if(passwordController.text.trim().isNotEmpty){
        String password = passwordController.text.trim();
    
        AuthService authService = AuthService();
    
        final result = await authService.signIn(email: email, password: password);

        final bool isEmailVerified = await authService.isEmailVerified();
        if(result){
          if(!isEmailVerified){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Por favor, verifica tu correo electrónico."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ));
          } else {
            switchAnimations(false, "success");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeView(),
              ),
            );
          }
        } else {
          switchAnimations(false, "fail");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al iniciar sesión. Verifica tus credenciales."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ));
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
    return;
  }
}
