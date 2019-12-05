import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File _imageAvatar;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Column(
          children: <Widget>[
            CircleAvatar(
                radius: 75,
                backgroundColor: Colors.deepOrangeAccent,
                child: InkWell(
                  onTap: () {},
                  child: ClipOval(
                    child: _imageAvatar == null
                        ? Container()
                        : Image.file(
                            _imageAvatar,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                )),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .7,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nombre',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .7,
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        ),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .7,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tipo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .7,
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        ),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .7,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Correo Electronico',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .7,
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        ),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .7,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contraseña',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .7,
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        ),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  width: MediaQuery.of(context).size.width * .7,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Domicilio',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * .07,
                    width: MediaQuery.of(context).size.width * .7,
                    child: TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
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
                        ),
                      ),
                    )),
              ],
            ),
          ),
        )
      ],
    );
  }

  styleText(String data, content) {
    return RichText(
      text:
          TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
        TextSpan(
            text: '${data}:  ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: '${content}')
      ]),
    );
  }
}
