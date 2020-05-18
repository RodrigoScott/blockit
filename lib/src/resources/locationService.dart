import 'package:dio/dio.dart';
import 'package:trailock/src/utils/dioConfiguration.dart';
import 'package:trailock/src/utils/enviroment.dart';

class LocationService {
  Dio dio = new DioConfiguration().createDio();

  set(String latitude, String longitude, String name, String zone) async {
    Uri uri = new Uri();

    Response response;
    try {
      uri = Uri.http('${Environment().host}', 'api/v1/zones', {
        "lat": latitude,
        "lng": longitude,
        "padlock_name": name.substring(3),
        "time_zone": zone
      });
      response = await dio.getUri(uri,
          options: Options(headers: {"requirestoken": true}));
      if (response.statusCode == 200) {
        return response;
      }
    } on DioError catch (e) {
      return e.response;
    }
  }
}
