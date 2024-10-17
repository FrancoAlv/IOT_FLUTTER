import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:workmanager/workmanager.dart';

// Función que se ejecutará en segundo plano a través de WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await reconnectAndNotify();
    return Future.value(true);
  });
}

// Función que se encarga de reconectar al WebSocket y mostrar notificaciones locales
Future<void> reconnectAndNotify() async {
  IO.Socket socket = IO.io('http://192.168.0.6:3000', <String, dynamic>{
    'transports': ['websocket'],
  });

  // Instancia de Flutter Local Notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Registrar el canal de notificaciones
  var androidNotificationChannel = const AndroidNotificationChannel(
    'notification_channel_id',
    'WebSocket Notifications',
    description: 'Notificaciones para eventos recibidos vía WebSocket',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);

  // Conectar al WebSocket
  socket.onConnect((_) {
    print('Reconectado con socket id: ' + socket.id.toString());
  });

  // Escuchar mensajes del socket y mostrar la notificación local
  socket.on('notificacionAccidente_1', (data) {
    // Mostrar la notificación local
    showLocalNotification(
      flutterLocalNotificationsPlugin,
      title: 'Accidente Detectado',
      body: data['mensaje'],
      accidenteId: data['accidente_id'],
    );
  });

  socket.onDisconnect((_) => print('Desconectado del servidor'));
}

// Función para mostrar la notificación local
Future<void> showLocalNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    {required String title,
      required String body,
      required int accidenteId}) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'notification_channel_id', // ID del canal debe coincidir con el canal registrado
    'WebSocket Notifications', // Nombre del canal
    channelDescription: 'Notificaciones para eventos recibidos vía WebSocket',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  // Mostrar la notificación
  await flutterLocalNotificationsPlugin.show(
    accidenteId, // Usamos el ID del accidente como ID de la notificación
    title,
    body,
    platformChannelSpecifics,
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher, // El callback que se ejecuta en segundo plano
    isInDebugMode: true, // Modo depuración para verificar la funcionalidad
  );

  runApp(const MyApp());

  // Inicializa el WorkManager y registra la tarea periódica

  // Programar una tarea periódica para ejecutar cada 15 minutos
  Workmanager().registerPeriodicTask(
    "2", // ID único de la tarea
    "simpleTask", // Nombre de la tarea
    frequency: Duration(seconds: 15),
    constraints: Constraints(
      networkType: NetworkType.connected, // Optional: constraints on when the task can run
    ),// Frecuencia de la tarea
  );
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
      home: WebSocketExample(),
    );
  }
}

class WebSocketExample extends StatefulWidget {
  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late IO.Socket socket;
  String notificationMessage = "No notifications yet";

  // Instancia de Flutter Local Notifications
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    // Inicializa el servicio en primer plano para Android
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id', // ID del canal
        channelName: 'WebSocket Notifications', // Nombre del canal
        channelDescription: 'Servicio en primer plano para mantener la conexión WebSocket activa',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
      ),
      iosNotificationOptions: IOSNotificationOptions(),
    );

    // Configuración inicial de Flutter Local Notifications para Android
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Registrar el canal de notificaciones
    var androidNotificationChannel = AndroidNotificationChannel(
      'notification_channel_id',
      'WebSocket Notifications',
      description: 'Notificaciones para eventos recibidos vía WebSocket',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Iniciar el servicio de foreground
    //startForegroundTask();

    // Conectar al WebSocket
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('http://192.168.0.6:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Conectado con socket id: ' + socket.id.toString());
    });

    // Escuchar mensajes del socket y mostrar la notificación local
    socket.on('notificacionAccidente_1', (data) {
      setState(() {
        notificationMessage = data['mensaje'];
      });
      // Mostrar la notificación
      showLocalNotification(
        title: 'Accidente Detectado',
        body: data['mensaje'],
        timeout: data['time_out'] ?? 2 * 60 * 1000,
        accidenteId: data['accidente_id'],
      );
    });

    socket.onDisconnect((_) => print('Desconectado del servidor'));
  }

  // Función para mostrar la notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required int timeout,
    required int accidenteId,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel_id', // ID del canal debe coincidir con el canal registrado
      'WebSocket Notifications', // Nombre del canal
      channelDescription: 'Notificaciones para eventos recibidos vía WebSocket',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      timeoutAfter: timeout, // Duración de la notificación
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    // Mostrar la notificación con un timeout definido
    await flutterLocalNotificationsPlugin.show(
      accidenteId, // Usamos el ID del accidente como ID de la notificación
      title,
      body,
      platformChannelSpecifics,
    );

    // Opcional: manejar el caso de que el usuario no responda en el tiempo dado
    Timer(Duration(milliseconds: timeout), () {
      print("Tiempo agotado para la respuesta del accidente ${accidenteId}");
    });
  }

  // Función para iniciar el Foreground Service
  void startForegroundTask() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Conexión WebSocket Activa',
      notificationText: 'La aplicación sigue ejecutándose en segundo plano.',
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
        title: Text("WebSocket Notifications"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(notificationMessage),
            OutlinedButton(onPressed: () {
              showLocalNotification(
                title: 'Prueba Notificación',
                body: 'Esta es una notificación de prueba',
                timeout: 5000, // 5 segundos
                accidenteId: 9999,
              );
            }, child: Text("Probar Notificación"))
          ],
        ),
      ),
    );
  }
}
