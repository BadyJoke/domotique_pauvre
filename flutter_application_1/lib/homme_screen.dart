import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings.dart';
import 'widgets/camera_widget.dart';
import 'widgets/buttonsection_widget.dart';

class HomeScreen extends StatefulWidget {
  late Socket arduino;

  HomeScreen(this.arduino, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  setSocket(Socket s) {
    setState(() {
      widget.arduino = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.arduino);
    return MaterialApp(
      title: 'Domotic',
      home: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          title: const Text('Domotic'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OptionMenu(context)),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            const TextSection(),
            CameraSection(widget.arduino),
            ButtonSection(widget.arduino),
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
