import 'package:connectivity/connectivity.dart';
import 'package:trailock/src/resources/version.Services.dart';

class Environment {
  bool  validateNEtwork;
  String client_secret = "tc507xfyD6Y0FkOOvnLMDpl4TAoE2J0zug5hvHPX";
  String client_id = "2";
  String base_url = 'http://trailock.mx/';
  String base_url_api = 'http://trailock.mx/api/v1/';
  String host = 'trailock.mx';

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
