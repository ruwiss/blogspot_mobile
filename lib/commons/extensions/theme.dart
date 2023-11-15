import 'package:flutter/material.dart';

import '../../utils/utils.dart';

extension ThemeDataExtension on BuildContext {
  ThemeData themeData() => ThemeData.light().copyWith(
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: "Nunito Sans"),
        primaryTextTheme:
            ThemeData.light().textTheme.apply(fontFamily: "Nunito Sans"),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: KColors.orange.withOpacity(.3),
          cursorColor: KColors.orange,
          selectionHandleColor: KColors.blue,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.white,
          onPrimary: KColors.orange,
          secondary: KColors.orange,
          onSecondary: Colors.white,
          error: KColors.red,
          onError: Colors.white,
          background: KColors.softWhite,
          onBackground: KColors.dark,
          surface: KColors.blue,
          onSurface: Colors.white,
        ),
      );

  TextStyle appBarTitleStyle() => const TextStyle(
        color: KColors.dark,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      );
}
