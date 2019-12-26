import 'package:flutter/material.dart';
import 'package:trailock/src/blocs/validatePadlock_bloc.dart';

class Provider extends InheritedWidget {
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}

final validateBloc = ValidatePadlockBloc();
