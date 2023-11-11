import 'package:blogman/app/base/base_viewmodel.dart';
import 'package:flutter/material.dart';

class AppBarViewModel extends BaseViewModel {

  // SearchBar
  final tSearch = TextEditingController();
  final searchFocus = FocusNode();
  bool searchEnabled = false;

  void cancelSearch() {
    tSearch.clear();
    searchEnabled = false;
    notifyListeners();
  }

  void enableSearch() {
    searchEnabled = true;
    notifyListeners();
    searchFocus.requestFocus();
  }
}
