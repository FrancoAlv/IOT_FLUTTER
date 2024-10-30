


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InitView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Column(children: [
      OutlinedButton(onPressed: (){
        final _auth = FirebaseAuth.instance;
        _auth.signOut();
        context.go("/login");
      }, child: Text(""))
    ],)),);
  }

}