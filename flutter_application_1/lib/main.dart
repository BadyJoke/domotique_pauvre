import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:retry/retry.dart';

void main() async {
  Socket camera = await Socket.connect("192.168.181.79", 80,
      timeout: const Duration(seconds: 1));
  Socket sock = await Socket.connect("192.168.181.202", 80);
  runApp(MyApp(sock, camera));
}

awakeCamera() async {
  Socket camera = await retry(
    () => Socket.connect("192.168.181.79", 80,
        timeout: const Duration(seconds: 1)),
    retryIf: (e) => e is SocketException || e is TimeoutException,
  );
  camera.write("AWAKE\n");
}

class MyApp extends StatelessWidget {
  final Socket socket;
  final Socket cameraSocket;

  const MyApp(this.socket, this.cameraSocket, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domotic',
      home: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.grey[200],
          title: Text(
            'Domotic',
            style: GoogleFonts.nunito(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Text1Section(),
            CameraSection(cameraSocket),
            ButtonSection(socket),
          ],
        ),
      ),
    );
  }
}

class Text1Section extends StatelessWidget {
  const Text1Section({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70,
        //color: Colors.grey[400],
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
        child: Column(
          children: [
            Text(
              "Retour Caméra",
              style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ));
  }
}

class CameraSection extends StatefulWidget {
  final Socket cameraSocket;
  const CameraSection(this.cameraSocket, {Key? key}) : super(key: key);

  @override
  State<CameraSection> createState() => _CameraSectionState();
}

class _CameraSectionState extends State<CameraSection>
    with WidgetsBindingObserver {
  bool isRunning = true;
  String buttonLabel = "On";

  changeText() {
    setState(() {
      if (isRunning) {
        buttonLabel = "On";
      }
      if (!isRunning) {
        buttonLabel = "Off";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    widget.cameraSocket.write("SLEEP");
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.grey[600],
      child: Column(
        children: <Widget>[
          Expanded(
              child: Center(
            child: Mjpeg(
                isLive: isRunning, stream: 'http://192.168.181.79:81/stream'),
          )),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 25),
              ),
              onPressed: () {
                isRunning = !isRunning;
                changeText();
              },
              child: Text(buttonLabel))
        ],
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  final Socket channel;

  const ButtonSection(this.channel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.grey[300],
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _down(channel);
            },
            child: const Icon(FeatherIcons.minus),
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _up(channel);
            },
            child: const Icon(FeatherIcons.plus),
          )
        ],
      ),
    );
  }
}

_up(Socket s) {
  print("UP");
  s.write("UP\n");
}

_down(Socket s) {
  print("DOWN");
  s.write("DOWN\n");
}
