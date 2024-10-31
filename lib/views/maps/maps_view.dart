import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injector/injector.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class MapsView extends StatefulWidget {
  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  bool _locationPermissionGranted = false;
  GoogleMapController? _mapController;
  Marker? _accidentMarker;

  DateTimeRange? _selectedDateRange;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _accidents = [];


  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    //_fetchAccidents();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAccidents(); // Ahora se llama en didChangeDependencies
  }

  Future<void> _fetchAccidents() async {
    Future.delayed(Duration.zero, () => showLoadingDialog(context));
    final prefs = Injector.appInstance.get<SharedPreferences>();
    final email = prefs.getString(Consts.keycorreo);
    final user = FirebaseAuth.instance.currentUser;

    if (email == null || user == null) return;

    final url = Uri.parse(
      '${Consts.urlbase}/accidente/findaccidente?uid_user=${user.uid}&email=$email',
    );
    //print('${Consts.urlbase}/accidente/findaccidente?uid_user=${user.uid}&email=$email');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _accidents = data.map((json) {
            final latLng = json['ubicacion_gps'].split(', ');

            return {
              'id': json['accidente_id'].toString(),
              'title': 'Accidente ${json['accidente_id']}',
              'description': json['descripcion'],
              'position': LatLng(
                double.parse(latLng[0]),
                double.parse(latLng[1]),
              ),
              'date': DateTime.parse(json['fecha_hora']),
              'time': TimeOfDay(
                hour: DateTime.parse(json['fecha_hora']).hour,
                minute: DateTime.parse(json['fecha_hora']).minute,
              ),
              "vehiculosCercanos":json["vehiculosCercanos"]
            };
          }).toList();

        });
      } else {
        print('Error fetching accidents: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    hideLoadingDialog(context);
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.location.request();
    }

    setState(() {
      _locationPermissionGranted = status.isGranted;
    });
  }

  void _updateMarker(Map<String, dynamic> accident) {
    setState(() {
      _accidentMarker = Marker(
        markerId: MarkerId(accident['id']),
        position: accident['position'],
        infoWindow: InfoWindow(
          title: accident['title'],
          snippet: accident['description'],
          onTap: () {
            _showAccidentInfo(
              accident
            );
          },
        ),
      );
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(accident['position'], 14),
    );
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _selectTimeRange() async {
    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start != null) {
      TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: start,
      );
      if (end != null) {
        setState(() {
          _startTime = start;
          _endTime = end;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAccidents {
    return _accidents.where((accident) {
      bool matchesDateRange = _selectedDateRange == null ||
          (accident['date'] as DateTime).isAfter(_selectedDateRange!.start) &&
              (accident['date'] as DateTime).isBefore(_selectedDateRange!.end);
      bool matchesTimeRange = _startTime == null ||
          (_startTime != null &&
              _endTime != null &&
              (accident['time'] as TimeOfDay).hour >= _startTime!.hour &&
              (accident['time'] as TimeOfDay).minute >= _startTime!.minute &&
              (accident['time'] as TimeOfDay).hour <= _endTime!.hour &&
              (accident['time'] as TimeOfDay).minute <= _endTime!.minute);
      return matchesDateRange && matchesTimeRange;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = null;
      _startTime = null;
      _endTime = null;
    });
  }

  void _showAccidentInfo(Map<String, dynamic> accident) {
    final vehiculosCercanos = accident['vehiculosCercanos'] as List<dynamic>?;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accident['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Descripción: ${accident['description']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                Text(
                  'Fecha y Hora: ${_formatDateTime(accident['date'])}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                if (vehiculosCercanos != null && vehiculosCercanos.isNotEmpty) ...[
                  Text(
                    'Vehículos Cercanos:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  for (var vehiculo in vehiculosCercanos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• Placa: ${vehiculo['placa']}',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Fecha y Hora de Acercamiento: ${_formatDateTime(vehiculo['fecha_hora_acercamiento'])}',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 5),
                          if (vehiculo['fotoTemporal'] != null) ...[
                            Text(
                              'Foto Capturada:',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                // Abre la imagen en una nueva pestaña o utiliza cualquier lógica que prefieras
                                launch(vehiculo['fotoTemporal']['url_foto']);
                              },
                              child: Image.network(
                                vehiculo['fotoTemporal']['url_foto'],
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Fecha de Captura: ${_formatDateTime(vehiculo['fotoTemporal']['fecha_hora_captura'])}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            Text(
                              'Fecha de Expiración: ${_formatDateTime(vehiculo['fotoTemporal']['fecha_expiracion'])}',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                ] else
                  Text(
                    'No se encontraron vehículos cercanos.',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper para formatear fechas
  String _formatDateTime(dynamic dateTime) {
    DateTime date;

    // Verificar si dateTime es String y convertirlo
    if (dateTime is String) {
      date = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'Formato desconocido';
    }

    // Formatear la fecha y hora en el formato deseado
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void showLoadingDialog(BuildContext contextone) {
    showDialog(
      context: contextone,
      barrierDismissible: false,
      useSafeArea: true,
      // El usuario no puede cerrar el dialogo presionando fuera de él
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _selectedDateRange == null
                                ? 'Rango de Fechas'
                                : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectTimeRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _startTime == null || _endTime == null
                                ? 'Rango de Horas'
                                : '${_startTime!.format(context)} - ${_endTime!.format(context)}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.redAccent),
                iconSize: 30,
                onPressed: _clearFilters,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-12.0464, -77.0428),
                  zoom: 12,
                ),
                markers: _accidentMarker != null ? {_accidentMarker!} : {},
                myLocationEnabled: _locationPermissionGranted,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchAccidents();
            },
            child: _filteredAccidents.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No hay accidentes disponibles',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _fetchAccidents();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Recargar'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredAccidents.length,
              itemBuilder: (context, index) {
                final accident = _filteredAccidents[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    title: Text(
                      accident['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      accident['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _updateMarker(accident);
                      _showAccidentInfo(accident);
                    },
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }
}
