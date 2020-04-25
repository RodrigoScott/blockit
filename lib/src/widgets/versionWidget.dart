import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class VersionWidget {
  Future version(String version, var context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            title: Text('Actualizar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    child: Text(
                        'Existe una versión mas reciente de la app de Trailock, actualiza antes de continuar')),
                SizedBox(
                  height: 5,
                ),
                Container(child: Text('Nueva actualización: $version')),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                color: Colors.white,
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Color(0xffff5f00)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                color: Color(0xffff5f00),
                child: Text(
                  "Actualizar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  LaunchReview.launch(
                      androidAppId: 'mx.trailock.app', iOSAppId: '1500656114');
                },
              ),
            ],
          );
        });
  }
}
