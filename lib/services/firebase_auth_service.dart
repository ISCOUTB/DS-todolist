import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String exito = 'Éxito';

void errorSnackbar(String message) {
  Get.snackbar(
    "Error",
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
}

class FirebaseAuthService {
  void signInWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorSnackbar('Email y contraseña no pueden estar vacíos.');
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar(
        exito,
        "Inicio de sesión exitoso",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        errorSnackbar('Wrong password provided for that user.');
      } else {
        errorSnackbar('Error register in: ${e.code}');
      }
    } catch (e) {
      errorSnackbar('Error inesperado: $e');
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void registerWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorSnackbar('Email y contraseña no pueden estar vacíos.');
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Get.snackbar(
        exito,
        "Registro exitoso. Verifica tu email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        errorSnackbar('The account already exists for that email.');
      } else {
        errorSnackbar('Error register in: ${e.code}');
      }
      // Cierra sesión del usuario en caso de error para evitar conflictos
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      errorSnackbar('Error inesperado: $e');
      await FirebaseAuth.instance.signOut();
    }
  }

  void resetPassword(String email) async {
    if (email.isEmpty) {
      errorSnackbar('El email no puede estar vacío.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        exito,
        "Correo de restablecimiento enviado.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorSnackbar('No user found for that email.');
      } else {
        errorSnackbar('Error sending password reset email: ${e.code}');
      }
    } catch (e) {
      errorSnackbar('Error inesperado: $e');
    }
  }

  void validateEmail(String email) async {
    if (email.isEmpty) {
      errorSnackbar('El email no puede estar vacío.');
      return;
    }
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Get.snackbar(
        "Email enviado",
        "Revisa tu bandeja de entrada",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        errorSnackbar('The email address is not valid.');
      } else if (e.code == 'user-not-found') {
        errorSnackbar('No user found for that email.');
      } else {
        errorSnackbar('Error validating email: ${e.code}');
      }
    } catch (e) {
      errorSnackbar('Error validating email: $e');
    }
  }
}
