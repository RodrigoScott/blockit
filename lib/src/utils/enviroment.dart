import 'package:connectivity/connectivity.dart';

class Environment {
  /*String client_secret = "tc507xfyD6Y0FkOOvnLMDpl4TAoE2J0zug5hvHPX";
  String client_id = "2";
  String base_url = 'http://trailock.mx/';
  String base_url_api = 'http://trailock.mx/api/v1/';*/

  String client_secret = "E1RQJPtwks5MH9M40MxM6lI5YCKbKMBmepocIBv0";
  String client_id = "2";
  String base_url = 'http://trailock.mx/';
  String base_url_api = 'http://cceo.io:8109/api/v1/';
  String host = 'cceo.io:8109';

  static final Environment _config = new Environment._internal();

  factory Environment() {
    return _config;
  }

  static Environment get config => _config;

  Environment._internal();
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
