import 'dart:io';

class Environment {
  String client_secret =
      "qTsnFd6IJPVQbZdUVvy7uBX5lM57M5M5wGlMR9i6"; //"BX26jpPthhlPJgAjuTxgXom368r6yDmnUMJlvnYQ";
  String client_id = "2";
  String base_url = 'https://c24172b9.ngrok.io/'; //'http://cceo.io:8109/';
  String base_url_api =
      'https://c24172b9.ngrok.io/api/v1/'; //'http://cceo.io:8109/api/v1/';

  static final Environment _config = new Environment._internal();

  factory Environment() {
    return _config;
  }

  static Environment get config => _config;

  Environment._internal();

  Future<bool> checkInternetConnection() async {
    try {
      var result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        result = null;
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
