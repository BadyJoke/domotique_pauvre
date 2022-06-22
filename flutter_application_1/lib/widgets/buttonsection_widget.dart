import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

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
    channel.write("UP\n");

    Future.delayed(time, () {
      if (kDebugMode) {
        print("END");
      }
      channel.write("END\n");
    });
  }

  _down(Duration time) {
    if (kDebugMode) {
      print("DOWN");
    }
    channel.write("DOWN\n");

    Future.delayed(time, () {
      if (kDebugMode) {
        print("END");
      }
      channel.write("END\n");
    });
  }
}
