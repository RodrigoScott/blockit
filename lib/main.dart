import 'package:flutter/material.dart';
import 'package:trailock/src/ui/auth/recoverPasswordPage.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/ui/auth/termnsAndConditions.dart';
import 'package:trailock/src/ui/homePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peliculas',
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => SignIn(),
        'HomePage': (BuildContext context) => HomePage(),
        'RecoverPass': (BuildContext context) => RecoverPasswordPage(),
        'TerminosyC': (BuildContext context) => TermnsAndConditions()
      },
    );
  }
}
