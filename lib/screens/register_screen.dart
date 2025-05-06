import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:to_do_list/components/my_button.dart';
import 'package:to_do_list/components/my_text_field.dart';
import 'package:to_do_list/services/auth_navigator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final useremailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool isloading = false;

  RegisterUser() async {
    setState(() {
      isloading = true;
    });

    if (passwordController.text.trim() !=
        confirmpasswordController.text.trim()) {
      Get.snackbar("Error", "Las contraseñas no coinciden");
      setState(() {
        isloading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: useremailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
      Get.snackbar(
        "Éxito",
        "Registro exitoso. Verifica tu email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Usar AuthNavigator para manejar la navegación
      await AuthNavigator.handleAuthNavigation(context);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message!);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(backgroundColor: Colors.grey[300], elevation: 0),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.supervised_user_circle, size: 100),
                    const SizedBox(height: 40),
                    Text(
                      "Registrate como un nuevo usuario",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: useremailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: passwordController,
                      hintText: "Contraseña",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: confirmpasswordController,
                      hintText: "Confirma tu contraseña",
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    MyButton(onTap: RegisterUser, text: "Registrar"),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(
                              "O continua con",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Bootstrap.google, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
