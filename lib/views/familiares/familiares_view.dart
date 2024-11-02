import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FamiliaresView extends StatelessWidget {
  final List<Map<String, String>> familiares = [
    {
      "nombre": "María López",
      "telefono": "+51 987654321",
      "correo": "maria.lopez@example.com",
      "relacion": "Madre"
    },
    {
      "nombre": "Carlos Sánchez",
      "telefono": "+51 987654322",
      "correo": "carlos.sanchez@example.com",
      "relacion": "Padre"
    },
    {
      "nombre": "Ana Gómez",
      "telefono": "+51 987654323",
      "correo": "ana.gomez@example.com",
      "relacion": "Hermana"
    }
  ];

  void _addFamiliar(BuildContext context) {
    // Navegar a la pantalla para agregar un nuevo familiar
     context.push('/familiar/add');
  }

  void _editFamiliar(BuildContext context, int index) {
    // Navegar a la pantalla para editar el familiar
     context.push('/familiar/edit', extra: familiares[index]);
  }

  void _confirmDeleteFamiliar(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar a este familiar?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFamiliar(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteFamiliar(int index) {
    // Lógica para eliminar el familiar
    print("Familiar eliminado: ${familiares[index]['nombre']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado de Familiares"),
        backgroundColor: Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: familiares.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: familiares.length,
        itemBuilder: (context, index) {
          final familiar = familiares[index];
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
                          familiar['nombre'] ?? '',
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
                              familiar['telefono'] ?? '',
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
                                familiar['correo'] ?? '',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Relación: ${familiar['relacion'] ?? ''}",
                                style: TextStyle(fontSize: 16, color: Colors.black87),
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
                        onPressed: () => _editFamiliar(context, index),
                        tooltip: "Editar Familiar",
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _confirmDeleteFamiliar(context, index),
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
              Icons.family_restroom,
              color: Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay familiares registrados",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchFamiliares(), // Función para recargar los datos
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
        onPressed: () => _addFamiliar(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        tooltip: 'Agregar Familiar',
      ),
    );
  }

  void _fetchFamiliares() {
    // Lógica para obtener la lista de familiares desde una API o fuente de datos.
  }
}
