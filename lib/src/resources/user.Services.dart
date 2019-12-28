import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/main.dart';
import 'package:trailock/src/model/user.dart';
import 'package:trailock/src/utils/Enviroment.dart';

class UserService {
  var dio = Dio();
  validateStatus() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');
    var url = '${Environment.config.base_url_api}validation';
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer $token"
    };
    Response response;
    try{
      response =
      await dio.post(url, options: Options(headers: _headers));
      return response;
    }
    on DioError catch (e) {
      return e.response;
    }
  }

  changePassword(String oldPassword, String newPassword,String confirmNewPassword) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token');
    var url = '${Environment.config.base_url_api}password/change';
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer $token"
    };
    var _data = {
      "old_password": "$oldPassword",
      "new_password": "$newPassword",
      "new_password_confirmation": "$confirmNewPassword"
    };
    Response response;
    try{
      response =
      await dio.post(url, options: Options(headers: _headers), data: _data);
        return response;
    }
    on DioError catch (e) {
      return e.response;
    }
  }
  Future<List<User>> getUser() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer $token",
    };
    Response response = await dio.get(
        '${Environment.config.base_url_api}posts',
        options: Options(headers: _headers));
    if (response.statusCode == 200) {
      var data =
      (response.data as List).map((data) => User.fromJson(data)).toList();

      return data;
    } else {
      return List();
    }
  }
  requestLogin(String email, String password) async {
    var url = '${Environment.config.base_url_api}login';
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
    };
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
      response =
          await dio.post(url, options: Options(headers: _headers), data: _data);
      if (response.statusCode == 200) {
        prefs.setString('access_token', response.data['access_token']);
        prefs.setString('userName', response.data['name']);
        prefs.setString('lastName', response.data['first_last_name']);
        prefs.setString('secondLastName', response.data['second_last_name']);
        prefs.setString('userEmail', response.data['email']);
        prefs.setString('carrier', response.data['company_name']);
        return response;
      }
    } on DioError catch (e) {
      return e.response;
    }
  }

  requestRecoverPass(String email) async {
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest"
    };
    var url = '${Environment.config.base_url_api}password/reset';
    var recoverData = {"email": "$email"};
    Response response;
    try {
      response = await dio.post(url,
          data: recoverData, options: Options(headers: _headers));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }
}
