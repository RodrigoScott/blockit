import 'package:flutter/material.dart';
import 'package:trailock/src/resources/user.Services.dart';
import 'package:trailock/src/resources/version.Services.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:trailock/src/widgets/loadingAlertDismissible.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  var _formNewOldPassword = GlobalKey<FormState>();
  var _formNewPassword = GlobalKey<FormState>();
  var _formConfirmNewPassword = GlobalKey<FormState>();

  var _oldPasswordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  var _confirmNewPasswordController = TextEditingController();
  var loadingContext;

  closeAlert(BuildContext _context) {
    Navigator.of(_context).pop();
  }

  void initState() {
    _oldPasswordController.addListener(() {
      setState(() {
        _formNewOldPassword.currentState.validate();
      });
    });
    _newPasswordController.addListener(() {
      setState(() {
        _formNewPassword.currentState.validate();
      });
    });
    _confirmNewPasswordController.addListener(() {
      setState(() {
        _formConfirmNewPassword.currentState.validate();
      });
    });
    super.initState();
  }

  @override
  Widget createInput(
    TextEditingController controller,
    Function _valida,
  ) {
    return Container(
        width: MediaQuery.of(context).size.width * .9,
        child: TextFormField(
          obscureText: true,
          validator: _valida,
          controller: controller,
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
        ));
  }

  Widget build(BuildContext context) {
    Widget _newPassword = createInput(_newPasswordController, (value) {
      if (_newPasswordController.text.length < 8) {
        return ('Favor de ingresar minimo 8 caracteres');
      }
    });
    Widget _confirmNewPassword =
        createInput(_confirmNewPasswordController, (value) {
      if (_confirmNewPasswordController.text.length == 0 ||
          _confirmNewPasswordController.text != _newPasswordController.text) {
        return ('Contraseña nueva no coincide');
      }
    });

    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                'App Versión: ${Environment().version}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              'Cambiar Contraseña',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .2,
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),
              Container(
                height: MediaQuery.of(context).size.height * .05,
                width: MediaQuery.of(context).size.width * .9,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Antigua Contraseña',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: Form(
                    key: _formNewOldPassword,
                    child: TextFormField(
                      obscureText: true,
                      controller: _oldPasswordController,
                      cursorColor: Color(0xffff5f00),
                      style: TextStyle(fontSize: 20),
                      validator: (value) {
                        if (_oldPasswordController.text.length == 0) {
                          return ('Favor de ingresar minimo 8 caracteres');
                        }
                      },
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
                  'Nueva Contraseña',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: _formNewPassword,
                child: _newPassword,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .02,
              ),
              Container(
                height: MediaQuery.of(context).size.height * .05,
                width: MediaQuery.of(context).size.width * .9,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Repite Nueva Contraseña',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: _formConfirmNewPassword,
                child: _confirmNewPassword,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              Container(
                height: MediaQuery.of(context).size.height * .07,
                width: MediaQuery.of(context).size.width * .9,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    VersionService().getVersion().then((res) {
                      if (res != null) {
                        if (_formNewPassword.currentState.validate() &&
                            _formNewOldPassword.currentState.validate() &&
                            _formConfirmNewPassword.currentState.validate()) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                loadingContext = context;
                                return LoadingAlertDismissible(
                                    content: 'Cambiando contraseña');
                              });
                          UserService()
                              .changePassword(
                                  _oldPasswordController.text,
                                  _newPasswordController.text,
                                  _confirmNewPasswordController.text)
                              .then((res) {
                            if (res.statusCode == 200) {
                              _oldPasswordController.text = '';
                              _newPasswordController.text = '';
                              _confirmNewPasswordController.text = '';
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
                                      title: Text('Hecho'),
                                      content: Container(
                                          child:
                                              Text('Contraseña restablecida')),
                                      actions: <Widget>[
                                        FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          color: Color(0xffff5f00),
                                          child: Text(
                                            "Aceptar",
                                            style:
                                                TextStyle(color: Colors.white),
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
                                              'Contraseña actual incorrecta')),
                                      actions: <Widget>[
                                        FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          color: Color(0xffff5f00),
                                          child: Text(
                                            "Aceptar",
                                            style:
                                                TextStyle(color: Colors.white),
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
                          'Guardar',
                          style: TextStyle(fontSize: 25, color: Colors.white),
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
            ],
          ),
        ],
      ),
    );
    ;
  }
}
