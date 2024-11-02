import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
class FamiliaresEditView extends StatefulWidget {
  final String nombre;
  final String telefono;
  final String correo;
  final String relacion;
  final int familiarId;

  FamiliaresEditView({
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.relacion,
    required this.familiarId
  });

  @override
  _FamiliaresEditViewState createState() => _FamiliaresEditViewState();
}

class _FamiliaresEditViewState extends State<FamiliaresEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  late TextEditingController _relacionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _telefonoController = TextEditingController(text: widget.telefono);
    _correoController = TextEditingController(text: widget.correo);
    _relacionController = TextEditingController(text: widget.relacion);
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);
      final nombre = _nombreController.text;
      final telefono = _telefonoController.text;
      final correo = _correoController.text;
      final relacion = _relacionController.text;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final url = Uri.parse(
        '${Consts.urlbase}/usuario/${user.uid}/familiar/${widget.familiarId}',
      );
      final Map<String, dynamic> userData = {
        "nombre": nombre.trim(),
        "correo": correo.trim(),
        "telefono":telefono.trim().replaceAll(" ", ""),
        "relacion":relacion.trim()
      };
      try {
        final response = await http.put(
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
          if (context.canPop()){
            context.pop();
          }else{
            context.go("/familiar");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error del sistema por favor intentalo mas tarde')),
          );
        }
      } catch (e) {
        print('Exception: $e');
      } finally{
        hideLoadingDialog(context);
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, complete todos los campos correctamente."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
        title: Text("Editar Familiar"),
        backgroundColor: Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: "Nombre",
                  controller: _nombreController,
                  hintText: "Ingrese el nombre del familiar",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: "Teléfono",
                  controller: _telefonoController,
                  hintText: "Ingrese el teléfono del familiar",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (!RegExp(r'^\+?[\d\s]+$').hasMatch(value)) {
                      return 'Ingrese un teléfono válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: "Correo",
                  controller: _correoController,
                  hintText: "Ingrese el correo electrónico del familiar",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (!RegExp(r'^[\w\.\-]+@[a-zA-Z\d\-]+\.[a-zA-Z\d\-]+$').hasMatch(value)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: "Relación",
                  controller: _relacionController,
                  hintText: "Ingrese la relación (e.g., Madre, Padre, Hermano)",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveChanges(),
                    icon: Icon(Icons.save),
                    label: Text("Guardar Cambios"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hintText,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
