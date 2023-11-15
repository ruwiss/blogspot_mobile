import 'package:blogman/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

extension ContextExtensions on BuildContext {
  void previewImage(String url) {
    showDialog(
      context: this,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: TapRegion(
          onTapOutside: (event) => context.pop(),
          child: Center(
            child: InteractiveViewer(
              maxScale: 3.0,
              minScale: 0.5,
              boundaryMargin:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // [flutter_datetime_picker_plus] paketiyle diyalog çağırıp datetime alıyoruz.
  void showDateTimePicker({Function(DateTime dateTime)? onConfirm}) async {
    final minTime = DateTime.now();
    final maxTime = DateTime.now().add(const Duration(days: 365));
    DatePicker.showDateTimePicker(
      this,
      showTitleActions: true,
      minTime: minTime,
      maxTime: maxTime,
      currentTime: DateTime.now(),
      locale: LocaleType.values.singleWhere(
          (e) => e.name == Localizations.localeOf(this).toString(),
          orElse: () => LocaleType.en),
      onConfirm: onConfirm,
    );
  }
}
