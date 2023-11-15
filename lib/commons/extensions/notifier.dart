import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';


extension NotifierExtension on BuildContext {
  SnackBar _createSnackBar(bool error, {String? text}) {
    return SnackBar(
      content: Text(
        text == null && error ? 'unknownError'.tr() : text!,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
      backgroundColor: error ? KColors.red : KColors.orange,
    );
  }

  void showError({String? error}) async {
    ScaffoldMessenger.of(this).showSnackBar(
      _createSnackBar(true, text: error),
    );
  }

  void showInfo({required String text}) async {
    ScaffoldMessenger.of(this).showSnackBar(
      _createSnackBar(false, text: text),
    );
  }
}
