import 'package:flutter/material.dart';

class OptionMenu extends StatefulWidget {
  const OptionMenu({Key? key}) : super(key: key);

  @override
  State<OptionMenu> createState() => _OptionMenuState();
}

class _OptionMenuState extends State<OptionMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    );
  }
}
