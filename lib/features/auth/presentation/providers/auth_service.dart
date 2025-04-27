import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
// TODO: IMPLEMENTAR CAMBIO DE ESTADOS DE AUTENTICACIÓN DEL AUT_STATUS_PROVIDER
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> signUp({
    //Registro
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await credentials.user!.sendEmailVerification();
      log("Usuario registrado: ${credentials.user?.uid}", name: "AuthService");
      return true;
    } catch (e) {
      log("Error al registrar: $e");
      return false;
    }
  }

  Future<bool> signIn({
    //Login
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credentials.user == null) {
        log("Usuario no encontrado: $email", name: "AuthService");
        return false;
      }

      if (credentials.user?.emailVerified == false) {
        await credentials.user?.sendEmailVerification();
        log("Se ha enviado un correo de verificacion a ${credentials.user?.email}",
            name: "AuthService");
      }

      log("Se ha iniciado sesion con exito: ${credentials.user?.uid}",
          name: "AuthService");
      return true;
    } catch (e) {
      log("Error al iniciar sesion: $e", name: "AuthService");
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    //Login con google
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth = await user?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      log("Usuario registrado", name: "AuthService");
      return userCredential.user != null;
    } catch (e) {
      log("Error al iniciar sesion con Google: $e", name: "AuthService");
      return false;
    }
  }

  Future<bool> isEmailVerified() async {
    //Comprobar si se ha verificado
    final user = _firebaseAuth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<bool> resetPassword({
    //Recuperar la contraseña
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      log("Se ha enviado un correo de recuperacion de contraseña a $email",
          name: "AuthService");
      return true;
    } catch (e) {
      log("Error al enviar el correo de recuperacionde contraseña: $e",
          name: "AuthService");
      return false;
    }
  }

  Future<void> signOut() async {
    //Logout
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    log("Usuario desconectado", name: "AuthService");
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }
}
