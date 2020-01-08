import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:trailock/src/resources/user.Services.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:trailock/src/widgets/loadingAlertDismissible.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var loadingContext;
  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
  }

  var _emailController = TextEditingController();
  bool connectionInternet = false;
  var _passwordController = TextEditingController();
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .6,
                height: MediaQuery.of(context).size.height * .35,
                child: Image.asset("assets/logoTrailock.png"),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .01,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .05,
              width: MediaQuery.of(context).size.width * .9,
              alignment: Alignment.centerLeft,
              child: Text(
                'Correo Electónico',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * .07,
                width: MediaQuery.of(context).size.width * .9,
                child: TextField(
                  textCapitalization: TextCapitalization.none,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  cursorColor: Color(0xffff5f00),
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xff888888),
                    ),
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
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * .02,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .05,
              width: MediaQuery.of(context).size.width * .9,
              alignment: Alignment.centerLeft,
              child: Text(
                'Contraseña',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * .07,
                width: MediaQuery.of(context).size.width * .9,
                child: TextField(
                  enableInteractiveSelection: false,
                  obscureText: true,
                  controller: _passwordController,
                  cursorColor: Color(0xffff5f00),
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xff888888),
                    ),
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
                    ),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .9,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  if (_emailController.text == '' ||
                      _passwordController.text == '') {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            title: Text('Error'),
                            content: Container(
                                child: _emailController.text == ''
                                    ? Text(' Ingrese un email')
                                    : Text('Ingrese una contraseña')),
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
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          loadingContext = context;
                          return LoadingAlertDismissible(
                              content: 'Iniciando sesión');
                        });
                    Environment().checkInternetConnection().then((res) {
                      if (res == true) {
                        UserService()
                            .requestLogin(
                                _emailController.text, _passwordController.text)
                            .then((res) {
                          closeAlert(loadingContext);
                          if (res.statusCode == 200) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                'HomePage', (Route<dynamic> route) => false);
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    title: Text('Error'),
                                    content: Container(
                                        child: Text(
                                            'Correo electronico o contraseña erroneos, intentelo de nuevo ')),
                                    actions: <Widget>[
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
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
                          }
                        });
                      } else {
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
                                title: Text('Error'),
                                content: Container(
                                    child: Text('Sin conexion a internet')),
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
                      }
                    });
                  }
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0xffff5f00),
                    ),
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .9,
                    child: Center(
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .01,
            ),
            Container(
              width: MediaQuery.of(context).size.width * .9,
              child: InkWell(
                focusColor: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.pushNamed(context, 'RecoverPass');
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      //border: Border.all(width: 3),
                      color: Colors.transparent,
                    ),
                    width: MediaQuery.of(context).size.width * .9,
                    height: 40,
                    child: Center(
                      child: Text(
                        'Olvide mi contraseña',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            ),
            Container(
              width: MediaQuery.of(context).size.width * .9,
              child: InkWell(
                focusColor: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  launch('http://trailock.mx/terminos-y-condiciones');
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.transparent,
                    ),
                    width: MediaQuery.of(context).size.width * .9,
                    height: 40,
                    child: Center(
                      child: Text(
                        'Terminos y condiciones',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
