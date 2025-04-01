import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/homepage.dart';
import 'package:to_do_list/screens/login_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar un indicador de carga mientras se espera la respuesta
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Manejar errores en el StreamBuilder
            return Center(child: Text('Ocurrió un error. Inténtalo de nuevo.'));
          } else if (snapshot.hasData) {
            // Verificar si el correo está verificado
            final user = snapshot.data!;
            if (user.emailVerified) {
              return Homepage();
            } else {
              return LoginScreen();
            }
          } else {
            // Si no hay datos, mostrar la pantalla de inicio de sesión
            return LoginScreen();
          }
        },
      ),
    );
  }
}