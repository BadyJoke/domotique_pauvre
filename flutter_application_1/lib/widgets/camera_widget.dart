import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

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
                isLive: isRunning,
                error: (context, error, stack) {
                  return handleErrorWidget(context, error, stack);
                },
                stream: 'http://${widget.cameraSocket.address.address}:81/stream'),
          )),
        ],
      ),
    );
  }
}

Widget handleErrorWidget(context, error, stack){

  return Text(error.toString(), style: const TextStyle(color: Colors.red));
}