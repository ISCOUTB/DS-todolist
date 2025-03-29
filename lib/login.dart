import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list/forgot.dart';
import 'package:to_do_list/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isloading = false;

  signIn() async{
    
    setState(() {
      isloading = true;
    });


    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);

    }on FirebaseAuthException catch(e){
      Get.snackbar("Error", e.message!);
    }catch(e){
      Get.snackbar("Error", e.toString());
    }

    setState(() {
      isloading = false;
    });
    
  }
  
  @override
  Widget build(BuildContext context) {
    return isloading?Center(child: CircularProgressIndicator(),) : Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Enter Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Enter Password"),
            ),
            ElevatedButton(onPressed: (() => signIn()), child: Text("Login")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (() => Get.to(Signup())), child: Text("Register now")),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (() => Get.to(Forgot())), child: Text("Forgot password?")),
          ],
        ),
      ),

    );
  }
}