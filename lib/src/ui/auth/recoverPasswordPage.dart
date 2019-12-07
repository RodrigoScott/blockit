import 'package:flutter/material.dart';

class RecoverPasswordPage extends StatefulWidget {
  @override
  _RecoverPasswordPageState createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              height: MediaQuery.of(context).size.height * .35,
              child: Image.asset("assets/icon.png"),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .07,
          ),
          Container(
            height: MediaQuery.of(context).size.height * .05,
            width: MediaQuery.of(context).size.width * .9,
            alignment: Alignment.centerLeft,
            child: Text(
              'Correo Electónico',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .9,
              child: TextField(
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 20),
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
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * .05,
          ),
          Container(
            height: MediaQuery.of(context).size.height * .07,
            width: MediaQuery.of(context).size.width * .9,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                // Navigator.pushNamed(context, 'HomePage');
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
                      'Recuperar Contraseña',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
