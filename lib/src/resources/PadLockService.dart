import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/model/codeModel.dart';
import 'package:trailock/src/utils/enviroment.dart';

class PadLockService {
  var dio = Dio();

  status(String code, int name, int source) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer ${prefs.getString('access_token')}",
    };
    var url = '${Environment.config.base_url_api}codes/status';
    var recoverData = {"code": code, "padlock_name": name, "source": source};
    Response response;
    try {
      response = await dio.post(url,
          data: recoverData, options: Options(headers: _headers));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  listPadLock(List<CodeModel> listCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _headers = {
      "accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "Authorization": "Bearer ${prefs.getString('access_token')}",
    };
    var url = '${Environment.config.base_url_api}codes/list/status';
    var recoverData = {"codes": listCode};
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
