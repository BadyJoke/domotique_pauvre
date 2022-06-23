import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'widgets/camera_widget.dart';
import 'widgets/buttonsection_widget.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget with WidgetsBindingObserver {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String?> _ip;

  late Future<Socket> arduino;
  http.Client client = http.Client();

  Future<Socket> connectTo(int port, Duration timeout) {
    late Future<Socket> camera;
    String ip = "";
    _ip.then((value) {
      if (value != null) {
        ip = value;
      }
    });

    camera = retry(() => Socket.connect(ip, port, timeout: timeout),
        retryIf: (e) => e is SocketException || e is TimeoutException,
        maxAttempts: 20,
        delayFactor: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 10));

    camera.then((sock) => client.get(
        Uri.parse("http://${sock.address.address}/control?var=AWAKE&val=0")));

    return camera;
  }

  @override
  void initState() {
    super.initState();
    _ip = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("ip");
    });

    arduino = connectTo(80, const Duration(seconds: 1));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    arduino.then((socket) => client.get(
        Uri.parse("http://${socket.address.address}/control?var=SLEEP&val=0")));
    arduino.then((socket) => socket.destroy());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("PAUSED");
      arduino.then((socket) => client.get(Uri.parse(
          "http://${socket.address.address}/control?var=SLEEP&val=0")));
    }
    if (state == AppLifecycleState.resumed) {
      print("RESUMED");
      arduino.then((sock) => client.get(
          Uri.parse("http://${sock.address.address}/control?var=AWAKE&val=0")));
    }
  }

  setConnect() {
    setState(() {
      _ip = _prefs.then((SharedPreferences prefs) {
        return prefs.getString("ip");
      });

      arduino = connectTo(80, const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promotic',
      home: Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            title: const Text('Promotic'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.black,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OptionMenu(context)),
                  ).then((value) => setConnect());
                },
              )
            ],
          ),
          body: Column(
            children: [
              FutureBuilder<Socket>(
                key: UniqueKey(),
                future: arduino,
                builder:
                    (BuildContext context, AsyncSnapshot<Socket> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CenteredCircularProgressIndicator();
                    default:
                      if (!snapshot.hasData) {
                        return const CenteredCircularProgressIndicator();
                      } else {
                        return Column(
                          children: [
                            const TextSection(),
                            CameraSection(snapshot.data!),
                            ButtonSection(snapshot.data!),
                          ],
                        );
                      }
                  }
                },
              ),
              const SizedBox(height: 25),
              Center(
                  child: ElevatedButton.icon(
                onPressed: setConnect,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ))
            ],
          )),
    );
  }
}

class CenteredCircularProgressIndicator extends StatelessWidget {
  const CenteredCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.cyan,
          strokeWidth: 5,
        ),
      ),
    );
  }
}

class TextSection extends StatelessWidget {
  const TextSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70,
        //color: Colors.grey[400],
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
        child: Column(
          children: [
            Text(
              "Camera",
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
