import 'dart:async';
import 'package:app_iot_web/firebase_options.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyTaskHandler extends TaskHandler {
  late IO.Socket socket;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Servicio iniciado en segundo plano');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Inicializa las notificaciones locales
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Registrar el canal de notificaciones
    const androidNotificationChannel = AndroidNotificationChannel(
      'notification_channel_id',
      'WebSocket Notifications',
      description: 'Notificaciones para eventos recibidos vía WebSocket',
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // Conectar al WebSocket
    _connectToSocket();
  }

  void _connectToSocket() {
    socket = IO.io(Consts.urlbase, <String, dynamic>{'transports': ['websocket']});

    socket.onConnect((_) {
      print('Reconectado con socket id: ' + socket.id.toString());
    });

    final uid=FirebaseAuth.instance.currentUser?.uid ??"";

    // Escuchar eventos desde el WebSocket y mostrar notificaciones locales
    socket.on('notificacionAccidente_$uid', (data) {
      // Mostrar la notificación local

      showLocalNotification(
        title: 'Accidente Detectado',
        body: data['mensaje'],
        accidenteId: data['accidente_id'],
      );
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor, intentando reconectar...');
      Timer(Duration(seconds: 5), () {
        _connectToSocket(); // Intentar reconectar después de 5 segundos
      });
    });
  }

  // Función para mostrar la notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required int accidenteId,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel_id', // ID del canal debe coincidir con el canal registrado
      'WebSocket Notifications', // Nombre del canal
      channelDescription: 'Notificaciones para eventos recibidos vía WebSocket',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',

    );
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Mostrar la notificación local
    await flutterLocalNotificationsPlugin.show(
      accidenteId, // Usamos el ID del accidente como ID de la notificación
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Llamado periódicamente para mantener la tarea viva y funcional
  @override
  void onRepeatEvent(DateTime timestamp) {
    print('Servicio en segundo plano sigue activo a las ${timestamp.toString()}');
    // Aquí podrías enviar algún dato al servidor o realizar otra tarea periódica
  }

  // Llamado cuando el servicio es destruido
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Servicio destruido');
    socket.dispose();
  }

  // Llamado cuando la notificación o botones dentro de la notificación son presionados
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/contador'); // Abre la aplicación cuando la notificación es presionada
    print('Notificación presionada');
  }

  @override
  void onNotificationDismissed() {
    print('Notificación descartada');
  }
}