import 'package:easy_localization/easy_localization.dart';

extension DateTimeFormatter on DateTime {
  String formatRelativeDateTime({bool isUpdated = false}) {
    final now = DateTime.now();
    final difference = now.difference(this);
    String text = '';

    if (difference.inDays < 1) {
      text = 'dateTimeFormat'.tr(gender: 'today');
    } else if (difference.inDays < 2) {
      text = 'dateTimeFormat'.tr(gender: 'yesterday');
    } else if (difference.inDays < 7) {
      text = 'dateTimeFormat'
          .tr(gender: 'daysAgo', args: ['${difference.inDays}']);
    } else if (difference.inDays < 14) {
      text = 'dateTimeFormat'.tr(gender: 'oneWeekAgo');
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      text = 'dateTimeFormat'.tr(gender: 'weeksAgo', args: ['$weeks']);
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      text = 'dateTimeFormat'.tr(gender: 'monthsAgo', args: ['$months']);
    } else {
      final years = (difference.inDays / 365).floor();
      text = 'dateTimeFormat'.tr(gender: 'yearsAgo', args: ['$years']);
    }

    if (isUpdated) text = 'updated $text';

    return text;
  }
}
