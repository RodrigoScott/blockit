import 'dart:io';

class Environment {
  String client_secret = "SoSbXp1xrqPMD4cZVlD5Of8jaId7sIw94hZNjmwG";
  String client_id = "2";
  String base_url = 'http://cceo.io:8109/';
  String base_url_api = 'http://cceo.io:8109/api/v1/';

  static final Environment _config = new Environment._internal();

  factory Environment() {
    return _config;
  }

  static Environment get config => _config;

  Environment._internal();

  Future<bool> checkInternetConnection() async {
    try {
      var result = await InternetAddress.lookup('https://google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        result = null;
        return true;
      }
    } on SocketException catch (e) {
      return false;
    }
    return false;
  }
}
