import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PoliciasView extends StatefulWidget {
  @override
  _PoliciasViewState createState() => _PoliciasViewState();
}

class _PoliciasViewState extends State<PoliciasView> {
  final List<Map<String, String>> policias = [
    {'nombre': 'Juan Pérez', 'telefono': '+51 987654321', 'correo': 'juan.perez@example.com'},
    {'nombre': 'Ana Gómez', 'telefono': '+51 987654322', 'correo': 'ana.gomez@example.com'},
    {'nombre': 'Carlos López', 'telefono': '+51 987654323', 'correo': 'carlos.lopez@example.com'},
  ];

  void _addPolicia() {
    context.go("/policias/add");
  }

  void _editPolicia(int index) {
    context.go('/policias/edit', extra:  policias[index]);
  }

  void _confirmDeletePolicia(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar a este policía?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePolicia(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePolicia(int index) {
    setState(() {
      policias.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de policías"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: policias.length,
        itemBuilder: (context, index) {
          final policia = policias[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Información del policía
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policia['nombre'] ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              policia['telefono'] ?? '',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              policia['correo'] ?? '',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botones de acción
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        onPressed: () => _editPolicia(index),
                        tooltip: "Editar Policía",
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _confirmDeletePolicia(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPolicia,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        tooltip: 'Agregar Policía',
      ),
    );
  }
}
