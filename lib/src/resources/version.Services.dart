import 'package:dio/dio.dart';
import 'package:trailock/src/utils/dioConfiguration.dart';
import 'package:trailock/src/utils/enviroment.dart';

class VersionService {
  Dio dio = new DioConfiguration().createDio();
  getVersion() async {
    try {
      Response response = await dio
          .get('${Environment.config.base_url_api}version',
              options: Options(headers: {"requirestoken": true}))
          .timeout(Duration(seconds: 5), onTimeout: () {
        return null;
      });
      if (response == null) {
        return null;
      } else {
        if (response.statusCode == 200) {
          return response;
        }
      }
    } on DioError catch (e) {
      return e.response;
    }
  }
}
