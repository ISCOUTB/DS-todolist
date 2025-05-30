import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/components/my_button.dart';
import 'package:to_do_list/components/my_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ForgetPasswordScreenState createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final useremailController = TextEditingController();
  bool isloading = false;

  forgotPassword() async {
    setState(() {
      isloading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: useremailController.text,
      );
      Get.snackbar(
        "Email enviado",
        "Revisa tu bandeja de entrada",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
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
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(backgroundColor: Colors.grey[300], elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.password, size: 100, color: Colors.black),
                const SizedBox(height: 50),

                Text(
                  "Reinicio de contraseña",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: useremailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                MyButton(onTap: forgotPassword, text: "Enviar Email"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
