import 'package:dio/dio.dart';
import 'package:trailock/src/model/codeModel.dart';
import 'package:trailock/src/utils/dioConfiguration.dart';
import 'package:trailock/src/utils/enviroment.dart';

class PadLockService {
  Dio dio = new DioConfiguration().createDio();

  status(String code, int name, int source) async {
    var url = '${Environment.config.base_url_api}codes/status';
    var recoverData = {"code": code, "padlock_name": name, "source": source};
    Response response;
    try {
      response = await dio.post(url,
          data: recoverData,
          options: Options(headers: {"requirestoken": true}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }

  listPadLock(List<CodeModel> listCode) async {
    var url = '${Environment.config.base_url_api}codes/list/status';
    var recoverData = {"codes": listCode};
    Response response;
    try {
      response = await dio.post(url,
          data: recoverData,
          options: Options(headers: {"requirestoken": true}));
      return response;
    } on DioError catch (e) {
      return e.response;
    }
  }
}
