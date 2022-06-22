import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings.dart';
import 'widgets/camera_widget.dart';
import 'widgets/buttonsection_widget.dart';

class HomeScreen extends StatelessWidget {
  final Socket arduino;

  const HomeScreen(this.arduino, {Key? key}) : super(key: key);

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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OptionMenu()),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            const TextSection(),
            CameraSection(arduino),
            ButtonSection(arduino),
          ],
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
