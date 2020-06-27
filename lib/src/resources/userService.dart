import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dioConfiguration.dart';
import '../utils/enviroment.dart';

class IotUserService {
  var dio = Dio();
  Dio _dio = new DioConfiguration().createDio();

  requestLogin(String email, String password) async {
    var _data = {
      "grant_type": "password",
      "scope": "*",
      "client_id": "2",
      "client_secret": "${Environment.config.client_secret}",
      "username": "$email",
      "password": "$password"
    };

    var prefs = await SharedPreferences.getInstance();

    try {
      Response response = await _dio.post('/login',
          options: Options(headers: {'requirestoken': false}), data: _data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        prefs.setString('access_token', response.data['access_token']);
        prefs.setString('name', response.data['name']);
        prefs.setString('email', response.data['email']);

        return response;
      }
    } on DioError catch (e) {
      print(e);
      return e.response;
    }
  }

  changePassword(String oldPassword, String newPassword,
      String newPasswordConfirmation) async {
    var prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    print(email);
    var _data = {
      "old_password": "$oldPassword",
      "new_password": "$newPassword",
      "new_password_confirmation": "$newPasswordConfirmation",
      "email": "$email",
    };

    try {
      Response response = await _dio.post('/password/change',
          data: _data, options: Options(headers: {'requierestoken': false}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        return response;
      }
    } on DioError catch (e) {
      print(e.message);
      return e.response;
    }
  }

  deviceStatus(String name) async {
    var recoverData = {"name": "$name"};
    try {
      Response response = await _dio.put('/status/device',
          data: recoverData,
          options: Options(headers: {'requierestoken': false}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  requestRecoverPass(String email) async {
    var recoverData = {"email": "$email"};
    try {
      Response response = await _dio.post('/password/reset',
          data: recoverData,
          options: Options(headers: {'requierestoken': false}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  requestPinCode(String email, int pin) async {
    var recoverData = {"email": "$email", 'number': '$pin'};

    try {
      Response response = await _dio.post('/password/code',
          data: recoverData,
          options: Options(headers: {'requierestoken': false}));
      print(response.statusCode);
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }
}
