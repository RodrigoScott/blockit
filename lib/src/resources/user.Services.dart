import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/utils/Enviroment.dart';

class UserService {
  var dio = Dio();

  requestLogin(String email, String password) async {
    var url = '${Environment.config.base_url}oauth/token';
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
    var url = '${Environment.config.base_url_api}password/email';
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
