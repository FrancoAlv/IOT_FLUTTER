import 'package:flutter/material.dart';

class PoliciasAddView extends StatelessWidget {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  void _savePolicia(BuildContext context) {
    final nombre = _nombreController.text;
    final telefono = _telefonoController.text;
    final correo = _correoController.text;

    if (nombre.isEmpty || telefono.isEmpty || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Aquí puedes agregar la lógica para guardar el policía
    Navigator.pop(context, {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nombre",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese el nombre del policía",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Teléfono",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese el teléfono del policía",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Correo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese el correo electrónico del policía",
              ),
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
    );
  }
}
