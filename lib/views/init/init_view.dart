import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:app_iot_web/views/estadisticas/estadisticas_view.dart';
import 'package:app_iot_web/views/maps/maps_view.dart';
import 'package:app_iot_web/views/perfil/perfil_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class InitView extends StatefulWidget {
  const InitView({super.key});

  @override
  _InitViewState createState() => _InitViewState();
}

class _InitViewState extends State<InitView> with WidgetsBindingObserver {

  int _selectedIndex = 1; // Comienza en el índice de Mapa

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async  {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // La app ha vuelto al primer plano
      while (true){
        if (Consts.keyrouter!=""){
        await Future.delayed(const Duration(seconds: 1),() {
            context.go(Consts.keyrouter);
            Consts.keyrouter="";
        },);
        }else{
          break;
        }

      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildStatisticsView();
      case 1:
        return _buildMapView();
      case 2:
        return _buildPersonalInfoView();
      default:
        return _buildMapView();
    }
  }

  Widget _buildStatisticsView() {
    return EstadisticasView();
  }



  Widget _buildPersonalInfoView() {
    return PerfilView();
  }

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: _buildContent(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics, color: Color(0xFF4A90E2)),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(Icons.map, color: Color(0xFF4A90E2)),
              ),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: Color(0xFF4A90E2)),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return MapsView();
  }
}
