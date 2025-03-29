import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/wrapper.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    
    signup()async{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
      Get.offAll(Wrapper());
    }
    
    return Scaffold(
      appBar: AppBar(title: Text("Registrar cuenta nueva"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Ingresar Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Ingresar Constraseña"),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (() => signup()), child: Text("Registrarse"))
          ],
        ),
      ),
    );
  }
}