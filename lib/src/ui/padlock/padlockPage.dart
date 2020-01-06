import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/resources/user.Services.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'bluetoothOffScreenWidget.dart';
import 'cardPadLockScanResultWidget.dart';

class PadlockPage extends StatefulWidget {
  @override
  _PadlockPageState createState() => _PadlockPageState();
}

class _PadlockPageState extends State<PadlockPage> {
  SharedPreferences prefs;

  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
  }

  @override
  initState() {
    getSharedInstance();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  getSharedInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<List<ScanResult>>(
                          stream: FlutterBlue.instance.scanResults,
                          initialData: [],
                          builder: (c, snapshot) => Column(
                            children: snapshot.data
                                .where((r) => r.device.name.indexOf("TL") != -1)
                                .map((r) {
                              if (prefs.getString('padlockName') ==
                                  r.device.name)
                                print("El candado " +
                                    r.device.name +
                                    " ya esta bloqueado");
                              return CardPadLockScanResult(
                                result: r,
                                dateTime: prefs.getString("padlockDateTime"),
                                remaining: prefs.getInt("padlockDuration"),
                                status: prefs.getString("padlockStatus"),
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
                    Environment().checkInternetConnection().then((res) {
                      res
                          ? UserService().validateStatus().then((r) {
                              r.statusCode == 401
                                  ? showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          title: Text('Alerta'),
                                          content: Container(
                                              child:
                                                  Text('Tu sesión a caducado')),
                                          actions: <Widget>[
                                            FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                              ),
                                              color: Color(0xffff5f00),
                                              child: Text(
                                                "Aceptar",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () async {
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.remove('access_token');
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SignIn()),
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              },
                                            ),
                                          ],
                                        );
                                      })
                                  : null;
                            })
                          : null;
                    });
                    return FloatingActionButton(
                      child: Icon(Icons.stop),
                      onPressed: () => FlutterBlue.instance.stopScan(),
                      backgroundColor: Colors.red,
                    );
                  } else {
                    return FloatingActionButton(
                        backgroundColor: Color(0xffff5f00),
                        child: Icon(Icons.search),
                        onPressed: () => FlutterBlue.instance
                            .startScan(timeout: Duration(seconds: 5)));
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
