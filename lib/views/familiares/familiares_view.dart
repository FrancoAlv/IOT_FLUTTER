import 'dart:convert';
import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class FamiliaresView extends StatefulWidget {
  @override
  State<FamiliaresView> createState() => _FamiliaresViewState();
}

class _FamiliaresViewState extends State<FamiliaresView> {
  List<Map<String, dynamic>> familiares = [];
  bool isLoading = false;
  bool isError = false;

  void _addFamiliar(BuildContext context) {
    context.push('/familiar/add').then((value) => _fetchFamiliares());
  }

  void _editFamiliar(BuildContext context, int index) {
    context.push('/familiar/edit', extra: familiares[index]).then((value) => _fetchFamiliares());
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

  void _deleteFamiliar(int index) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/familiar/${familiares[index]["familiar_id"]}');

    try {
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as Map<String,dynamic>;
        final messaje=data["message"] ??"";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(messaje)),
        );
      } else {
        setState(() {
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
      });
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    _fetchFamiliares();
  }

  @override
  void initState() {
    super.initState();
    _fetchFamiliares();
  }

  Future _fetchFamiliares() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/familiar');

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as List<dynamic>;
        familiares = data.cast<Map<String, dynamic>>();
        setState(() {});
      } else {
        setState(() {
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
      });
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado de Familiares"),
        backgroundColor: Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : isError
          ? _buildErrorContent()
          : familiares.isNotEmpty
          ? _buildFamiliaresList()
          : _buildEmptyContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addFamiliar(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        tooltip: 'Agregar Familiar',
      ),
    );
  }

  Widget _buildFamiliaresList() {
    return RefreshIndicator(
      onRefresh: _fetchFamiliares,
      child: ListView.builder(
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
                        _buildInfoRow(Icons.phone, familiar['telefono'] ?? ''),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.email, familiar['correo'] ?? ''),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.group, "Relación: ${familiar['relacion'] ?? ''}"),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            info,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.redAccent, size: 80),
          const SizedBox(height: 16),
          Text(
            "Ocurrió un error al cargar los datos",
            style: TextStyle(fontSize: 18, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchFamiliares,
            icon: Icon(Icons.refresh),
            label: Text("Reintentar"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
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
            onPressed: _fetchFamiliares,
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
    );
  }
}
