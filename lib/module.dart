
import 'package:app_iot_web/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  return true;
}