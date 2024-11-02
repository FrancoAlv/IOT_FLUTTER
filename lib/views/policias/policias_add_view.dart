import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;


class PoliciasAddView extends StatefulWidget {
  @override
  State<PoliciasAddView> createState() => _PoliciasAddViewState();
}

class _PoliciasAddViewState extends State<PoliciasAddView> {
  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _telefonoController = TextEditingController();

  final TextEditingController _correoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _savePolicia(BuildContext context)  async{
    if (_formKey.currentState?.validate() ?? false) {

     await  _fetchAccidents();

    }
  }

  Future<void> _fetchAccidents() async {
    Future.delayed(Duration.zero, () => showLoadingDialog(context));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final url = Uri.parse(
      '${Consts.urlbase}/usuario/${user.uid}/policia/agregar',
    );
    final Map<String, dynamic> userData = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim().replaceAll(" ", ""),
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as Map<String,dynamic>;
        final messaje=data["message"] ??"";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(messaje)),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error del sistema por favor intentalo mas tarde')),
        );
      }
    } catch (e) {
      print('Exception: $e');
    }
    hideLoadingDialog(context);
  }

  void showLoadingDialog(BuildContext contextone) {
    showDialog(
      context: contextone,
      barrierDismissible: false,
      useSafeArea: true,
      // El usuario no puede cerrar el dialogo presionando fuera de él
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: LoadingAnimationWidget.inkDrop(
                color: const Color(0xFF4A90E2),
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext contextone) {
    Navigator.of(contextone).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Policía"),
        backgroundColor: Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nombre",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Ingrese el nombre del policía",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre es obligatorio";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Teléfono",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Ingrese el teléfono del policía",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El teléfono es obligatorio";
                  }
                  final phoneRegex = RegExp(r'^\+?[0-9\s]+$');
                  if (!phoneRegex.hasMatch(value)) {
                    return "Ingrese un teléfono válido";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Correo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Ingrese el correo electrónico del policía",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El correo es obligatorio";
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return "Ingrese un correo electrónico válido";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _savePolicia(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    "Guardar",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
