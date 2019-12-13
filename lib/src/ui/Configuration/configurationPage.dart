import 'package:flutter/material.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.transparent,
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              'Perfil',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
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
                      backgroundColor: Color(0xffff5f00),
                      child: InkWell(
                        onTap: () {},
                        child: ClipOval(
                            child: Container(
                          child: Text(
                            'FL',
                            style: TextStyle(fontSize: 55, color: Colors.white),
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
                        'Fernando Leal',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tres Guerras',
                        style: TextStyle(fontSize: 13, color: Colors.black38),
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),
              options(Icon(Icons.account_circle), Text('Perfil'), 'Profile'),
              SizedBox(
                height: 5,
              ),
              options(Icon(Icons.lock), Text('Cambiar Contraseña'),
                  'ChangePassword'),
              SizedBox(
                height: 5,
              ),
              options(Icon(Icons.label_outline), Text('Cerrar Sesión'), ''),
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),
              Container(
                height: MediaQuery.of(context).size.height * .05,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Información',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              options(Icon(Icons.info_outline), Text('Terminos y Condiciones'),
                  'TerminosyC'),
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
        onTap: () {
          Navigator.pushNamed(context, '$route');
        },
        dense: true,
        leading: icon,
        title: title,
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
