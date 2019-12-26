import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:trailock/src/widgets/loadingAlertDismissible.dart';

class PadlockPage extends StatefulWidget {
  @override
  _PadlockPageState createState() => _PadlockPageState();
}

class _PadlockPageState extends State<PadlockPage> {
  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
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
                                .map((r) => CardPadLockScanResult(
                                      result: r,
                                    ))
                                .toList(),
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

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF5F00),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Center(
              child: Text(
                'Para desbloquear candados enciende el Bluetooth.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardPadLockScanResult extends StatefulWidget {
  CardPadLockScanResult({Key key, this.result}) : super(key: key);
  final ScanResult result;

  @override
  _CardPadLockScanResultState createState() => _CardPadLockScanResultState();
}

class _CardPadLockScanResultState extends State<CardPadLockScanResult> {
  final codeFieldController = TextEditingController();
  var _validateField = GlobalKey<FormState>();
  var _fController = TextEditingController();
  bool validateContainer = false;
  bool validateUseContainer = false;
  String textError = '';
  void initState() {
    codeFieldController.addListener(() {
      setState(() {
        _validateField.currentState.validate();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    closeAlert(BuildContext _context) {
      Navigator.of(_context).pop();
    }

    var loadingContext;
    Widget createInput(
      TextEditingController controller,
      Function _valida,
    ) {
      return Container(
          height: MediaQuery.of(context).size.height * .07,
          width: MediaQuery.of(context).size.width * .9,
          child: TextFormField(
            validator: _valida,
            obscureText: false,
            keyboardType: TextInputType.visiblePassword,
            maxLength: 9,
            controller: controller,
            cursorColor: Colors.black,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xffe3e3e3),
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.transparent)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.transparent)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.transparent)),
            ),
          ));
    }

    Widget _inputValidate = createInput(codeFieldController, (value) {
      if (_fController.text.length < 9) {
        return ('Ingresa 9 caracteres');
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 6.0,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Center(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFFF5F00),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(5))),
                  height: 120,
                  width: MediaQuery.of(context).size.width * .35,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .3,
                    child: Image.asset(
                      "assets/trailockorange.png",
                    ),
                  ),
                )),
                SizedBox(
                  width: 40,
                ),
                Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Candado',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(widget.result.device.name,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                var device = widget.result.advertisementData.connectable
                    ? widget.result.device
                    : null;

                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      loadingContext = context;
                      return LoadingAlertDismissible();
                    });

                widget.result.device.connect().then((response) {
                  widget.result.device.discoverServices().then((services) {
                    BluetoothService service = services
                        .where((s) =>
                            s.uuid
                                .toString()
                                .toUpperCase()
                                .substring(4, 8)
                                .indexOf('1101') !=
                            -1)
                        .toList()
                        .first;

                    BluetoothCharacteristic characteristic = service
                        .characteristics
                        .where((c) =>
                            c.uuid
                                .toString()
                                .toUpperCase()
                                .substring(4, 8)
                                .indexOf('2101') !=
                            -1)
                        .toList()
                        .first;
                    BluetoothCharacteristic unlockedCharacteristic = service
                        .characteristics
                        .where((c) =>
                            c.uuid
                                .toString()
                                .toUpperCase()
                                .substring(4, 8)
                                .indexOf('2102') !=
                            -1)
                        .toList()
                        .first;
                    closeAlert(loadingContext);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 170, top: 100),
                              child: SingleChildScrollView(
                                child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    content: Column(
                                      children: <Widget>[
                                        Text('Candado',
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold)),
                                        Text(widget.result.device.name,
                                            style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .07,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .07,
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Codigo',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9,
                                          child: Form(
                                              key: _validateField,
                                              child: _inputValidate),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            onTap: () async {
                                              await characteristic.write(
                                                  utf8.encode(
                                                      codeFieldController.text
                                                          .toUpperCase()));
                                              int lockedStatus =
                                                  (await unlockedCharacteristic
                                                      .read())[0];
                                              print(await unlockedCharacteristic
                                                  .read());
                                              setState(() {
                                                switch (lockedStatus) {
                                                  case 0:
                                                    print('case 0');
                                                    validateContainer = true;
                                                    textError =
                                                        'Codigo incorrecto';
                                                    break;
                                                  case 1:
                                                    validateContainer = false;
                                                    textError = '';
                                                    print('case 1');
                                                    Navigator.pop(context);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    5),
                                                              ),
                                                            ),
                                                            title: Text(
                                                                'Codigo correcto'),
                                                            content: Container(
                                                                child: Text(
                                                                    'El candado permanecera abierto durante 5 min')),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                ),
                                                                color: Color(
                                                                    0xffff5f00),
                                                                child: Text(
                                                                  "Aceptar",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        });
                                                    break;
                                                  case 2:
                                                    print('case 2');
                                                    validateContainer = true;
                                                    textError =
                                                        'El candado está abierto';
                                                    break;
                                                }
                                              }); //
                                            },
                                            child: Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Color(0xffff5f00),
                                                ),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .07,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .9,
                                                child: Center(
                                                  child: Text(
                                                    'Verificar',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          });
                        }).then((data) {
                      print("Ya me desconecte");
                      widget.result.device.disconnect();
                    });
                  });
                });
              },
              splashColor: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff081f2d),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                height: 50,
                child: Center(
                  child: Text(
                    'Desbloquear',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("Ya me salí");
    widget.result.device.disconnect();
    super.dispose();
  }
}
