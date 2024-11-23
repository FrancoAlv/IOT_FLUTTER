import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PoliciasAddView extends StatefulWidget {
  @override
  State<PoliciasAddView> createState() => _PoliciasAddViewState();
}

class _PoliciasAddViewState extends State<PoliciasAddView> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true; // Switch para estado activo/inactivo
  LatLng _centerLocation = const LatLng(-12.0464, -77.0428); // Centro inicial (Lima, Perú)

  void _savePolicia(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      await _fetchAccidents();
    }
  }

  Future<void> _fetchAccidents() async {
    showLoadingDialog(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/policia/agregar');
    final Map<String, dynamic> userData = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim().replaceAll(" ", ""),
      "gps": "${_centerLocation.latitude},${_centerLocation.longitude}",
      "isActive": _isActive,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data["message"] ?? "";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error del sistema, intente más tarde')),
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
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
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

  void _openMapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        LatLng tempLocation = _centerLocation;

        return AlertDialog(
          title: const Text("Seleccionar ubicación"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerLocation,
                    zoom: 14,
                  ),
                  onCameraMove: (position) {
                    tempLocation = position.target;
                  },
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                ),
                const Icon(Icons.location_pin, size: 40, color: Colors.red),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _centerLocation = tempLocation;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Comisaria"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nombre",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Ingrese el nombre de la Comisaria",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "El nombre es obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Teléfono",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Ingrese el teléfono de la Comisaria",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final phoneRegex = RegExp(r'^\+?[0-9\s]+$');
                    if (!phoneRegex.hasMatch(value)) {
                      return "Ingrese un teléfono válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Correo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Ingrese el correo electrónico de la Comisaria",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "El correo es obligatorio";
                    }
                    final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return "Ingrese un correo electrónico válido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      "Estado:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    Text(_isActive ? "Activo" : "Inactivo"),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openMapDialog(context),
                      icon: const Icon(Icons.map),
                      label: const Text("Seleccionar Ubicación"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Ubicación seleccionada: ${_centerLocation.latitude.toStringAsFixed(3)}, ${_centerLocation.longitude.toStringAsFixed(3)}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _savePolicia(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
}
