import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/services/auth_navigator.dart';

class UserButton extends StatelessWidget {
  final FirebaseAuth auth;
  UserButton({super.key, FirebaseAuth? auth})
    : auth = auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              AuthNavigator.handleAuthNavigation(context);
            },
          );
        } else {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (value) async {
              if (value == 'logout') {
                await auth.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada exitosamente.'),
                    ),
                  );
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
