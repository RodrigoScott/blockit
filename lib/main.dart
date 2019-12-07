import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailock/src/ui/Configuration/changePasswordPage.dart';
import 'package:trailock/src/ui/auth/recoverPasswordPage.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/ui/Configuration/termnsAndConditions.dart';
import 'package:trailock/src/ui/homePage.dart';
import 'package:trailock/src/ui/Configuration/profilePage.dart';

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
        'TerminosyC': (BuildContext context) => TermnsAndConditions(),
        'Profile': (BuildContext context) => ProfilePage(),
        'ChangePassword': (BuildContext context) => ChangePasswordPage(),
      },
    );
  }
}
