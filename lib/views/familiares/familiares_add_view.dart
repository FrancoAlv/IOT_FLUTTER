import 'package:flutter/material.dart';

class FamiliaresAddView extends StatelessWidget {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _relacionController = TextEditingController();

  void _saveFamiliar(BuildContext context) {
    final nombre = _nombreController.text;
    final telefono = _telefonoController.text;
    final correo = _correoController.text;
    final relacion = _relacionController.text;

    if (nombre.isEmpty || telefono.isEmpty || correo.isEmpty || relacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Todos los campos son obligatorios"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Aquí puedes agregar la lógica para guardar el familiar
    Navigator.pop(context, {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'relacion': relacion,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Familiar"),
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
                hintText: "Ingrese el nombre del familiar",
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
                hintText: "Ingrese el teléfono del familiar",
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
                hintText: "Ingrese el correo electrónico del familiar",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Relación",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _relacionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ingrese la relación (e.g., Madre, Padre, Hermano)",
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _saveFamiliar(context),
                icon: Icon(Icons.save),
                label: Text("Guardar"),
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
    );
  }
}
