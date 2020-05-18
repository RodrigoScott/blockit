import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/utils/dioConfiguration.dart';
import 'package:trailock/src/utils/enviroment.dart';

class UserService {
  Dio dio = new DioConfiguration().createDio();

  validateStatus() async {
    var url = '${Environment.config.base_url_api}validation';

    Response response;
    try {
      response = await dio.post(url,
          options: Options(headers: {"requirestoken": true}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    var url = '${Environment.config.base_url_api}password/change';
    var _data = {
      "old_password": "$oldPassword",
      "new_password": "$newPassword",
      "new_password_confirmation": "$confirmNewPassword"
    };
    Response response;
    try {
      response = await dio.post(url,
          options: Options(headers: {"requirestoken": true}), data: _data);
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  requestLogin(String email, String password) async {
    var url = '${Environment.config.base_url_api}login';
    var _data = {
      "grant_type": "password",
      "scope": "*",
      "client_id": "2",
      "client_secret": "${Environment.config.client_secret}",
      "username": "$email",
      "password": "$password"
    };

    var prefs = await SharedPreferences.getInstance();
    Response response;
    try {
      response = await dio
          .post(url,
              options: Options(headers: {"requirestoken": false}), data: _data)
          .timeout(Duration(seconds: 15), onTimeout: () {
        return null;
      });
      if (response == null) {
        return null;
      } else {
        if (response.statusCode == 200) {
          prefs.setString('access_token', response.data['access_token']);
          prefs.setString('userName', response.data['name']);
          prefs.setString('lastName', response.data['first_last_name']);
          prefs.setString('secondLastName', response.data['second_last_name']);
          prefs.setString('userEmail', response.data['email']);
          prefs.setString('carrier', response.data['company_name']);

          return response;
        }
      }
    } on DioError catch (e) {
      return e.response;
    }
  }

  requestRecoverPass(String email) async {
    var url = '${Environment.config.base_url_api}password/reset';
    var recoverData = {"email": "$email"};
    Response response;
    try {
      response = await dio.post(url,
          data: recoverData,
          options: Options(headers: {"requirestoken": false}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }
}
