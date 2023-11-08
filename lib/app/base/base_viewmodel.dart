import 'package:flutter/material.dart';

enum ViewState { idle, busy }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }
}
