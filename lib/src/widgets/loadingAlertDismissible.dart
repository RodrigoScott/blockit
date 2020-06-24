import 'package:flutter/material.dart';

class LoadingAlertDismissible extends StatefulWidget {
  String text;
  LoadingAlertDismissible(this.text);
  @override
  _LoadingAlertDismissibleState createState() =>
      _LoadingAlertDismissibleState();
}

class _LoadingAlertDismissibleState extends State<LoadingAlertDismissible> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          SizedBox(width: size.width * 0.02),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: new Text('${widget.text}'),
          ),
        ],
      ),
    );
  }
}
