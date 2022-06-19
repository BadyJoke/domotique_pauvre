import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';



var isRunning = true;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            Text1Section(),
            CameraSection(),
            ButtonSection(),
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

class CameraSection extends StatelessWidget {
  const CameraSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.grey[600],
      child: Column(
        children: const <Widget> [
          Expanded(
            child: Center(
              child: Mjpeg(isLive: true, stream:'https://www.twitch.tv/otplol_'),))
        ],
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({Key? key}) : super(key: key);

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
              // que fait le bouton?
            },
            child: const Icon(FeatherIcons.minus),
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              // que fait le bouton?
            },
            child: const Icon(FeatherIcons.plus),
          )
        ],
      ),
    );
  }
}
