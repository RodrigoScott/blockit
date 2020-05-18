import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/controller/codesController.dart';
import 'package:trailock/src/model/codeModel.dart';
import 'package:trailock/src/model/device.dart';
import 'package:trailock/src/model/location.dart';
import 'package:trailock/src/resources/PadLockService.dart';
import 'package:trailock/src/resources/locationService.dart';
import 'package:trailock/src/resources/version.Services.dart';
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
  String _geoHash = "";
  String _coordinates = "";
  StreamSubscription _getPositionSubscription;
  Position currentLocation;
  SharedPreferences prefs;
  List<Device> devices;
  LocationModel location = new LocationModel();
  bool validateContainer = false;
  bool validateBotton = false;
  bool validateBattery = false;
  bool timeOut = false;
  bool validateUseContainer = false;
  String textError = '';
  String _current = '0:00';
  String padlockStatus = "ready";
  Duration _durationTimeOpen;
  DateTime timeNow = DateTime.now();
  String zone;
  Duration _durationTimeLocked;
  bool check = false;
  String lat, lng;
  var loadingContext;
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 5);

  StreamSubscription<CountdownTimer> timer;

  formattedTimeZoneOffset(DateTime time) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final duration = time.timeZoneOffset,
        hours = duration.inHours,
        minutes = duration.inMinutes.remainder(60).abs().toInt();

    setState(() {
      zone = '${hours > 0 ? '+' : '-'}${twoDigits(hours.abs())}';
    });
  }

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
            removeFromSharedPreferences();
          });
  }

  @override
  void initState() {
    formattedTimeZoneOffset(timeNow);
    _checkConection();
    _getLocation();
    if (widget.dateTime != null) {
      var started = DateTime.parse(widget.dateTime);
      var rest =
          widget.remaining - DateTime.now().difference(started).inSeconds;

      if (rest > 0) {
        startTimer(rest);
        padlockStatus = widget.status;
      } else
        removeFromSharedPreferences();
    }

    codeFieldController.addListener(() {
      setState(() {
        _validateField.currentState.validate();
      });
    });
    super.initState();
  }

  Future<void> removeFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      padlockStatus = "ready";
    });

    List<Device> devices = prefs.getStringList("padlocks") != null
        ? prefs
            .getStringList("padlocks")
            .map((device) => Device.fromJson(jsonDecode(device)))
            .toList()
        : List<Device>();

    devices.removeWhere((device) => device.name == widget.result.device.name);

    prefs.setStringList("padlocks",
        devices.map((device) => jsonEncode(device.toJson())).toList());
  }

  @override
  Widget build(BuildContext context) {
    Widget createInput(
      TextEditingController controller,
      Function _valida,
    ) {
      return Container(
          height: MediaQuery.of(context).size.height * .1,
          width: MediaQuery.of(context).size.width * .9,
          child: Theme(
            data: ThemeData(
              primaryColor: Color(0xffff5f00),
              primaryColorDark: Color(0xffff5f00),
            ),
            child: TextFormField(
              validator: _valida,
              obscureText: false,
              keyboardType: TextInputType.visiblePassword,
              maxLength: 9,
              controller: controller,
              cursorColor: Color(0xffff5f00),
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                errorStyle: TextStyle(color: Color(0xffff5f00)),
                filled: true,
                fillColor: Color(0xffe3e3e3),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.transparent)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.transparent)),
              ),
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
                      "assets/icons/iconiOS.png",
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
              onTap: () async {
                setState(() {
                  timeOut = false;
                  codeFieldController.text = '';
                });
                widget.result.device.disconnect();
                if (_current == '0:00') {
                  alertText('Verificando Internet');
                  await VersionService().getVersion().then((res) async {
                    Navigator.of(context).pop();
                    alertText('Conectando Bluetooth');
                    await widget.result.device
                        .connect(autoConnect: false)
                        .timeout(Duration(seconds: 10), onTimeout: () {
                      widget.result.device.disconnect();
                      setState(() {
                        timeOut = true;
                      });
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          timeInSecForIos: 10,
                          msg: "Tiempo de espera agotado. Intenta de nuevo");
                      Duration(seconds: 10);
                    });
                    if (timeOut != true) {
                      Navigator.of(context).pop();
                      if (res != null) {
                        alertText('Verificando localización');
                        await _getLocation().timeout(Duration(seconds: 30),
                            onTimeout: () {
                          Navigator.of(context).pop();
                          alertText('Imposible obtener ubicación');
                          Duration(seconds: 5);
                          widget.result.device.disconnect();
                          lng = lat = '0';
                        });
                        LocationService()
                            .set(lat, lng, widget.result.device.name, zone)
                            .then((res) async {
                          if (res.statusCode == 200) {
                            location = LocationModel.fromJson(res.data);
                            if (location.inside) {
                              Navigator.of(context).pop();
                              List<BluetoothService> services =
                                  await widget.result.device.discoverServices();

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
                              BluetoothCharacteristic unlockedCharacteristic =
                                  service.characteristics
                                      .where((c) =>
                                          c.uuid
                                              .toString()
                                              .toUpperCase()
                                              .substring(4, 8)
                                              .indexOf('2102') !=
                                          -1)
                                      .toList()
                                      .first;
                              BluetoothCharacteristic openTimeCharacteristic =
                                  service.characteristics
                                      .where((c) =>
                                          c.uuid
                                              .toString()
                                              .toUpperCase()
                                              .substring(4, 8)
                                              .indexOf('2103') !=
                                          -1)
                                      .toList()
                                      .first;
                              BluetoothCharacteristic lowBatteryCharacteristic =
                                  service.characteristics
                                      .where((c) =>
                                          c.uuid
                                              .toString()
                                              .toUpperCase()
                                              .substring(4, 8)
                                              .indexOf('2104') !=
                                          -1)
                                      .toList()
                                      .first;
                              BluetoothCharacteristic lockedTimeCharacteristic =
                                  service.characteristics
                                      .where((c) =>
                                          c.uuid
                                              .toString()
                                              .toUpperCase()
                                              .substring(4, 8)
                                              .indexOf('2105') !=
                                          -1)
                                      .toList()
                                      .first;
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    loadingContext = context;
                                    return LoadingAlertDismissible(
                                        content: 'Verificando Geocerca');
                                  });
                              await characteristic
                                  .write(utf8.encode(location.code));
                              int _durTimeOpen =
                                  (await openTimeCharacteristic.read())[0] * 10;
                              _durationTimeOpen =
                                  Duration(seconds: _durTimeOpen);

                              int _durTimeLocked =
                                  (await lockedTimeCharacteristic.read())[0] *
                                      10;

                              _durationTimeLocked =
                                  Duration(seconds: _durTimeLocked);

                              int lowBattery =
                                  (await lowBatteryCharacteristic.read())[0];

                              if (lowBattery == 1) {
                                setState(() {
                                  validateBattery = true;
                                });
                              }

                              int lockedStatus =
                                  (await unlockedCharacteristic.read())[0];

                              final prefs =
                                  await SharedPreferences.getInstance();

                              FocusScope.of(context).requestFocus(FocusNode());

                              List<Device> devicesList = prefs
                                          .getStringList("padlocks") !=
                                      null
                                  ? prefs
                                      .getStringList("padlocks")
                                      .map((device) =>
                                          Device.fromJson(jsonDecode(device)))
                                      .toList()
                                  : List<Device>();

                              setState(() {
                                switch (lockedStatus) {
                                  case 0:
                                    validateContainer = true;
                                    textError = 'Código incorrecto';
                                    setState(() {
                                      codeFieldController.text =
                                          location.master;
                                    });
                                    break;
                                  case 1:
                                    setState(() {
                                      padlockStatus = "open";
                                    });
                                    var now = new DateTime.now();

                                    Device device = Device(
                                        name: widget.result.device.name,
                                        datetime: now.toIso8601String(),
                                        duration: _durationTimeOpen.inSeconds,
                                        status: padlockStatus);

                                    devicesList.add(device);

                                    prefs.setStringList(
                                        "padlocks",
                                        devicesList
                                            .map((device) =>
                                                jsonEncode(device.toJson()))
                                            .toList());

                                    validateContainer = false;
                                    textError = '';
                                    startTimer(_durationTimeOpen.inSeconds);
                                    Navigator.pop(context);
                                    PadLockService().status(
                                        codeFieldController.text,
                                        int.parse(widget.result.device.name
                                            .substring(3)),
                                        2);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            title: Text('Abierto por Geocerca'),
                                            content: Container(
                                                child: Text(
                                                    'El candado permanecera abierto durante ${_durationTimeOpen.inMinutes}:${(_durationTimeOpen.inSeconds % 60).toString().padLeft(2, '0')}')),
                                            actions: <Widget>[
                                              FlatButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                                color: Color(0xffff5f00),
                                                child: Text(
                                                  "Aceptar",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                    break;
                                  case 2:
                                    validateContainer = true;
                                    textError = 'El candado está abierto';
                                    break;
                                  case 3:
                                    setState(() {
                                      padlockStatus = "locked";
                                    });

                                    var now = new DateTime.now();

                                    Device device = Device(
                                        name: widget.result.device.name,
                                        datetime: now.toIso8601String(),
                                        duration: _durationTimeLocked.inSeconds,
                                        status: padlockStatus);

                                    devicesList.add(device);

                                    prefs.setStringList(
                                        "padlocks",
                                        devicesList
                                            .map((device) =>
                                                jsonEncode(device.toJson()))
                                            .toList());

                                    startTimer(_durationTimeLocked.inSeconds);
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            title: Text('Candado bloqueado'),
                                            content: Container(
                                                child: Text(
                                                    'Vuelva a intentar en ${_durationTimeLocked.inMinutes}:${(_durationTimeLocked.inSeconds % 60).toString().padLeft(2, '0')}')),
                                            actions: <Widget>[
                                              FlatButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                                color: Color(0xffff5f00),
                                                child: Text(
                                                  "Aceptar",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          );
                                        });
                                    break;
                                  case 4:
                                    validateContainer = true;
                                    textError = 'Código ya utilizado';
                                    break;
                                }
                                lockedStatus = null;
                                codeFieldController.text = '';
                              }); //

                            } else {
                              setState(() {
                                codeFieldController.text = location.code;
                              });
                              Navigator.of(context).pop();
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              content: Column(
                                                children: <Widget>[
                                                  Text('Candado',
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      widget.result.device.name,
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Container(
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
                                                              Icons
                                                                  .not_interested,
                                                              color: Color(
                                                                  0xffff5f00),
                                                            )),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          height: 20,
                                                          child: Text(
                                                              'Fuera de Geocerca',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffff5f00),
                                                              )),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  validateBattery
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
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Container(
                                                                  height: 30,
                                                                  child: Icon(
                                                                    Icons
                                                                        .battery_alert,
                                                                    color: Color(
                                                                        0xffff5f00),
                                                                  )),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Container(
                                                                height: 20,
                                                                child: Text(
                                                                    'Candado sin batería',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xffff5f00),
                                                                    )),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
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
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Container(
                                                                  height: 30,
                                                                  child: Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red,
                                                                  )),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Container(
                                                                height: 20,
                                                                child: Text(
                                                                  textError,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .05,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .9,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Código',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .07,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .9,
                                                    child: Form(
                                                        key: _validateField,
                                                        child: _inputValidate),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .05,
                                                  ),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .07,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .9,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      onTap: () async {
                                                        List<BluetoothService>
                                                            services =
                                                            await widget
                                                                .result.device
                                                                .discoverServices();

                                                        BluetoothService service = services
                                                            .where((s) =>
                                                                s.uuid
                                                                    .toString()
                                                                    .toUpperCase()
                                                                    .substring(
                                                                        4, 8)
                                                                    .indexOf(
                                                                        '1101') !=
                                                                -1)
                                                            .toList()
                                                            .first;

                                                        BluetoothCharacteristic
                                                            characteristic =
                                                            service
                                                                .characteristics
                                                                .where((c) =>
                                                                    c.uuid
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .substring(
                                                                            4,
                                                                            8)
                                                                        .indexOf(
                                                                            '2101') !=
                                                                    -1)
                                                                .toList()
                                                                .first;
                                                        BluetoothCharacteristic
                                                            unlockedCharacteristic =
                                                            service
                                                                .characteristics
                                                                .where((c) =>
                                                                    c.uuid
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .substring(
                                                                            4,
                                                                            8)
                                                                        .indexOf(
                                                                            '2102') !=
                                                                    -1)
                                                                .toList()
                                                                .first;
                                                        BluetoothCharacteristic
                                                            openTimeCharacteristic =
                                                            service
                                                                .characteristics
                                                                .where((c) =>
                                                                    c.uuid
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .substring(
                                                                            4,
                                                                            8)
                                                                        .indexOf(
                                                                            '2103') !=
                                                                    -1)
                                                                .toList()
                                                                .first;
                                                        BluetoothCharacteristic
                                                            lowBatteryCharacteristic =
                                                            service
                                                                .characteristics
                                                                .where((c) =>
                                                                    c.uuid
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .substring(
                                                                            4,
                                                                            8)
                                                                        .indexOf(
                                                                            '2104') !=
                                                                    -1)
                                                                .toList()
                                                                .first;
                                                        BluetoothCharacteristic
                                                            lockedTimeCharacteristic =
                                                            service
                                                                .characteristics
                                                                .where((c) =>
                                                                    c.uuid
                                                                        .toString()
                                                                        .toUpperCase()
                                                                        .substring(
                                                                            4,
                                                                            8)
                                                                        .indexOf(
                                                                            '2105') !=
                                                                    -1)
                                                                .toList()
                                                                .first;
                                                        if (_validateField
                                                            .currentState
                                                            .validate()) {
                                                          showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                loadingContext =
                                                                    context;
                                                                return LoadingAlertDismissible(
                                                                    content:
                                                                        'Verificando Codigo');
                                                              });
                                                          await characteristic
                                                              .write(utf8.encode(
                                                                  codeFieldController
                                                                      .text
                                                                      .toUpperCase()));

                                                          int _durTimeOpen =
                                                              (await openTimeCharacteristic
                                                                      .read())[0] *
                                                                  10;
                                                          _durationTimeOpen =
                                                              Duration(
                                                                  seconds:
                                                                      _durTimeOpen);

                                                          int _durTimeLocked =
                                                              (await lockedTimeCharacteristic
                                                                      .read())[0] *
                                                                  10;

                                                          _durationTimeLocked =
                                                              Duration(
                                                                  seconds:
                                                                      _durTimeLocked);

                                                          int lowBattery =
                                                              (await lowBatteryCharacteristic
                                                                  .read())[0];

                                                          if (lowBattery == 1) {
                                                            setState(() {
                                                              validateBattery =
                                                                  true;
                                                            });
                                                          }

                                                          int lockedStatus =
                                                              (await unlockedCharacteristic
                                                                  .read())[0];

                                                          final prefs =
                                                              await SharedPreferences
                                                                  .getInstance();

                                                          Navigator.pop(
                                                              context);
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  FocusNode());

                                                          List<
                                                              Device> devicesList = prefs
                                                                      .getStringList(
                                                                          "padlocks") !=
                                                                  null
                                                              ? prefs
                                                                  .getStringList(
                                                                      "padlocks")
                                                                  .map((device) =>
                                                                      Device.fromJson(
                                                                          jsonDecode(
                                                                              device)))
                                                                  .toList()
                                                              : List<Device>();
                                                          setState(() {
                                                            switch (
                                                                lockedStatus) {
                                                              case 0:
                                                                setState(() {
                                                                  validateContainer =
                                                                      true;
                                                                  textError =
                                                                      'Código incorrecto';
                                                                  if (location
                                                                          .code !=
                                                                      '' /*&& validateBattery==true*/) {
                                                                    codeFieldController
                                                                            .text =
                                                                        location
                                                                            .master;
                                                                  }
                                                                });

                                                                break;
                                                              case 1:
                                                                setState(() {
                                                                  padlockStatus =
                                                                      "open";
                                                                });
                                                                var now =
                                                                    new DateTime
                                                                        .now();

                                                                Device device = Device(
                                                                    name: widget
                                                                        .result
                                                                        .device
                                                                        .name,
                                                                    datetime: now
                                                                        .toIso8601String(),
                                                                    duration:
                                                                        _durationTimeOpen
                                                                            .inSeconds,
                                                                    status:
                                                                        padlockStatus);

                                                                devicesList.add(
                                                                    device);

                                                                prefs.setStringList(
                                                                    "padlocks",
                                                                    devicesList
                                                                        .map((device) =>
                                                                            jsonEncode(device.toJson()))
                                                                        .toList());

                                                                validateContainer =
                                                                    false;
                                                                textError = '';
                                                                startTimer(
                                                                    _durationTimeOpen
                                                                        .inSeconds);
                                                                Navigator.pop(
                                                                    context);
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(
                                                                            Radius.circular(5),
                                                                          ),
                                                                        ),
                                                                        title: Text(
                                                                            'Código correcto'),
                                                                        content:
                                                                            Container(child: Text('El candado permanecera abierto durante ${_durationTimeOpen.inMinutes}:${(_durationTimeOpen.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                        actions: <
                                                                            Widget>[
                                                                          FlatButton(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            color:
                                                                                Color(0xffff5f00),
                                                                            child:
                                                                                Text(
                                                                              "Aceptar",
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          )
                                                                        ],
                                                                      );
                                                                    });
                                                                PadLockService().status(
                                                                    codeFieldController
                                                                        .text,
                                                                    int.parse(widget
                                                                        .result
                                                                        .device
                                                                        .name
                                                                        .substring(
                                                                            3)),
                                                                    3);
                                                                break;
                                                              case 2:
                                                                validateContainer =
                                                                    true;
                                                                textError =
                                                                    'El candado está abierto';
                                                                break;
                                                              case 3:
                                                                setState(() {
                                                                  padlockStatus =
                                                                      "locked";
                                                                });

                                                                var now =
                                                                    new DateTime
                                                                        .now();

                                                                Device device = Device(
                                                                    name: widget
                                                                        .result
                                                                        .device
                                                                        .name,
                                                                    datetime: now
                                                                        .toIso8601String(),
                                                                    duration:
                                                                        _durationTimeLocked
                                                                            .inSeconds,
                                                                    status:
                                                                        padlockStatus);

                                                                devicesList.add(
                                                                    device);

                                                                prefs.setStringList(
                                                                    "padlocks",
                                                                    devicesList
                                                                        .map((device) =>
                                                                            jsonEncode(device.toJson()))
                                                                        .toList());

                                                                startTimer(
                                                                    _durationTimeLocked
                                                                        .inSeconds);
                                                                Navigator.pop(
                                                                    context);
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(
                                                                            Radius.circular(5),
                                                                          ),
                                                                        ),
                                                                        title: Text(
                                                                            'Candado bloqueado'),
                                                                        content:
                                                                            Container(child: Text('Vuelva a intentar en ${_durationTimeLocked.inMinutes}:${(_durationTimeLocked.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                        actions: <
                                                                            Widget>[
                                                                          FlatButton(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            color:
                                                                                Color(0xffff5f00),
                                                                            child:
                                                                                Text(
                                                                              "Aceptar",
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                          )
                                                                        ],
                                                                      );
                                                                    });
                                                                break;
                                                              case 4:
                                                                validateContainer =
                                                                    true;
                                                                textError =
                                                                    'Código ya utilizado';
                                                                break;
                                                            }
                                                            lockedStatus = null;

                                                            if (validateContainer ==
                                                                    true &&
                                                                location.code !=
                                                                    '') {
                                                              //&& validateBattery == true) {
                                                              codeFieldController
                                                                      .text =
                                                                  location
                                                                      .master;
                                                            } else {
                                                              codeFieldController
                                                                  .text = '';
                                                            }
                                                          }); //
                                                        }
                                                      },
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Color(
                                                                0xffff5f00),
                                                          ),
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .07,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .9,
                                                          child: Center(
                                                            child: Text(
                                                              'Verificar',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                            }
                          } else if (res.statusCode == 404) {
                            setState(() {
                              validateContainer = false;
                            });
                            showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (context) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            content: Column(
                                              children: <Widget>[
                                                Text('Candado',
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(widget.result.device.name,
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                res == null
                                                    ? Container()
                                                    : Container(
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
                                                                  Icons
                                                                      .battery_alert,
                                                                  color: Color(
                                                                      0xffff5f00),
                                                                )),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Container(
                                                              height: 20,
                                                              child: Text(
                                                                  'Sin internet',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffff5f00),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                validateBattery
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
                                                                  Icons
                                                                      .battery_alert,
                                                                  color: Color(
                                                                      0xffff5f00),
                                                                )),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Container(
                                                              height: 20,
                                                              child: Text(
                                                                  'Candado sin batería',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffff5f00),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
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
                                                                  color: Colors
                                                                      .red,
                                                                )),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Container(
                                                              height: 20,
                                                              child: Text(
                                                                textError,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Código',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                        BorderRadius.circular(
                                                            5),
                                                    onTap: () async {
                                                      List<BluetoothService>
                                                          services =
                                                          await widget
                                                              .result.device
                                                              .discoverServices();

                                                      BluetoothService service = services
                                                          .where((s) =>
                                                              s.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '1101') !=
                                                              -1)
                                                          .toList()
                                                          .first;

                                                      BluetoothCharacteristic
                                                          characteristic =
                                                          service
                                                              .characteristics
                                                              .where((c) =>
                                                                  c.uuid
                                                                      .toString()
                                                                      .toUpperCase()
                                                                      .substring(
                                                                          4, 8)
                                                                      .indexOf(
                                                                          '2101') !=
                                                                  -1)
                                                              .toList()
                                                              .first;
                                                      BluetoothCharacteristic
                                                          unlockedCharacteristic =
                                                          service
                                                              .characteristics
                                                              .where((c) =>
                                                                  c.uuid
                                                                      .toString()
                                                                      .toUpperCase()
                                                                      .substring(
                                                                          4, 8)
                                                                      .indexOf(
                                                                          '2102') !=
                                                                  -1)
                                                              .toList()
                                                              .first;
                                                      BluetoothCharacteristic
                                                          openTimeCharacteristic =
                                                          service
                                                              .characteristics
                                                              .where((c) =>
                                                                  c.uuid
                                                                      .toString()
                                                                      .toUpperCase()
                                                                      .substring(
                                                                          4, 8)
                                                                      .indexOf(
                                                                          '2103') !=
                                                                  -1)
                                                              .toList()
                                                              .first;
                                                      BluetoothCharacteristic
                                                          lowBatteryCharacteristic =
                                                          service
                                                              .characteristics
                                                              .where((c) =>
                                                                  c.uuid
                                                                      .toString()
                                                                      .toUpperCase()
                                                                      .substring(
                                                                          4, 8)
                                                                      .indexOf(
                                                                          '2104') !=
                                                                  -1)
                                                              .toList()
                                                              .first;
                                                      BluetoothCharacteristic
                                                          lockedTimeCharacteristic =
                                                          service
                                                              .characteristics
                                                              .where((c) =>
                                                                  c.uuid
                                                                      .toString()
                                                                      .toUpperCase()
                                                                      .substring(
                                                                          4, 8)
                                                                      .indexOf(
                                                                          '2105') !=
                                                                  -1)
                                                              .toList()
                                                              .first;
                                                      if (_validateField
                                                          .currentState
                                                          .validate()) {
                                                        showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              loadingContext =
                                                                  context;
                                                              return LoadingAlertDismissible(
                                                                  content:
                                                                      'Verificando Codigo');
                                                            });
                                                        await characteristic
                                                            .write(utf8.encode(
                                                                codeFieldController
                                                                    .text
                                                                    .toUpperCase()));

                                                        int _durTimeOpen =
                                                            (await openTimeCharacteristic
                                                                    .read())[0] *
                                                                10;
                                                        _durationTimeOpen =
                                                            Duration(
                                                                seconds:
                                                                    _durTimeOpen);

                                                        int _durTimeLocked =
                                                            (await lockedTimeCharacteristic
                                                                    .read())[0] *
                                                                10;

                                                        _durationTimeLocked =
                                                            Duration(
                                                                seconds:
                                                                    _durTimeLocked);

                                                        int lowBattery =
                                                            (await lowBatteryCharacteristic
                                                                .read())[0];

                                                        if (lowBattery == 1) {
                                                          setState(() {
                                                            validateBattery =
                                                                true;
                                                          });
                                                        }

                                                        int lockedStatus =
                                                            (await unlockedCharacteristic
                                                                .read())[0];

                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();

                                                        Navigator.pop(context);
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FocusNode());

                                                        List<
                                                            Device> devicesList = prefs
                                                                    .getStringList(
                                                                        "padlocks") !=
                                                                null
                                                            ? prefs
                                                                .getStringList(
                                                                    "padlocks")
                                                                .map((device) =>
                                                                    Device.fromJson(
                                                                        jsonDecode(
                                                                            device)))
                                                                .toList()
                                                            : List<Device>();

                                                        setState(() {
                                                          switch (
                                                              lockedStatus) {
                                                            case 0:
                                                              setState(() {
                                                                validateContainer =
                                                                    true;
                                                                textError =
                                                                    'Código incorrecto';
                                                              });

                                                              break;
                                                            case 1:
                                                              setState(() {
                                                                padlockStatus =
                                                                    "open";
                                                              });
                                                              var now =
                                                                  new DateTime
                                                                      .now();

                                                              Device device = Device(
                                                                  name: widget
                                                                      .result
                                                                      .device
                                                                      .name,
                                                                  datetime: now
                                                                      .toIso8601String(),
                                                                  duration:
                                                                      _durationTimeOpen
                                                                          .inSeconds,
                                                                  status:
                                                                      padlockStatus);

                                                              devicesList
                                                                  .add(device);

                                                              prefs.setStringList(
                                                                  "padlocks",
                                                                  devicesList
                                                                      .map((device) =>
                                                                          jsonEncode(
                                                                              device.toJson()))
                                                                      .toList());

                                                              validateContainer =
                                                                  false;
                                                              textError = '';
                                                              startTimer(
                                                                  _durationTimeOpen
                                                                      .inSeconds);
                                                              CodeModel padLock = new CodeModel(
                                                                  code:
                                                                      codeFieldController
                                                                          .text,
                                                                  name: widget
                                                                      .result
                                                                      .device
                                                                      .name
                                                                      .substring(
                                                                          3));
                                                              saveCode(padLock);
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                      ),
                                                                      title: Text(
                                                                          'Código correcto'),
                                                                      content: Container(
                                                                          child:
                                                                              Text('El candado permanecera abierto durante ${_durationTimeOpen.inMinutes}:${(_durationTimeOpen.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                      actions: <
                                                                          Widget>[
                                                                        FlatButton(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(5)),
                                                                          ),
                                                                          color:
                                                                              Color(0xffff5f00),
                                                                          child:
                                                                              Text(
                                                                            "Aceptar",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        )
                                                                      ],
                                                                    );
                                                                  });
                                                              break;
                                                            case 2:
                                                              validateContainer =
                                                                  true;
                                                              textError =
                                                                  'El candado está abierto';
                                                              break;
                                                            case 3:
                                                              setState(() {
                                                                padlockStatus =
                                                                    "locked";
                                                              });

                                                              var now =
                                                                  new DateTime
                                                                      .now();

                                                              Device device = Device(
                                                                  name: widget
                                                                      .result
                                                                      .device
                                                                      .name,
                                                                  datetime: now
                                                                      .toIso8601String(),
                                                                  duration:
                                                                      _durationTimeLocked
                                                                          .inSeconds,
                                                                  status:
                                                                      padlockStatus);

                                                              devicesList
                                                                  .add(device);

                                                              prefs.setStringList(
                                                                  "padlocks",
                                                                  devicesList
                                                                      .map((device) =>
                                                                          jsonEncode(
                                                                              device.toJson()))
                                                                      .toList());

                                                              startTimer(
                                                                  _durationTimeLocked
                                                                      .inSeconds);
                                                              Navigator.pop(
                                                                  context);
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(
                                                                              5),
                                                                        ),
                                                                      ),
                                                                      title: Text(
                                                                          'Candado bloqueado'),
                                                                      content: Container(
                                                                          child:
                                                                              Text('Vuelva a intentar en ${_durationTimeLocked.inMinutes}:${(_durationTimeLocked.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                      actions: <
                                                                          Widget>[
                                                                        FlatButton(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(5)),
                                                                          ),
                                                                          color:
                                                                              Color(0xffff5f00),
                                                                          child:
                                                                              Text(
                                                                            "Aceptar",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        )
                                                                      ],
                                                                    );
                                                                  });
                                                              break;
                                                            case 4:
                                                              validateContainer =
                                                                  true;
                                                              textError =
                                                                  'Código ya utilizado';
                                                              break;
                                                          }
                                                          lockedStatus = null;
                                                          codeFieldController
                                                              .text = '';
                                                        }); //
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color:
                                                              Color(0xffff5f00),
                                                        ),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            .07,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .9,
                                                        child: Center(
                                                          child: Text(
                                                            'Verificar',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
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
                          }
                        });
                      } else {
                        setState(() {
                          validateContainer = false;
                        });
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
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(widget.result.device.name,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                              height: 29,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Container(
                                                      height: 30,
                                                      child: Icon(
                                                        Icons.signal_wifi_off,
                                                        color:
                                                            Color(0xffff5f00),
                                                      )),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Container(
                                                    height: 20,
                                                    child: Text('Sin internet',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffff5f00),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                            validateBattery
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
                                                              Icons
                                                                  .battery_alert,
                                                              color: Color(
                                                                  0xffff5f00),
                                                            )),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                          height: 20,
                                                          child: Text(
                                                              'Candado sin batería',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffff5f00),
                                                              )),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
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
                                                'Código',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                  List<BluetoothService>
                                                      services = await widget
                                                          .result.device
                                                          .discoverServices();

                                                  BluetoothService service =
                                                      services
                                                          .where((s) =>
                                                              s.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '1101') !=
                                                              -1)
                                                          .toList()
                                                          .first;

                                                  BluetoothCharacteristic
                                                      characteristic = service
                                                          .characteristics
                                                          .where((c) =>
                                                              c.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '2101') !=
                                                              -1)
                                                          .toList()
                                                          .first;
                                                  BluetoothCharacteristic
                                                      unlockedCharacteristic =
                                                      service.characteristics
                                                          .where((c) =>
                                                              c.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '2102') !=
                                                              -1)
                                                          .toList()
                                                          .first;
                                                  BluetoothCharacteristic
                                                      openTimeCharacteristic =
                                                      service.characteristics
                                                          .where((c) =>
                                                              c.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '2103') !=
                                                              -1)
                                                          .toList()
                                                          .first;
                                                  BluetoothCharacteristic
                                                      lowBatteryCharacteristic =
                                                      service.characteristics
                                                          .where((c) =>
                                                              c.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '2104') !=
                                                              -1)
                                                          .toList()
                                                          .first;
                                                  BluetoothCharacteristic
                                                      lockedTimeCharacteristic =
                                                      service.characteristics
                                                          .where((c) =>
                                                              c.uuid
                                                                  .toString()
                                                                  .toUpperCase()
                                                                  .substring(
                                                                      4, 8)
                                                                  .indexOf(
                                                                      '2105') !=
                                                              -1)
                                                          .toList()
                                                          .first;
                                                  if (_validateField
                                                      .currentState
                                                      .validate()) {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          loadingContext =
                                                              context;
                                                          return LoadingAlertDismissible(
                                                              content:
                                                                  'Verificando Codigo');
                                                        });
                                                    await characteristic.write(
                                                        utf8.encode(
                                                            codeFieldController
                                                                .text
                                                                .toUpperCase()));

                                                    int _durTimeOpen =
                                                        (await openTimeCharacteristic
                                                                .read())[0] *
                                                            10;
                                                    _durationTimeOpen =
                                                        Duration(
                                                            seconds:
                                                                _durTimeOpen);

                                                    int _durTimeLocked =
                                                        (await lockedTimeCharacteristic
                                                                .read())[0] *
                                                            10;

                                                    _durationTimeLocked =
                                                        Duration(
                                                            seconds:
                                                                _durTimeLocked);

                                                    int lowBattery =
                                                        (await lowBatteryCharacteristic
                                                            .read())[0];

                                                    if (lowBattery == 1) {
                                                      setState(() {
                                                        validateBattery = true;
                                                      });
                                                    }

                                                    int lockedStatus =
                                                        (await unlockedCharacteristic
                                                            .read())[0];

                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();

                                                    Navigator.pop(context);
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());

                                                    List<
                                                        Device> devicesList = prefs
                                                                .getStringList(
                                                                    "padlocks") !=
                                                            null
                                                        ? prefs
                                                            .getStringList(
                                                                "padlocks")
                                                            .map((device) =>
                                                                Device.fromJson(
                                                                    jsonDecode(
                                                                        device)))
                                                            .toList()
                                                        : List<Device>();
                                                    setState(() {
                                                      switch (lockedStatus) {
                                                        case 0:
                                                          setState(() {
                                                            validateContainer =
                                                                true;
                                                            textError =
                                                                'Código incorrecto';
                                                          });

                                                          break;
                                                        case 1:
                                                          setState(() {
                                                            padlockStatus =
                                                                "open";
                                                          });
                                                          var now = new DateTime
                                                              .now();
                                                          Device device = Device(
                                                              name: widget
                                                                  .result
                                                                  .device
                                                                  .name,
                                                              datetime: now
                                                                  .toIso8601String(),
                                                              duration:
                                                                  _durationTimeOpen
                                                                      .inSeconds,
                                                              status:
                                                                  padlockStatus);

                                                          devicesList
                                                              .add(device);

                                                          prefs.setStringList(
                                                              "padlocks",
                                                              devicesList
                                                                  .map((device) =>
                                                                      jsonEncode(
                                                                          device
                                                                              .toJson()))
                                                                  .toList());

                                                          validateContainer =
                                                              false;
                                                          textError = '';
                                                          startTimer(
                                                              _durationTimeOpen
                                                                  .inSeconds);
                                                          CodeModel padLock =
                                                              new CodeModel(
                                                                  code:
                                                                      codeFieldController
                                                                          .text,
                                                                  name: widget
                                                                      .result
                                                                      .device
                                                                      .name
                                                                      .substring(
                                                                          3));
                                                          saveCode(padLock);
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
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
                                                                      'Código correcto'),
                                                                  content: Container(
                                                                      child: Text(
                                                                          'El candado permanecera abierto durante ${_durationTimeOpen.inMinutes}:${(_durationTimeOpen.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                  actions: <
                                                                      Widget>[
                                                                    FlatButton(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(5)),
                                                                      ),
                                                                      color: Color(
                                                                          0xffff5f00),
                                                                      child:
                                                                          Text(
                                                                        "Aceptar",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              });

                                                          break;
                                                        case 2:
                                                          validateContainer =
                                                              true;
                                                          textError =
                                                              'El candado está abierto';
                                                          break;
                                                        case 3:
                                                          setState(() {
                                                            padlockStatus =
                                                                "locked";
                                                          });

                                                          var now = new DateTime
                                                              .now();

                                                          Device device = Device(
                                                              name: widget
                                                                  .result
                                                                  .device
                                                                  .name,
                                                              datetime: now
                                                                  .toIso8601String(),
                                                              duration:
                                                                  _durationTimeLocked
                                                                      .inSeconds,
                                                              status:
                                                                  padlockStatus);

                                                          devicesList
                                                              .add(device);

                                                          prefs.setStringList(
                                                              "padlocks",
                                                              devicesList
                                                                  .map((device) =>
                                                                      jsonEncode(
                                                                          device
                                                                              .toJson()))
                                                                  .toList());

                                                          startTimer(
                                                              _durationTimeLocked
                                                                  .inSeconds);
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
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
                                                                          'Vuelva a intentar en ${_durationTimeLocked.inMinutes}:${(_durationTimeLocked.inSeconds % 60).toString().padLeft(2, '0')}')),
                                                                  actions: <
                                                                      Widget>[
                                                                    FlatButton(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(5)),
                                                                      ),
                                                                      color: Color(
                                                                          0xffff5f00),
                                                                      child:
                                                                          Text(
                                                                        "Aceptar",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                          break;
                                                        case 4:
                                                          validateContainer =
                                                              true;
                                                          textError =
                                                              'Código ya utilizado';
                                                          break;
                                                      }
                                                      lockedStatus = null;
                                                      codeFieldController.text =
                                                          '';
                                                    }); //
                                                  }
                                                },
                                                child: Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Color(0xffff5f00),
                                                    ),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .07,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .9,
                                                    child: Center(
                                                      child: Text(
                                                        'Verificar',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.white),
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
                      }
                    }
                  }); //Enviroment().checkIntenrnetConnection

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
                                  Navigator.pop(context);
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
    _getPositionSubscription?.cancel();

    super.dispose();
  }

  Future<bool> _checkConection() async {
    check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    try {
      final result = await InternetAddress.lookup('trailock.mx');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          check = true;
        });
      } else {
        setState(() {
          check = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        check = false;
      });
    }
  }

  _getLocation() async {
    currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      lat = (currentLocation.latitude).toString();
      lng = (currentLocation.longitude).toString();
    });
    _getPositionSubscription = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position position) {
      var newGeoHash =
          Geohash.encode(position.latitude, position.longitude).substring(0, 8);
      if (newGeoHash != _geoHash) {
        setState(() {
          _geoHash = newGeoHash;
          lat = (position.latitude).toString();
          lng = (position.longitude).toString();
        });
      }
      _coordinates = position.toString();
    });
  }

  Future alertText(String text) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          loadingContext = context;
          return LoadingAlertDismissible(content: '$text');
        });
  }

  void saveCode(CodeModel padLock) async {
    var res = await CodesController().save(padLock);
  }
}
