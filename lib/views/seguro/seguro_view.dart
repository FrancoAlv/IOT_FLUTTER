import 'dart:convert';
import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeguroView extends StatefulWidget {
  @override
  State<SeguroView> createState() => _SeguroViewState();
}

class _SeguroViewState extends State<SeguroView> {
  List<Map<String, dynamic>> seguros = [];

  @override
  void initState() {
    super.initState();
    _fetchSeguros();
  }

  Future<void> _fetchSeguros() async {
    // Aquí se debe agregar la lógica para obtener la lista de seguros desde una API o base de datos.
    // De momento usaremos datos de ejemplo.
    setState(() {
      seguros = [
        {'nombre': 'Seguro 1', 'telefono': '+51 987654321', 'correo': 'seguro1@example.com'},
        {'nombre': 'Seguro 2', 'telefono': '+51 987654322', 'correo': 'seguro2@example.com'},
        {'nombre': 'Seguro 3', 'telefono': '+51 987654323', 'correo': 'seguro3@example.com'},
      ];
    });
  }

  void _addSeguro(BuildContext context) {
    context.push('/seguro/add').then((value) => _fetchSeguros());
  }

  void _editSeguro(BuildContext context, int index) {
    context.push('/seguro/edit', extra: seguros[index]).then((value) => _fetchSeguros());
  }

  void _confirmDeleteSeguro(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar este seguro?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSeguro(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSeguro(int index) {
    setState(() {
      seguros.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado de Seguros"),
        backgroundColor: Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: seguros.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: seguros.length,
        itemBuilder: (context, index) {
          final seguro = seguros[index];
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seguro['nombre'] ?? '',
                          style: const TextStyle(
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
                              seguro['telefono'] ?? '',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.email, color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                seguro['correo'] ?? '',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        onPressed: () => _editSeguro(context, index),
                        tooltip: "Editar Seguro",
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _confirmDeleteSeguro(context, index),
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
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield,
              color: Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay seguros registrados",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchSeguros,
              icon: Icon(Icons.refresh),
              label: Text("Reintentar"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSeguro(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        tooltip: 'Agregar Seguro',
      ),
    );
  }
}
