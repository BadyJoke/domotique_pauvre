import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionMenu extends StatefulWidget {
  final mainContext;
  OptionMenu(this.mainContext, {Key? key}) : super(key: key);

  @override
  State<OptionMenu> createState() => _OptionMenuState();
}

class _OptionMenuState extends State<OptionMenu> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String?> _ip;
  final ipController = TextEditingController();

  Future<void> _saveIp() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("ip", ipController.text);
  }

  @override
  void initState() {
    super.initState();
    _ip = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("ip");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          title: const Text("Settings"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            FutureBuilder<String?>(
              future: _ip,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasData) {
                      ipController.text = snapshot.data!;
                    } else {
                      ipController.text = "";
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 5.0),
                              hintText: "IP adress of arduino",
                            ),
                            controller: ipController,
                            onEditingComplete: _saveIp),
                      ),
                    );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                _saveIp();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ));
  }
}
