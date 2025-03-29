import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:to_do_list/wrapper.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {

  @override
  void initState(){
    sendverifylink();
    super.initState();
  }

  sendverifylink()async{
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) => {
      Get.snackbar(
        "Link Enviado", 
        "Un link ha sido enviado a tu correo electronico", 
        margin: EdgeInsets.all(30), 
        snackPosition: SnackPosition.BOTTOM
        )
    });
  }

  reload()async{
    await FirebaseAuth.instance.currentUser!.reload().then((value) => {Get.offAll(Wrapper())});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verificacion de Email"),),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Text("Abre tu email y clickea en el link provisionado para verficar, luego recarga la pagina"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => reload()),
        child: Icon(Icons.restart_alt_rounded),
      ),
    );
  }
}