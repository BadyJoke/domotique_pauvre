import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

/// Create a row of 4 [FloatingActionButton] and takes a [Socket] as parameter.
/// 
/// Buttons on press action is alredy defined.
// ignore: must_be_immutable
class ButtonSection extends StatelessWidget {
  final Socket channel;
  http.Client client = http.Client();

  ButtonSection(this.channel, {Key? key}) : super(key: key);

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
            heroTag: "left-left",
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _down(const Duration(seconds: 5));
            },
            child: const Icon(FeatherIcons.chevronsLeft),
          ),
          FloatingActionButton(
            heroTag: "left",
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _down(const Duration(seconds: 1));
            },
            child: const Icon(FeatherIcons.chevronLeft),
          ),
          FloatingActionButton(
            heroTag: "right",
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _up(const Duration(seconds: 1));
            },
            child: const Icon(FeatherIcons.chevronRight),
          ),
          FloatingActionButton(
            heroTag: "right-right",
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            onPressed: () {
              _up(const Duration(seconds: 5));
            },
            child: const Icon(FeatherIcons.chevronsRight),
          ),
        ],
      ),
    );
  }

  _up(Duration time) {
    if (kDebugMode) {
      print("UP");
    }
    client.get(Uri.parse("http://${channel.address.address}/control?var=UP&val=0"));

    Future.delayed(time, () {
      if (kDebugMode) {
        print("END");
      }
      client.get(Uri.parse("http://${channel.address.address}/control?var=END&val=0"));
    });
  }

  _down(Duration time) {
    if (kDebugMode) {
      print("DOWN");
    }
    client.get(Uri.parse("http://${channel.address.address}/control?var=DOWN&val=0"));

    Future.delayed(time, () {
      if (kDebugMode) {
        print("END");
      }
     client.get(Uri.parse("http://${channel.address.address}/control?var=END&val=0"));
    });
  }
}
