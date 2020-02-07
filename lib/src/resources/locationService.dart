import 'package:trailock/src/model/location.dart';
import 'package:trailock/src/utils/enviroment.dart';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  var dio = Dio();


  set(String latitude, String longitude, String name) async {
    var url = '${Environment.config.base_url_api}location';
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
    };
    var _data = {
      "latitude": "$latitude",
      "longitude": "$longitude",
      "deviceName":"$name"
    };

    var prefs = await SharedPreferences.getInstance();
    Response response;
    try {
      response =
      await dio.post(url, options: Options(headers: _headers), data: _data);
      if (response.statusCode == 200) {
        prefs.setString('code', response.data['code.Master']);
        return response;
      }
    } on DioError catch (e) {
      return e.response;
    }
  }
}