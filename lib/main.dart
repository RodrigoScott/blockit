import 'package:flutter/material.dart';
import 'package:trailock/src/ui/Configuration/changePasswordPage.dart';
import 'package:trailock/src/ui/auth/recoverPasswordPage.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/ui/Configuration/termnsAndConditions.dart';
import 'package:trailock/src/ui/homePage.dart';
import 'package:trailock/src/ui/Configuration/profilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

var token = '';
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString('access_token');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Trailock',
    initialRoute: (token == null || token == '') ? '/' : 'HomePage',
    routes: {
      '/': (BuildContext context) => SignIn(),
      'HomePage': (BuildContext context) => HomePage(),
      'RecoverPass': (BuildContext context) => RecoverPasswordPage(),
      'TerminosyC': (BuildContext context) => TermnsAndConditions(),
      'Profile': (BuildContext context) => ProfilePage(),
      'ChangePassword': (BuildContext context) => ChangePasswordPage(),
    },
  ));
}
