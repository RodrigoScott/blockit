import 'package:flutter/material.dart';
import 'package:trailock/src/ui/auth/recoverPasswordPage.dart';
import 'package:trailock/src/ui/auth/signIn.dart';
import 'package:trailock/src/ui/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/ui/configuration/changePasswordPage.dart';
import 'src/ui/configuration/configurationPage.dart';
import 'src/ui/configuration/profilePage.dart';

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
      'Profile': (BuildContext context) => ProfilePage(),
      'ChangePassword': (BuildContext context) => ChangePasswordPage(),
      'ConfigurationPage': (BuildContext context) => ConfigurationPage(),
    },
  ));
}
