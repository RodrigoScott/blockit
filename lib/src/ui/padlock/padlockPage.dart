import 'package:flutter/material.dart';

class PadlockPage extends StatefulWidget {
  @override
  _PadlockPageState createState() => _PadlockPageState();
}

class _PadlockPageState extends State<PadlockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Card(
              elevation: 4.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        color: Colors.deepOrangeAccent,
                        height: 80,
                        width: MediaQuery.of(context).size.width * .4,
                      ),
                      Container(
                        color: Colors.deepPurpleAccent,
                        height: 20,
                        // width: MediaQuery.of(context).size.width * .5,
                      ),
                    ],
                  ),
                  Container(
                    color: Color(0xff081f2d),
                    height: 50,
                    child: Center(
                      child: Text(
                        'Desbloquear',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
