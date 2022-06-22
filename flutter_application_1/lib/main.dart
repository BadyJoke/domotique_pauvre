import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:retry/retry.dart';

void main() async {
  Socket camera =
      await Socket.connect("8.8.8.8", 80, timeout: const Duration(seconds: 1));
  Socket sock =
      await Socket.connect("8.8.8.8", 80, timeout: const Duration(seconds: 1));
  runApp(MyApp(sock, camera));
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
            style: GoogleFonts.openSans(
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
              "Caméra",
              style: GoogleFonts.openSans(
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    widget.cameraSocket.write("SLEEP\n");
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
              _down(channel, const Duration(seconds: 5));
            },
            child: const Icon(FeatherIcons.chevronsLeft),
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _down(channel, const Duration(seconds: 1));
            },
            child: const Icon(FeatherIcons.chevronLeft),
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _up(channel, const Duration(seconds: 1));
            },
            child: const Icon(FeatherIcons.chevronRight),
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _up(channel, const Duration(seconds: 5));
            },
            child: const Icon(FeatherIcons.chevronsRight),
          ),
        ],
      ),
    );
  }
}

_up(Socket s, Duration time) {
  print("UP");
  s.write("UP\n");

  Future.delayed(time, () {
    print("END");
    s.write("END\n");
  });
}

_down(Socket s, Duration time) {
  print("DOWN");
  s.write("DOWN\n");

  Future.delayed(time, () {
    print("END");
    s.write("END\n");
  });
}
