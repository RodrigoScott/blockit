import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/controller/codesController.dart';
import 'package:trailock/src/model/versionAppModel.dart';
import 'package:trailock/src/resources/user.Services.dart';
import 'package:trailock/src/resources/version.Services.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/ui/configuration/configurationPage.dart';
import 'package:trailock/src/ui/padlock/padlockPage.dart';

class HomePage extends StatefulWidget {
  int indexPage;

  @override
  HomePage({Key key, this.indexPage}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pageOptions = [PadlockPage(), ConfigurationPage()];

  @override
  void initState() {
    setState(() {
      VersionService().getVersion().then((res) {
        VersionAppModel version = new VersionAppModel();
        res != null
            ? UserService().validateStatus().then((r) {
                version = VersionAppModel.fromJson(res.data);
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
                            content:
                                Container(child: Text('Tu sesión a caducado')),
                            actions: <Widget>[
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
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => SingIn()),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            ],
                          );
                        })
                    : null;
              })
            : null;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Color(0xff00558A),
        currentIndex: widget.indexPage == 1 ? widget.indexPage : _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) async {
          setState(() {
            _selectedIndex = index;
          });
        },
        iconSize: 30,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.airport_shuttle, color: Color(0xff00558A)),
              icon: Icon(Icons.airport_shuttle),
              title: Text('Puertas')),
          BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.settings,
                color: Color(0xff00558A),
              ),
              icon: Icon(Icons.settings),
              title: Text(
                'Configuración',
              )),
        ],
      ),
      body: Center(
        child: _pageOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
