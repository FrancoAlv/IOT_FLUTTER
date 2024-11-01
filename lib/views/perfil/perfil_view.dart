import 'dart:convert';

import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:injector/injector.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PerfilView extends StatefulWidget {
  final bool showAppBar;

  PerfilView({this.showAppBar = false});

  @override
  _PerfilViewState createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final TextEditingController _nombreController = TextEditingController(text: '');
  final TextEditingController _apellidoFirtsController = TextEditingController(text: '');
  final TextEditingController _apellidoSecondController = TextEditingController(text: '');
  final TextEditingController _codigoIOTController = TextEditingController(text: '');
  final TextEditingController _correoController = TextEditingController(text: '');
  final TextEditingController _telefonoController = TextEditingController(text: '');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _serviceActive = false;
  String _tokenmessagin = "";

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
      drawer: widget.showAppBar
          ?  DawerView() : null,
      body: _buildPersonalInfoView(),
    );
  }
  @override
  void initState() {
    super.initState();
    _fetchAccidents();
    setState(() {
    _serviceActive= Injector.appInstance.get<SharedPreferences>().getBool(Consts.keyservice) ?? false;
  });
  }


  Future<void> _fetchAccidents() async {
    Future.delayed(Duration.zero, () => showLoadingDialog(context));
    final prefs = Injector.appInstance.get<SharedPreferences>();
    final email = prefs.getString(Consts.keycorreo);
    final user = FirebaseAuth.instance.currentUser;

    if (email == null || user == null) return;

    final url = Uri.parse(
      '${Consts.urlbase}/usuario/find',
    );

    final Map<String, dynamic> userData = {
      "correo": email,
      "uid_codigo":user.uid
    };
    try {
      final response = await http.post(
        url,
        body: jsonEncode(userData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode<= 300)  {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _nombreController.text=data["nombre"];
        _apellidoFirtsController.text=data["apellido_firts"];
        _apellidoSecondController.text=data["apellido_second"];
        _correoController.text=data["correo"];
        _telefonoController.text=data["telefono"];
        _codigoIOTController.text=data["equipoIoT"]["numero_serie"];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error del sistema por favor intentalo mas tarde')),
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
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildEditableField('Nunero de serie del IOT', _codigoIOTController),
            const SizedBox(height: 16),
            _buildEmailField(),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
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
        const Text(
          'Activar Servicio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Switch(
          value: _serviceActive,
          onChanged: (value) async {
            setState(() {
              _serviceActive = value;
            });
            if (value){

              await _firebaseMessaging.requestPermission();
              // Obtener el token de FCM del dispositivo
              _tokenmessagin= (await _firebaseMessaging.getToken())!;
            }
            _saveProfile();
            Injector.appInstance.get<SharedPreferences>().setBool(Consts.keyservice,value);
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
        child: const Row(
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _correoController,
          keyboardType: TextInputType.emailAddress,
          enabled: false,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'example@mail.com',
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Teléfono',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _telefonoController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: '+51 987654321',
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    showLoadingDialog(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final url = Uri.parse(
      '${Consts.urlbase}/usuario/actualizar',
    );

    final Map<String, dynamic> userData = {
      "nombre": _nombreController.text.trim(),
      "correo": _correoController.text.trim(),
      "telefono": _telefonoController.text.trim(),
      "uid_codigo": user.uid,
      "apellido_firts": _apellidoFirtsController.text.trim(),
      "apellido_second": _apellidoSecondController.text.trim(),
      "codigo_equipo_iot": _codigoIOTController.text.trim(),
      "token_messagin":_tokenmessagin
    };
    try {
      final response = await http.put(
        url,
        body: jsonEncode(userData),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _nombreController.text = data["nombre"];
        _apellidoFirtsController.text = data["apellido_firts"];
        _apellidoSecondController.text = data["apellido_second"];
        _correoController.text = data["correo"];
        _telefonoController.text = data["telefono"];
        _codigoIOTController.text = data["equipoIoT"]["numero_serie"];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error del sistema por favor intentalo mas tarde')),
        );
      }
    } catch (e) {
      print('Exception: $e');
    }
    hideLoadingDialog(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Información guardada exitosamente')),
    );
  }
}
