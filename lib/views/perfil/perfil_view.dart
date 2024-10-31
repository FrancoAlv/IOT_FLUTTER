import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PerfilView extends StatefulWidget {
  final bool showAppBar;

  PerfilView({this.showAppBar = false});

  @override
  _PerfilViewState createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final TextEditingController _nombreController = TextEditingController(text: 'Juan');
  final TextEditingController _apellidoFirtsController = TextEditingController(text: 'Perez');
  final TextEditingController _apellidoSecondController = TextEditingController(text: 'Gomez');
  final TextEditingController _correoController = TextEditingController(text: 'juan.perez@example.com');
  final TextEditingController _telefonoController = TextEditingController(text: '+51 987654321');

  bool _serviceActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: Text('Perfil del Usuario'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A90E2),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      )
          : null,
      body: _buildPersonalInfoView(),
    );
  }

  Widget _buildPersonalInfoView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            _buildEditableField('Nombre', _nombreController),
            const SizedBox(height: 16),
            _buildEditableField('Primer Apellido', _apellidoFirtsController),
            const SizedBox(height: 16),
            _buildEditableField('Segundo Apellido', _apellidoSecondController),
            const SizedBox(height: 16),
            _buildEditableField('Correo', _correoController),
            const SizedBox(height: 16),
            _buildEditableField('Teléfono', _telefonoController),
            const SizedBox(height: 16),
            _buildServiceSwitch(),
            const SizedBox(height: 24),
            if (!widget.showAppBar) _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Activar Servicio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Switch(
          value: _serviceActive,
          onChanged: (value) {
            setState(() {
              _serviceActive = value;
            });
          },
          activeColor: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _saveProfile,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text('Guardar', style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    // Lógica para guardar los datos
    print("Datos guardados:");
    print("Nombre: ${_nombreController.text}");
    print("Primer Apellido: ${_apellidoFirtsController.text}");
    print("Segundo Apellido: ${_apellidoSecondController.text}");
    print("Correo: ${_correoController.text}");
    print("Teléfono: ${_telefonoController.text}");
    print("Servicio Activo: $_serviceActive");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Información guardada exitosamente')),
    );
  }
}
