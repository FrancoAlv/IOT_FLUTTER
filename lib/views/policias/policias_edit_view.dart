import 'package:flutter/material.dart';

class PoliciasEditView extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController telefonoController;
  final TextEditingController correoController;

  PoliciasEditView({
    required String nombre,
    required String telefono,
    required String correo,
    Key? key,
  })  : nombreController = TextEditingController(text: nombre),
        telefonoController = TextEditingController(text: telefono),
        correoController = TextEditingController(text: correo),
        super(key: key);

  void _saveChanges(BuildContext context) {
    final nombre = nombreController.text;
    final telefono = telefonoController.text;
    final correo = correoController.text;

    if (nombre.isEmpty || telefono.isEmpty || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Aquí puedes agregar la lógica para guardar los cambios
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
        title: Text("Editar Policía"),
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
              controller: nombreController,
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
              controller: telefonoController,
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
              controller: correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese el correo electrónico del policía",
              ),
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
    );
  }
}
