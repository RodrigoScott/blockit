import 'package:dio/dio.dart';
import 'package:trailock/src/model/iotDeviceModel.dart';
import '../utils/dioConfiguration.dart';

class DeviceService {
  var dio = Dio();
  Dio _dio = new DioConfiguration().createDio();

  getDevice() async {
    try {
      Response response = await _dio.get('/all/devices',
          options: Options(headers: {'requirestoken': false}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = IotDeviceModel.fromJson(response.data);
        return data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      print(e);
      return e.response;
    }
  }
}
