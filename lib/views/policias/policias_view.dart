


import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:flutter/material.dart';

class PoliciasView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
        title: const Text("Listado de policias"),
    backgroundColor: const Color(0xFF4A90E2),
    ),
    drawer: DawerView(),
    body: Center());
  }

}