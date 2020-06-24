class Environment {
  String version = '1.1.0';
  bool validateNEtwork;
  String client_secret = "1MY6EDcF1d5MhkoBNuqNJ7vgcpBSn9kqOOFZZdUI";
  String client_id = "2";
  String base_url = 'http://cceo.io:8134';
  String base_url_api = 'http://cceo.io:8134/api';
  String host = 'http://cceo.io:8134';

  /*String client_secret = "z89SUkG51B1bXXPGOlgCtIk66YJr4R83tBbIIn69";
  String client_id = "2";
  String base_url = 'http://trailock.mx/';
  String base_url_api = 'http://cceo.io:8109/api/v1/';
  String host = 'cceo.io:8109';*/

  static final Environment _config = new Environment._internal();

  factory Environment() {
    return _config;
  }

  static Environment get config => _config;

  Environment._internal();
}
