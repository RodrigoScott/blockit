import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailock/src/utils/enviroment.dart';

class DioConfiguration {
  Dio createDio() {
    return addInterceptors(Dio(BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
        baseUrl: Environment.config.base_url_api)));
  }

  Dio addInterceptors(Dio dio) {
    return dio
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) => requestInterceptor(options),
        /*onResponse: (Response response) => responseInterceptor(response),
          onError: (DioError dioError) => errorInterceptor(dioError)*/
      ));
  }

  dynamic requestInterceptor(RequestOptions options) async {
    if (options.headers.containsKey("requirestoken")) {
      //remove the auxiliary header
      options.headers.remove("requirestoken");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString("access_token");

      options.headers.addAll({"authorization": "Bearer $accessToken"});
    }

    options.headers.addAll({"Content-Type": "application/json"});
    options.headers.addAll({"Accept": "application/json"});
    options.headers.addAll({"X-Requested-With": "XMLHttpRequest"});

    return options;
  }

  dynamic responseInterceptor(Response options) async {
    if (options.headers.value("verifyToken") != null) {
      //if the header is present, then compare it with the Shared Prefs key
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var verifyToken = prefs.get("VerifyToken");

      // if the value is the same as the header, continue with the request
      if (options.headers.value("verifyToken") == verifyToken) {
        return options;
      }
    }

    return DioError(
        request: options.request, error: options.request.data.errors);
  }

  dynamic errorInterceptor(DioError dioError) {
    if (dioError.message.contains("ERROR_001")) {
      // this will push a new route and remove all the routes that were present
      /*navigatorKey.currentState.pushNamedAndRemoveUntil(
          "/login", (Route<dynamic> route) => false);*/
    }

    return dioError;
  }
}
