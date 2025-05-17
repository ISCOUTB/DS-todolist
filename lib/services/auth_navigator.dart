import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/home_page.dart';
import 'package:to_do_list/screens/login_screen.dart';

class AuthNavigator {
  static Future<void> handleAuthNavigation(BuildContext context) async {
    try {
      // Obtener el usuario actual
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Si no hay un usuario logueado, navegar a la pantalla de inicio de sesión
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (user.emailVerified) {
        // Si el usuario está logueado y el correo está verificado, navegar a la pantalla principal
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Si el correo no está verificado, mostrar un mensaje y redirigir al inicio de sesión
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, verifica tu correo electrónico.'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Manejar errores y mostrar un mensaje al usuario
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')));
    }
  }
}
