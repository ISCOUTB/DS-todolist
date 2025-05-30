import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/services/auth_navigator.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance
              .authStateChanges(), // Escucha cambios en el estado de autenticación
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          // Si no hay un usuario logueado, muestra el botón de navegación al LoginScreen
          return IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Aquí puedes manejar la navegación al LoginScreen si es necesario
              AuthNavigator.handleAuthNavigation(context);
            },
          );
        } else {
          // Si hay un usuario logueado, muestra el menú desplegable
          return PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada exitosamente.'),
                    ),
                  );
                  // No redirigir al LoginScreen, solo cerrar sesión
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'user',
                    enabled: false,
                    child: Text('Usuario: ${user.email ?? "Desconocido"}'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Cerrar sesión'),
                  ),
                ],
          );
        }
      },
    );
  }
}
