import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
  FlutterForegroundTask.initCommunicationPort();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebSocket Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebSocketExample(),
    );
  }
}

class WebSocketExample extends StatefulWidget {
  const WebSocketExample({super.key});

  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late IO.Socket socket;
  String notificationMessage = "No notifications yet";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initService();
    connectToSocket();
    requestNotificationPermission();

    // Configuración inicial de las notificaciones locales
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void connectToSocket() {
    socket = IO.io('http://192.168.0.6:3000', <String, dynamic>{'transports': ['websocket']});

    socket.onConnect((_) {
      print('Conectado con socket id: ' + socket.id.toString());
    });

    socket.on('notificacionAccidente_1', (data) {
      setState(() {
        notificationMessage = data['mensaje'];
      });
      showLocalNotification(
        title: 'Accidente Detectado',
        body: data['mensaje'],
        accidenteId: data['accidente_id'],
      );
    });

    socket.onDisconnect((_) => print('Desconectado del servidor'));
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required int accidenteId,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel_id',
      'WebSocket Notifications',
      channelDescription: 'Notificaciones para eventos recibidos vía WebSocket',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      accidenteId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _requestPermissions() async {
    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid && !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'Este servicio está ejecutándose en primer plano.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.startService(
      notificationTitle: 'WebSocket Activo',
      notificationText: 'Escuchando eventos en segundo plano',
      callback: startCallback,
    );
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebSocket Notifications"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(notificationMessage),
            OutlinedButton(
              onPressed: () {
                showLocalNotification(
                  title: 'Prueba Notificación',
                  body: 'Esta es una notificación de prueba',
                  accidenteId: 9999,
                );
              },
              child: const Text("Probar Notificación"),
            ),
          ],
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  late IO.Socket socket;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Servicio iniciado en segundo plano');

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
    socket = IO.io('http://192.168.0.6:3000', <String, dynamic>{'transports': ['websocket']});

    socket.onConnect((_) {
      print('Reconectado con socket id: ' + socket.id.toString());
    });

    // Escuchar eventos desde el WebSocket y mostrar notificaciones locales
    socket.on('notificacionAccidente_1', (data) {
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
    FlutterForegroundTask.launchApp('/'); // Abre la aplicación cuando la notificación es presionada
    print('Notificación presionada');
  }

  @override
  void onNotificationDismissed() {
    print('Notificación descartada');
  }
}
