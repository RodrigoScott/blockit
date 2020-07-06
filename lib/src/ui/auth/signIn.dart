import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trailock/src/resources/userService.dart';

import '../../widgets/loadingAlertDismissible.dart';
import '../homePage.dart';

//0xff00558a

class SingIn extends StatefulWidget {
  @override
  _SingInState createState() => _SingInState();
}

var _formSignInKey = GlobalKey<FormState>();
var _formPasswordKey = GlobalKey<FormState>();
var _formEmailKey = GlobalKey<FormState>();

var _emailController = TextEditingController();
var _passwordController = TextEditingController();

bool ok = true;

var loadingContext;

class _SingInState extends State<SingIn> {
  void initState() {
    _emailController.addListener(() {
      if (this.mounted) {
        setState(() {
          _formEmailKey.currentState.validate();
        });
      }
    });

    _passwordController.addListener(() {
      if (this.mounted) {
        setState(() {
          _formPasswordKey.currentState.validate();
        });
      }
    });

    _emailController.clear();
    _passwordController.clear();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    Widget createButton(Function _onPress, String _text, double _width,
        double _height, double _fontSize) {
      return ButtonTheme(
          height: _height,
          minWidth: MediaQuery.of(context).size.width * 0.5,
          child: RaisedButton(
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(color: Color(0xff00558a), width: 3)),
            onPressed: _onPress,
            color: Color(0xff00558a),
            child: Text('$_text',
                style: TextStyle(color: Colors.white, fontSize: _fontSize)),
          ));
    }

    Widget createInput(String _label, TextEditingController _controller,
        bool isPassword, Function _validator) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: size.width * .7,
            child: TextFormField(
                cursorColor: Colors.grey,
                keyboardType: TextInputType.text,
                controller: _controller,
                validator: _validator,
                obscureText: isPassword,
                decoration: InputDecoration(
                  hintText: _label,
                  //labelText: _label,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 18)),
          ),
        ],
      );
    }

    void _submit(BuildContext context) async {
      _formPasswordKey.currentState.validate();
      _formEmailKey.currentState.validate();
      if (_formEmailKey.currentState.validate() &&
          _formPasswordKey.currentState.validate()) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              loadingContext = context;
              return LoadingAlertDismissible('Cargando...');
            });
        IotUserService()
            .requestLogin(_emailController.text, _passwordController.text)
            .then((res) {
          Navigator.of(context).pop();
          if (res == null) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    title: Text("Error de conexión"),
                    content: Text(
                        "Conecte su dispositivo a una red e intentelo de nuevo"),
                    actions: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        color: Color(0xff00558a),
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
            //if (ok) {
            if (res.statusCode == 200) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      title: Text("Intente otra vez"),
                      content: Text("Usuario o contraseña incorrectos"),
                      actions: <Widget>[
                        FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          color: Color(0xff00558a),
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
          }
        });
      }
    }

    final inputEmail = createInput(
        "Correo electronico",
        _emailController,
        false,
        (value) =>
            _emailController.text.length == 0 ? ('Ingrese su correo') : null);
    final inputPassword = createInput(
        "Contraseña",
        _passwordController,
        true,
        (value) => _passwordController.text.length == 0
            ? ('Ingrese su contraseña')
            : null);

    final bttnSignIn = createButton(() {
      _submit(context);
    }, "Ingresar", MediaQuery.of(context).size.width / 2.5, 40, 18);

    return Scaffold(
        backgroundColor: Colors.white, //Color(0xffe9a9aa),
        body: SingleChildScrollView(
          child: Container(
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                Image.asset(
                  'assets/logo.png',
                  scale: size.width * .02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                Container(
                  width: size.width * .8,
                  //color: Colors.grey,
                  child: AutoSizeText(
                    'Inicio de Sesión',
                    style: TextStyle(fontSize: 30, color: Colors.black54),
                    textAlign: TextAlign.left,
                    minFontSize: 20,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: size.width,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .02,
                      ),
                      Form(
                        key: _formEmailKey,
                        child: inputEmail,
                      ),
                      Form(
                        key: _formPasswordKey,
                        child: inputPassword,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .03,
                      ),
                      Container(
                        width: size.width * .7,
                        child: InkWell(
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            onTap:
                                () {} /* => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => recoveryPassword())),*/
                            ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .03,
                      ),
                      Container(
                        child: bttnSignIn,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .03,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
