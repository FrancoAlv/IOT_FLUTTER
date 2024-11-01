import 'dart:async';
import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:app_iot_web/views/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class ContadorView extends StatefulWidget {
  @override
  State<ContadorView> createState() => _ContadorViewState();
}

class _ContadorViewState extends State<ContadorView> with TickerProviderStateMixin {
  String notificationMessage = "No notifications yet";
  int seconds = 0;
  Duration _duration = Duration(seconds: 0);
  Timer? _timer;
  bool isSendingMessages = false;
  double progress = 1.0;
  late  int _accidente_id;

  @override
  void initState() {
    super.initState();
    if (Consts.keyrouterData != null) {
      notificationMessage = Consts.keyrouterData?['mensaje'] ?? "";
      _accidente_id = checkInt(checkDouble(Consts.keyrouterData?["accidente_id"]?? "0"))!;
      seconds = checkInt(checkDouble(Consts.keyrouterData?["timeout"]?? "0") / 1000)!;
      _duration = Duration(seconds: seconds);
      startTimer();
      Consts.keyrouterData=null;
    }
  }

  double checkDouble(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is int) return value.toDouble();
    return value;
  }

  int? checkInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void startTimer() {
    progress = 1.0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        _timer?.cancel();
        context.go("/");
      } else {
        setState(() {
          _duration = _duration - Duration(seconds: 1);
          progress = _duration.inSeconds / seconds;
        });
      }
    });
  }

  void activateMessageSending() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Injector.appInstance.get<IO.Socket>().emit("respuestaUsuario",{
      "uid_codigo": uid,
      "accidente_id":_accidente_id,
      "respuesta" : "enviar"
    });
    context.go("/");
  }

  void deactivateMessageSending() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Injector.appInstance.get<IO.Socket>().emit("respuestaUsuario",{
      "uid_codigo": uid,
      "accidente_id":_accidente_id,
      "respuesta":"no"
    });
    context.go("/");
  }

  void resetCountdown() {
    setState(() {
      _duration = Duration(seconds: seconds);
      progress = 1.0;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      drawer: DawerView(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notificationMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Cuenta Regresiva',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  Text(
                    '${_duration.inSeconds}s',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: activateMessageSending,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen.shade400,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white),
                        const SizedBox(width: 8),
                        Text("Activar Envío", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: deactivateMessageSending,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade200,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pause, color: Colors.white),
                        const SizedBox(width: 8),
                        Text("Desactivar Envío", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
