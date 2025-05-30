import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:to_do_list/components/my_button.dart';
import 'package:to_do_list/components/my_text_field.dart';
import 'package:to_do_list/screens/forget_password_screen.dart';
import 'package:to_do_list/screens/register_screen.dart';
import 'package:to_do_list/services/synchronization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final useremailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isloading = false;

  Future<void> loginUser() async {
    setState(() {
      isloading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: useremailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await SynchronizationService().initialize();

      if (!mounted) return; // Chequeo inmediato tras el await

      Get.snackbar(
        "Éxito",
        "Inicio de sesión exitoso",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message!);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            backgroundColor: Colors.grey[300],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // Volver a la pantalla anterior
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.lock, size: 100, color: Colors.black),
                    const SizedBox(height: 50),

                    Text(
                      "Bienvenido Otra Vez",
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap:
                                (() =>
                                    Get.to(() => const ForgetPasswordScreen())),
                            child: Text(
                              "Olvidaste tu contraseña?",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    MyButton(onTap: loginUser, text: "Iniciar Sesión"),

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
                          icon: const Icon(
                            Bootstrap.google,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No tienes una cuenta?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: (() => Get.to(() => const RegisterScreen())),
                          child: const Text(
                            "Registrate",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
