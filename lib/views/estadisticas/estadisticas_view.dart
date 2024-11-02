import 'dart:convert';

import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injector/injector.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EstadisticasView extends StatefulWidget {
  @override
  _EstadisticasViewState createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  int totalAccidents = 0;
  int severeAccidents = 0;
  int minorAccidents = 0;
  Map<String, int> accidentsByLocation = {};
  List<int> accidentsTrend = []; // Datos simulados para tendencia

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
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

  Future<void> _fetchStatistics() async {
    await _fetchAccidents();

  }
  List<Map<String, dynamic>> _accidents = [];
  Future<void> _fetchAccidents() async {
    Future.delayed(Duration.zero, () => showLoadingDialog(context));
    final prefs = Injector.appInstance.get<SharedPreferences>();
    final email = prefs.getString(Consts.keycorreo);
    final user = FirebaseAuth.instance.currentUser;

    if (email == null || user == null) return;

    final url = Uri.parse(
      '${Consts.urlbase}/accidente/findaccidente?uid_user=${user.uid}&email=$email',
    );

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
              "streetname": json?["streetname"] ?? "Unknown",
              'date': DateTime.parse(json['fecha_hora']),
              'time': TimeOfDay(
                hour: DateTime.parse(json['fecha_hora']).hour,
                minute: DateTime.parse(json['fecha_hora']).minute,
              ),
              "vehiculosCercanos": json["vehiculosCercanos"],
              "severity": json["descripcion"].contains("mayor") ? "severe" : "minor",
              "location": latLng.join(", "), // Usa coordenadas como ubicación
            };
          }).toList();

          // Actualizar estadísticas
          totalAccidents = _accidents.length;
          severeAccidents = _accidents.where((accident) => accident['severity'] == 'severe').length;
          minorAccidents = _accidents.where((accident) => accident['severity'] == 'minor').length;

          // Contar accidentes por ubicación
          accidentsByLocation = {};
          for (var accident in _accidents) {
            String location = accident?['streetname']??"Unknown";
            if (accidentsByLocation.containsKey(location)) {
              accidentsByLocation[location] = accidentsByLocation[location]! + 1;
            } else {
              accidentsByLocation[location] = 1;
            }
          }

          // Calcular la tendencia de accidentes por mes
          Map<int, int> monthlyAccidents = {};
          for (var accident in _accidents) {
            int month = accident['date'].month;
            if (monthlyAccidents.containsKey(month)) {
              monthlyAccidents[month] = monthlyAccidents[month]! + 1;
            } else {
              monthlyAccidents[month] = 1;
            }
          }

          // Convertir los datos de tendencia en una lista ordenada por mes
          accidentsTrend = List.generate(12, (index) => monthlyAccidents[index + 1] ?? 0);
        });
      } else {
        print('Error fetching accidents: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    hideLoadingDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchStatistics,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Estadísticas de Accidentes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTotalAccidents(),
              const SizedBox(height: 16),
              _buildAccidentTypeChart(),
              const SizedBox(height: 16),
              _buildAccidentsByLocationChart(),
              const SizedBox(height: 16),
              _buildAccidentsTrendChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAccidents() {
    return Column(
      children: [
        const Text(
          'Total de Accidentes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          totalAccidents.toString(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildAccidentTypeChart() {
    return Column(
      children: [
        Text(
          'Tipos de Accidentes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200, // Altura fija para el PieChart
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: severeAccidents.toDouble(),
                  color: Colors.redAccent,
                  title: 'Graves',
                  radius: 50,
                ),
                PieChartSectionData(
                  value: minorAccidents.toDouble(),
                  color: Colors.orangeAccent,
                  title: 'Leves',
                  radius: 50,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildAccidentsByLocationChart() {
    return Column(
      children: [
        Text(
          'Accidentes por Ubicación',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (accidentsByLocation.values.isNotEmpty
                  ? accidentsByLocation.values.reduce((a, b) => a > b ? a : b)
                  : 10)
                  .toDouble(),
              barGroups: accidentsByLocation.entries.map((entry) {
                return BarChartGroupData(
                  x: accidentsByLocation.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      fromY: 0,
                      toY: entry.value.toDouble(),
                      color: Colors.lightBlueAccent,
                      width: 15,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= accidentsByLocation.keys.length) return Container();
                      String location = accidentsByLocation.keys.toList()[value.toInt()];
                      return Text(location, style: TextStyle(fontSize: 12));
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccidentsTrendChart() {
    return Column(
      children: [
        Text(
          'Tendencia de Accidentes en el Tiempo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('Mes ${value.toInt() + 1}'),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(accidentsTrend.length,
                          (index) => FlSpot(index.toDouble(), accidentsTrend[index].toDouble())),
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.lightBlue.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
