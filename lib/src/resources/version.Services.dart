import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/model/versionAppModel.dart';
import 'package:trailock/src/utils/enviroment.dart';

class VersionService {
  var dio = Dio();

  getVersion() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token');
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer $token"
    };
    try {
      Response response = await dio
          .get('${Environment.config.base_url_api}version',
              options: Options(headers: _headers))
          .timeout(Duration(seconds: 5), onTimeout: () {
        return null;
      });
      if (response == null) {
        return null;
      } else {
        if (response.statusCode == 200) {
          var data = VersionAppModel.fromJson(response.data);
          return data;
        }
      }
    } on DioError catch (e) {
      print(e.response);

      return e.response;
    }
  }
}
