import 'package:flutter/material.dart';

enum ViewState { idle, busy }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  Map states = {};

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  bool isActiveState(key) => states.containsKey(key);
  dynamic getStateValue(state) => states[state];

  void addState(key, [value]) {
    states[key] = value;
    notifyListeners();
  }

  void deleteState(key) {
    states.remove(key);
    notifyListeners();
  }
}
