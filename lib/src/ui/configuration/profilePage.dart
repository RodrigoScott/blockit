import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _nameController = TextEditingController();
  var _emailController = TextEditingController();
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Perfil"),
          centerTitle: true,
          backgroundColor: Color(0xff00558A),
        ),
        body: Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black38),
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
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Nombre',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * .07,
                            width: MediaQuery.of(context).size.width * .9,
                            child: TextField(
                              controller: _nameController,
                              enabled: false,
                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 17),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Color(0xff888888),
                                ),
                                filled: true,
                                fillColor: Color(0xffe3e3e3),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .05,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Correo Electronico',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * .07,
                            width: MediaQuery.of(context).size.width * .9,
                            child: TextField(
                              controller: _emailController,
                              enabled: false,
                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 17),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: Color(0xff888888),
                                ),
                                filled: true,
                                fillColor: Color(0xffe3e3e3),
                                contentPadding: EdgeInsets.all(8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
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

  Future getshared() async {
    var prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    List<String> nameSplit = name.split(' ');

    setState(() {
      userName = '${nameSplit[0]}';
      lastName = '${nameSplit[1]}';
      carrier = 'Administrador';
      userEmail = prefs.getString('email');
      carrier = 'Administrador';
      _nameController.text = '$userName $lastName';
      _emailController.text = userEmail;
    });
  }
}
