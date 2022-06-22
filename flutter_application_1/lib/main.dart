import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:retry/retry.dart';

import 'homme_screen.dart';

void main() async {
  Socket arduino =
      await Socket.connect("8.8.8.8", 80, timeout: const Duration(seconds: 1));
  runApp(MyApp(arduino));
}

Future<Socket> connectTo(String ip, int port, Duration timeout) async {
  Socket camera = await retry(
    () => Socket.connect(ip, port, timeout: timeout),
    retryIf: (e) => e is SocketException || e is TimeoutException,
    maxAttempts: 10,
  );

  return camera;
}

class MyApp extends StatelessWidget {
  final Socket arduino;

  const MyApp(this.arduino, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(arduino),
    );
  }
}
