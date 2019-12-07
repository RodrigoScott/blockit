import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailock/src/ui/Configuration/configurationPage.dart';
import 'package:trailock/src/ui/padlock/padlockPage.dart';
import 'package:trailock/src/ui/Configuration/profilePage.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Color(0xffff5f00),
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
              activeIcon:
                  Icon(Icons.airport_shuttle, color: Colors.deepOrangeAccent),
              icon: Icon(Icons.airport_shuttle),
              title: Text('Candados')),
          BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.settings,
                color: Colors.deepOrangeAccent,
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
