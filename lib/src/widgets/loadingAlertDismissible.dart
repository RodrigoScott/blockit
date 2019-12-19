import 'package:flutter/material.dart';

class LoadingAlertDismissible extends StatefulWidget {
  @override
  _LoadingAlertDismissibleState createState() =>
      _LoadingAlertDismissibleState();
}

class _LoadingAlertDismissibleState extends State<LoadingAlertDismissible> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text("Cargando..."),
          ),
        ],
      ),
    );
  }
}
