import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/widgets/loadingAlertDismissible.dart';

class CardPadLockScanResult extends StatefulWidget {
  CardPadLockScanResult(
      {Key key, this.result, this.remaining, this.dateTime, this.status})
      : super(key: key);
  final ScanResult result;
  final int remaining;
  final String dateTime;
  final String status;

  @override
  _CardPadLockScanResultState createState() => _CardPadLockScanResultState();
}

class _CardPadLockScanResultState extends State<CardPadLockScanResult> {
  final codeFieldController = TextEditingController();
  var _validateField = GlobalKey<FormState>();
  bool validateContainer = false;
  bool validateUseContainer = false;
  String textError = '';
  String _current = '0:00';
  String padlockStatus = "ready";
  Duration _duration;

  StreamSubscription<CountdownTimer> timer;

  void startTimer(_duration) {
    timer = CountdownTimer(Duration(seconds: _duration), Duration(seconds: 1))
        .listen((data) {})
          ..onData((CountdownTimer data) {
            setState(() {
              _current =
                  '${data.remaining.inMinutes}:${(data.remaining.inSeconds % 60).toString().padLeft(2, '0')}';
            });
          })
          ..onDone(() {
            clearSharedPreferences();
          });
  }

  @override
  void initState() {
    print("object");
    print(widget.dateTime);

    if (widget.dateTime != null) {
      var started = DateTime.parse(widget.dateTime);
      var rest =
          widget.remaining - DateTime.now().difference(started).inSeconds;

      print(rest);

      if (rest > 0) {
        startTimer(rest);
        padlockStatus = widget.status;
      } else
        clearSharedPreferences();
    }

    codeFieldController.addListener(() {
      setState(() {
        _validateField.currentState.validate();
      });
    });
    super.initState();
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      padlockStatus = "ready";
    });

    prefs.remove('padlockName');
    prefs.remove('padlockDateTime');
    prefs.remove('padlockStatus');
    prefs.remove("padlockDuration");
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
          height: MediaQuery.of(context).size.height * .1,
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
      if (codeFieldController.text.length < 9) {
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
                if (_current == "0:00") {
                  setState(() {
                    validateContainer = false;
                  });

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
                      BluetoothCharacteristic timeCharacteristic = service
                          .characteristics
                          .where((c) =>
                              c.uuid
                                  .toString()
                                  .toUpperCase()
                                  .substring(4, 8)
                                  .indexOf('2103') !=
                              -1)
                          .toList()
                          .first;
                      closeAlert(loadingContext);
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                StatefulBuilder(builder: (context, setState) {
                                  return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
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
                                          validateContainer
                                              ? Container(
                                                  height: 29,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                          height: 30,
                                                          child: Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                          )),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        child: Text(
                                                          textError,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(),
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
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      loadingContext = context;
                                                      return LoadingAlertDismissible();
                                                    });
                                                await characteristic.write(
                                                    utf8.encode(
                                                        codeFieldController.text
                                                            .toUpperCase()));

                                                int _dur =
                                                    (await timeCharacteristic
                                                            .read())[0] *
                                                        10;

                                                _duration =
                                                    Duration(seconds: _dur);

                                                int lockedStatus =
                                                    (await unlockedCharacteristic
                                                        .read())[0];
                                                codeFieldController.text = '';

                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();

                                                closeAlert(loadingContext);
                                                print(lockedStatus);
                                                setState(() {
                                                  switch (lockedStatus) {
                                                    case 0:
                                                      print('case 0');
                                                      validateContainer = true;
                                                      textError =
                                                          'Codigo incorrecto';
                                                      break;
                                                    case 1:
                                                      setState(() {
                                                        padlockStatus = "open";
                                                      });

                                                      print(
                                                          "Escrito en shared");

                                                      var now =
                                                          new DateTime.now();

                                                      prefs.setString(
                                                          'padlockName',
                                                          widget.result.device
                                                              .name);
                                                      prefs.setString(
                                                          'padlockDateTime',
                                                          now.toIso8601String());
                                                      prefs.setString(
                                                          'padlockStatus',
                                                          padlockStatus);
                                                      prefs.setInt(
                                                          "padlockDuration",
                                                          _duration.inSeconds);

                                                      validateContainer = false;
                                                      textError = '';
                                                      startTimer(
                                                          _duration.inSeconds);
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
                                                                  Radius
                                                                      .circular(
                                                                          5),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  'Codigo correcto'),
                                                              content: Container(
                                                                  child: Text(
                                                                      'El candado permanecera abierto durante ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5)),
                                                                  ),
                                                                  color: Color(
                                                                      0xffff5f00),
                                                                  child: Text(
                                                                    "Aceptar",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  onPressed:
                                                                      () {
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
                                                    case 3:
                                                      print('Case 3');
                                                      setState(() {
                                                        padlockStatus =
                                                            "locked";
                                                      });

                                                      var now =
                                                          new DateTime.now();

                                                      prefs.setString(
                                                          'padlockName',
                                                          widget.result.device
                                                              .name);
                                                      prefs.setString(
                                                          'padlockDateTime',
                                                          now.toIso8601String());
                                                      prefs.setString(
                                                          'padlockStatus',
                                                          padlockStatus);
                                                      prefs.setInt(
                                                          "padlockDuration",
                                                          _duration.inSeconds);

                                                      startTimer(
                                                          _duration.inSeconds);
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
                                                                  Radius
                                                                      .circular(
                                                                          5),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                  'Candado bloqueado'),
                                                              content: Container(
                                                                  child: Text(
                                                                      'Vuelva a intentar en ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5)),
                                                                  ),
                                                                  color: Color(
                                                                      0xffff5f00),
                                                                  child: Text(
                                                                    "Aceptar",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          });
                                                      break;
                                                    case 4:
                                                      print('case 4');
                                                      validateContainer = true;
                                                      textError =
                                                          'Codigo no reusable';
                                                      break;
                                                  }
                                                }); //
                                              },
                                              child: Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
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
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ));
                                }),
                              ],
                            );
                          }).then((data) {
                        widget.result.device.disconnect();
                      });
                    });
                  });
                } else if (padlockStatus == "open") {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            title: Text('Candado abierto'),
                            content: Container(
                                child:
                                    Text('El candado se cerrará en $_current')),
                            actions: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                color: Color(0xffff5f00),
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                      });
                } else if (padlockStatus == "locked") {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            title: Text('Candado bloqueado'),
                            content:
                                Container(child: Text('Intentar en $_current')),
                            actions: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                color: Color(0xffff5f00),
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                      });
                }
              },
              splashColor: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              child: Container(
                decoration: BoxDecoration(
                    color: padlockStatus == 'open'
                        ? Color(0xff14CC67)
                        : padlockStatus == 'locked'
                            ? Color(0xff718093)
                            : Color(0xff081f2d),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                height: 50,
                child: Center(
                  child: Text(
                    _current != '0:00'
                        ? padlockStatus == "open"
                            ? "Cerrará en $_current"
                            : "Intentar en $_current"
                        : 'Desbloquear',
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
    widget.result.device.disconnect();
    if (timer != null) timer.cancel();
    super.dispose();
  }
}
