class Environment {
  String client_secret = "4OzBihD7fqLKmt3egqoZKcZ7BuetAG9G9cFLwzaS";
  String client_id = "2";
  String base_url = 'http://cceo.io:8134';
  String base_url_api = 'http://cceo.io:8134/api';
  String host = 'http://cceo.io:8134';

  static final Environment _config = new Environment._internal();

  factory Environment() {
    return _config;
  }

  static Environment get config => _config;

  Environment._internal();
}
