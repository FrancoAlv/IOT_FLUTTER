import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
class PoliciasEditView extends StatefulWidget {
  final TextEditingController nombreController;
  final TextEditingController telefonoController;
  final TextEditingController correoController;
  final int policiaId;
  PoliciasEditView({
    required int policiaID,
    required String nombre,
    required String telefono,
    required String correo,
    Key? key,
  })  : nombreController = TextEditingController(text: nombre),
        telefonoController = TextEditingController(text: telefono),
        correoController = TextEditingController(text: correo),
        policiaId=policiaID,
        super(key: key);

  @override
  State<PoliciasEditView> createState() => _PoliciasEditViewState();
}

class _PoliciasEditViewState extends State<PoliciasEditView> {
  final _formKey = GlobalKey<FormState>();

  void _saveChanges(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {

    await  _fetchAccidents();

    }
  }

  Future<void> _fetchAccidents() async {
    Future.delayed(Duration.zero, () => showLoadingDialog(context));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final url = Uri.parse(
      '${Consts.urlbase}/usuario/${user.uid}/policia/${widget.policiaId}',
    );
    final nombre = widget.nombreController.text;
    final telefono = widget.telefonoController.text;
    final correo = widget.correoController.text;
    final Map<String, dynamic> userData = {
      "nombre":nombre.trim(),
      "correo": correo.trim(),
      "telefono":telefono.trim().replaceAll(" ", ""),
    };
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final  data = jsonDecode(response.body) as Map<String,dynamic>;
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
        title: Text("Editar Policía"),
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
                controller: widget.nombreController,
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
                controller: widget.telefonoController,
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
                controller: widget.correoController,
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
                  onPressed: () => _saveChanges(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    "Guardar Cambios",
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
