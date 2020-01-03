import 'package:flutter/material.dart';
import 'package:trailock/src/resources/user.Services.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:trailock/src/widgets/loadingAlertDismissible.dart';

class RecoverPasswordPage extends StatefulWidget {
  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  var _emailController = TextEditingController();
  var loadingContext;
  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
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
              height: MediaQuery.of(context).size.height * .07,
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
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  cursorColor: Colors.black,
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
              height: MediaQuery.of(context).size.height * .05,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .9,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  if (_emailController.text == '') {
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
                              child: Text('Ingrese un email'),
                            ),
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
                          return LoadingAlertDismissible();
                        });
                    Environment().checkInternetConnection().then((res) {
                      if (res == true) {
                        UserService()
                            .requestRecoverPass(_emailController.text)
                            .then((res) {
                          if (res.statusCode == 200) {
                            closeAlert(loadingContext);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    title: Text('Envidado'),
                                    content: Container(
                                        child: Text(
                                            'Se ha enviado un correo a la dirección ingresada')),
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
                          } else {
                            closeAlert(loadingContext);
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
                                            'Correo electronico erroneo, intentelo de nuevo ')),
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

                    //Navigator.pushNamed(context, 'HomePage');
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
                        'Recuperar Contraseña',
                        style: TextStyle(fontSize: 20, color: Colors.white),
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
