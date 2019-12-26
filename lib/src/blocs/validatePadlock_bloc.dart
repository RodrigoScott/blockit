import 'dart:async';

class ValidatePadlockBloc {}

final _validatePadlockController = StreamController<String>.broadcast();
Stream<String> get _validateStream => _validatePadlockController.stream;

Function(String) get changeValidatePadlock =>
    _validatePadlockController.sink.add;

dispose() {
  _validatePadlockController?.close();
}
