import 'dart:async';
import 'dart:io';
import 'package:app_iot_web/module.dart';
import 'package:app_iot_web/router/main_router.dart';
import 'package:app_iot_web/service_handler/my_task_handler.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification?.title=="Se ha detectado un accidente"){
    MainRouter.router.go("/contador");
    Consts.keyrouterData =message.data;
  }
}

void main() async {
  await modulo();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>   with WidgetsBindingObserver{

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;



  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
  }

  void _configureFirebaseMessaging() async {

    final isActive = Injector.appInstance.get<SharedPreferences>().getBool(Consts.keyservice) ?? false;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(isActive && uid!= null ){
      await _firebaseMessaging.requestPermission();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler,);
      FirebaseMessaging.onMessage.listen((RemoteMessage message)async  {
        if (message.notification?.title=="Se ha detectado un accidente"){
          MainRouter.router.go("/contador");
          Consts.keyrouterData =message.data;
        }
        // Manejo del mensaje cuando el usuario abre la notificación
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)async  {
        if (message.notification?.title=="Se ha detectado un accidente"){
          MainRouter.router.go("/contador");
          Consts.keyrouterData =message.data;
        }
      });
       FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
         if (initialMessage != null) {
           print("Notificación de segundo plano abierta: ${initialMessage.notification?.title}");
           if (initialMessage.notification?.title=="Se ha detectado un accidente"){
             MainRouter.router.go("/contador");
             Consts.keyrouterData =initialMessage.data;
           }
         }
      },);

    }
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter WebSocket Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: MainRouter.router,
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
  int seconds=0;
  Duration _duration = Duration(seconds: 0);
  // Define a Timer object
  Timer? _timer;
  // Define a variable to store the current countdown value
  int _countdownValue = 0;
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


  double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else if (value is int)   {
      return value.toDouble();
    }else{
    return value;
    }
  }

  void connectToSocket() {
    socket = IO.io('http://192.168.60.1:3000', <String, dynamic>{'transports': ['websocket']});

    socket.onConnect((_) {
      print('Conectado con socket id: ' + socket.id.toString());
    });

    int? checkInt(dynamic value) {
      if(value is int) return value;
      if(value is double) return value.toInt();
      if(value is String) return int.tryParse(value);
      return null;
    }
    socket.on('notificacionAccidente_1', (data) {
      setState(() {
        notificationMessage = data['mensaje'];
        seconds= checkInt(checkDouble(data["time_out"]) /1000)!;
        _duration = Duration(seconds: seconds);
        print(_duration.inSeconds);
      });
      startTimer();
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
    _timer?.cancel();
    super.dispose();
  }
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        _timer?.cancel();
        // Perform any desired action when the countdown is completed
      } else {
        // Update the countdown value and decrement by 1 second
        setState(() {
          _countdownValue = _duration.inSeconds;
          _duration = _duration - Duration(seconds: 1);
        });
      }
    });
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
            Text('Countdown: $_countdownValue'),
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


