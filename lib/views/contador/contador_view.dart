


import 'dart:async';

import 'package:app_iot_web/views/components/dawer_view.dart';
import 'package:flutter/material.dart';

class ContadorView extends StatelessWidget{

  String notificationMessage = "No notifications yet";

  int seconds=0;
  Duration _duration = Duration(seconds: 0);
  // Define a Timer object
  Timer? _timer;
  // Define a variable to store the current countdown value
  int _countdownValue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebSocket Notifications"),
      ),
      drawer: DawerView(),
      body: Center(
        child: Column(
          children: [
            Text(notificationMessage),
            Text('Countdown: $_countdownValue'),
            OutlinedButton(
              onPressed: () {

              },
              child: const Text("Probar Notificación"),
            ),
          ],
        ),
      ),
    );
  }

}