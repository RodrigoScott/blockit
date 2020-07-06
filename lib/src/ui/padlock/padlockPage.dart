import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/model/device.dart';
import 'package:trailock/src/model/versionAppModel.dart';

import 'bluetoothOffScreenWidget.dart';
import 'cardPadLockScanResultWidget.dart';

class PadlockPage extends StatefulWidget {
  @override
  _PadlockPageState createState() => _PadlockPageState();
}

class _PadlockPageState extends State<PadlockPage> {
  SharedPreferences prefs;
  List<Device> devices;
  VersionAppModel version = new VersionAppModel();

  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
  }

  String user;

  @override
  initState() {
    //validateVersion();
    getSharedInstance();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  getSharedInstance() async {
    prefs = await SharedPreferences.getInstance();
    user = prefs.getString('name');
    print('hola: $user');
    devices = prefs.getStringList("padlocks") != null
        ? prefs
            .getStringList("padlocks")
            .map((device) => Device.fromJson(jsonDecode(device)))
            .toList()
        : List<Device>();

    devices.forEach((device) => print(device));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Puertas Disponibles"),
                centerTitle: true,
                backgroundColor: Color(0xff00558A),
              ),
              body: RefreshIndicator(
                onRefresh: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        Icon(
                          Icons.perm_contact_calendar,
                          size: 200,
                          color: Color(0xff00558A),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: size.width * 0.9,
                          child: Text(
                            'Administrador: $user',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          width: size.width * 0.9,
                          child: Text(
                            'Dispositivos: ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        StreamBuilder<List<ScanResult>>(
                          stream: FlutterBlue.instance.scanResults,
                          initialData: [],
                          builder: (c, snapshot) => Column(
                            children: snapshot.data
                                .where((r) => r.device.name.indexOf("TL") != -1)
                                .map((r) {
                              Device device = devices.firstWhere(
                                  (device) => device.name == r.device.name,
                                  orElse: () => null);
                              /*bool isLocked = prefs.getString('padlockName') ==
                                  r.device.name;*/
                              return CardPadLockScanResult(
                                result: r,
                                dateTime:
                                    device != null ? device.datetime : null,
                                remaining:
                                    device != null ? device.duration : null,
                                status: device != null ? device.status : null,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  if (snapshot.data) {
                    return FloatingActionButton(
                      child: Icon(Icons.stop),
                      onPressed: () => FlutterBlue.instance.stopScan(),
                      backgroundColor: Colors.red,
                    );
                  } else {
                    return FloatingActionButton(
                        backgroundColor: Color(0xff00558A),
                        child: Icon(Icons.search),
                        onPressed: () async {
                          getSharedInstance();
                          FlutterBlue.instance
                              .startScan(timeout: Duration(seconds: 5));
                        });
                  }
                },
              ),
            );
          }
          return BluetoothOffScreen(state: state);
        });
  }

  _PadlockPageState();
}
