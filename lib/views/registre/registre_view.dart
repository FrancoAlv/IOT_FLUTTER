import 'dart:convert';
import 'package:app_iot_web/views/consts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegistreView extends StatefulWidget {
  @override
  _RegistreViewState createState() => _RegistreViewState();
}

class _RegistreViewState extends State<RegistreView> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidofirtsController = TextEditingController();
  final TextEditingController _apellidosecondController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codigoEquipoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      try {
        // Registro en Firebase
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _correoController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Si el registro en Firebase es exitoso, realiza la solicitud HTTP
        if (userCredential.user != null) {
         await _auth.signOut();
         final response= await _sendUserData(userCredential.user?.uid);
         if (response){
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Usuario registrado exitosamente')),
           );
           if (context.canPop()){
             context.pop();
           }else{
             context.go("/login");
           }
         }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    hideLoadingDialog(context);
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
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

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<bool> _sendUserData(String? uid_codigo) async {
    const String url = "${Consts.urlbase}/usuario/crear"; // Cambia esta URL a la de tu API

    final Map<String, dynamic> userData = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "uid_codigo":uid_codigo,
      "apellido_firts":_apellidofirtsController.text.trim(),
      "apellido_second": _apellidosecondController.text.trim(),
      "codigo_equipo_iot": _codigoEquipoController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode >= 200 && response.statusCode<= 300) {
        print('Datos enviados correctamente');
        return true;
      } else {
        throw Exception('Error al enviar los datos: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud HTTP: ${e.toString()}')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: const Color(0xFF4A90E2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()){
              context.pop();
            }else{
              context.go("/login");
            }

          },
        ),
      ),
      backgroundColor: const Color(0xFFE8F5FE), // Fondo azul claro
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo de la empresa
                  Center(
                    child: Image.asset(
                      'assets/logo.png', // Reemplaza con la ruta de tu logo
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nombreController, 'Nombre Completo'),
                  const SizedBox(height: 20),
                  _buildTextField(_apellidofirtsController, 'Primer Apellido'),
                  const SizedBox(height: 20),
                  _buildTextField(_apellidosecondController, 'Segundo Apellido'),
                  const SizedBox(height: 15),
                  _buildEmailField(_correoController, 'Correo Electrónico'),
                  const SizedBox(height: 15),
                  _buildTextField(_telefonoController, 'Número de Teléfono', TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildTextField(_codigoEquipoController, 'Código de Equipo IoT'),
                  const SizedBox(height: 15),
                  _buildPasswordField(_passwordController, 'Contraseña'),
                  const SizedBox(height: 15),
                  _buildPasswordField(_confirmPasswordController, 'Confirmación de Contraseña', isConfirmation: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Constructor de campos de texto comunes
  Widget _buildTextField(TextEditingController controller, String labelText, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese ${labelText.toLowerCase()}';
        }
        return null;
      },
    );
  }

  // Campo de texto específico para el correo con validación de formato
  Widget _buildEmailField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un correo electrónico';
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Por favor ingrese un correo válido';
        }
        return null;
      },
    );
  }

  // Campo de contraseña con validación y confirmación opcional
  Widget _buildPasswordField(TextEditingController controller, String labelText, {bool isConfirmation = false}) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: const Icon(Icons.lock, color: Color(0xFF4A90E2)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese una contraseña';
        } else if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        } else if (isConfirmation && value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _codigoEquipoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
