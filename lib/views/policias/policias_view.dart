import 'dart:convert';
import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PoliciasView extends StatefulWidget {
  @override
  _PoliciasViewState createState() => _PoliciasViewState();
}

class _PoliciasViewState extends State<PoliciasView>  {
  List<Map<String, dynamic>> policias = [];
  bool isLoading = false;
  bool isError = false;
  LatLng selectedLocation = const LatLng(-12.0464, -77.0428); // Ubicación inicial (Lima)
  double radius = 500; // Radio inicial en metros


  Future<void> _fetchPolicias() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/policia');

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as List<dynamic>;
        policias = data.cast<Map<String, dynamic>>();
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
  void initState() {
    super.initState();
    _fetchPolicias();
  }



  void _addPolicia() {
    context.push("/policias/add").then((_) => _fetchPolicias());
  }

  void _editPolicia(int index) {
    context.push('/policias/edit', extra: policias[index]).then((_) => _fetchPolicias());
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

  void _deletePolicia(int index) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/policia/${policias[index]["policia_id"]}');

    try {
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body) as Map<String,dynamic>;
        final messaje=data["message"] ??"";
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
              content: Text(messaje)),
        );
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
    _fetchPolicias();
  }

  void _openLocationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: selectedLocation, zoom: 14),
                      onCameraMove: (position) {
                        setModalState(() {
                          selectedLocation = position.target;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected-location'),
                          position: selectedLocation,
                        )
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Radio: ${radius.toInt()} metros',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: radius,
                          min: 100,
                          max: 2000,
                          divisions: 19,
                          label: '${radius.toInt()} m',
                          onChanged: (value) {
                            setModalState(() {
                              radius = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Cerrar el modal
                            _buscarComisarias();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: const Text('Buscar Comisarías'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _buscarComisarias() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse('${Consts.urlbase}/usuario/${user.uid}/policia/buscar-cercanos');

    final body = {
      'lat': selectedLocation.latitude,
      'lng': selectedLocation.longitude,
      'radius': radius,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Comisarías registradas exitosamente')),
        );
        _fetchPolicias(); // Recargar la lista de policías
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
        title: const Text("Listado de Comisarias"),
        backgroundColor: const Color(0xFF4A90E2),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _openLocationModal,
              tooltip: 'Buscar Comisarías Cercanas',
            ),
          ],
      ),
      drawer: DawerView(),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.inkDrop(
          color: const Color(0xFF4A90E2),
          size: 50,
        ),
      )
          : policias.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              color: Colors.blueAccent.withOpacity(0.6),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              isError
                  ? "Error al cargar las Comisarias."
                  : "No hay Comisarias disponibles.",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isError
                  ? "Por favor, intenta recargar la lista."
                  : "Puedes agregar una nueva Comisaria con el botón de abajo.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchPolicias,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                "Reintentar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shadowColor: Colors.blueAccent.withOpacity(0.4),
                elevation: 6,
              ),
            ),

          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchPolicias,
        child: ListView.builder(
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
                              Flexible(
                                child: Text(
                                  policia['correo'] ?? '',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
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
                          tooltip: "Editar Comisaria",
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPolicia,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        tooltip: 'Agregar una Comisaria',
      ),
    );
  }
}
