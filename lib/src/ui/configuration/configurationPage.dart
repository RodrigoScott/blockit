import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/controller/codesController.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  String userName;
  String name;
  String lastName;
  String secondLastName;
  String userEmail;
  String carrier;
  void initState() {
    super.initState();
    setState(() {
      getshared();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Configuración"),
          centerTitle: true,
          backgroundColor: Color(0xff00558A),
        ),
        body: Container(
          color: Colors.transparent,
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .05,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .45,
                    child: Center(
                      child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Color(0xff00558A),
                          child: InkWell(
                            onTap: () {},
                            child: ClipOval(
                                child: Container(
                              child: Text(
                                userName == null
                                    ? ''
                                    : '${userName.substring(0, 1)}${lastName.substring(0, 1)}',
                                style: TextStyle(
                                    fontSize: 55, color: Colors.white),
                              ),
                            )),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .05,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .40,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userName == null ? '' : '$userName $lastName',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            carrier == null ? '' : carrier,
                            style:
                                TextStyle(fontSize: 13, color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .02,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .05,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mi cuenta',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .01,
                  ),
                  options(
                      Icon(Icons.account_circle), Text('Perfil'), 'Profile'),
                  SizedBox(
                    height: 5,
                  ),
                  options(Icon(Icons.lock), Text('Cambiar Contraseña'),
                      'ChangePassword'),
                  SizedBox(
                    height: 5,
                  ),
                  options(Icon(Icons.label_outline), Text('Cerrar Sesión'),
                      'log-out'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .05,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget options(Icon icon, Text title, String route) {
    return Container(
      color: Colors.black12,
      child: ListTile(
        onTap: route != 'log-out'
            ? () {
                route == 'TerminosyC'
                    ? launch('http://trailock.mx/terminos-y-condiciones')
                    : Navigator.pushNamed(context, '$route');
              }
            : () {
                showDialog(
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
                            child: Text('¿Seguro que desea cerrar sesión? ')),
                        actions: <Widget>[
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            color: Colors.white,
                            child: Text(
                              "Cancelar",
                              style: TextStyle(color: Color(0xff00558A)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            color: Color(0xff00558A),
                            child: Text(
                              "Aceptar",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              var r = await CodesController().deleteTable();
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('access_token');
                              prefs.clear();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => SingIn()),
                                  (Route<dynamic> route) => false);
                            },
                          )
                        ],
                      );
                    });
              },
        dense: true,
        leading: icon,
        title: title,
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Future getshared() async {
    var prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    List<String> nameSplit = name.split(' ');

    print('${nameSplit[0]}');
    setState(() {
      userName = '${nameSplit[0]}';
      lastName = '${nameSplit[1]}';
      carrier = 'Administrador';
    });
  }
}
