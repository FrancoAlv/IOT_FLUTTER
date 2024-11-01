
import 'dart:async';

import 'package:app_iot_web/firebase_options.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

Future<bool> modulo() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Se genera la inicio y conexion con firebase segun la plataforma que nos encontramos
  //se debe esperar con la palabra await y el await solo usa async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  //instancia de injector para registro de dependencias
  final injector = Injector.appInstance;
  //Inicio del preferent para guardado de datos
  final preferences= await SharedPreferences.getInstance();
  //services
  injector.registerSingleton(() => preferences);


  final isActive = Injector.appInstance.get<SharedPreferences>().getBool(Consts.keyservice) ?? false;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if(isActive && uid!= null ){
    Timer? reconnectTimer;
    IO.Socket  socket = IO.io(Consts.urlbase, <String, dynamic>{'transports': ['websocket']});
    socket.onConnect((_) {
      reconnectTimer?.cancel();
      print('Conectado con socket id: ' + socket.id.toString());
    });
   socket.onDisconnect((_) {
     reconnectTimer?.cancel();
     reconnectTimer= Timer(const Duration(seconds: 5), () {
       socket.connect();
     });
   });
   Injector.appInstance.registerSingleton<IO.Socket>(()=>socket);
  }
  return true;
}