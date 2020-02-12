import 'dart:convert';

import 'package:trailock/src/model/location.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  var dio = Dio();

  set(String latitude, String longitude, String name) async {
    var prefs = await SharedPreferences.getInstance();
    var url = '${Environment.config.base_url_api}zones';
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer ${prefs.getString('access_token')}",
    };

    Uri uri = new Uri();

    Response response;
    try {
      uri = Uri.http('${Environment().host}', 'api/v1/zones', {
        "lat": "$latitude",
        "lng": "$longitude",
        "padlock_name": '${int.parse(name.substring(3))}'
      });

      response = await dio.getUri(uri, options: Options(headers: _headers));

      if (response.statusCode == 200) {
        return response;
      }
    } on DioError catch (e) {
      return e.response;
    }
  }
}
