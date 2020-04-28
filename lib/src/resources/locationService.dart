import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/utils/enviroment.dart';

class LocationService {
  var dio = Dio();

  set(String latitude, String longitude, String name, String zone) async {
    var prefs = await SharedPreferences.getInstance();
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer ${prefs.getString('access_token')}",
    };

    Uri uri = new Uri();

    Response response;
    try {
      uri = Uri.http('${Environment().host}', 'api/v1/zones', {
        "lat": latitude,
        "lng": longitude,
        "padlock_name": name.substring(3),
        "time_zone": zone
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
