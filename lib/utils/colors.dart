import 'package:flutter/material.dart';

abstract class KColors {
  static const Color orange = Color(0xFFF2780C);
  static const Color red = Color(0xFFEC5555);
  static const Color blue = Color(0xFF4285F4);
  static const Color softWhite = Color(0xFFFBFAF5);
  static const Color softWhite2 = Color(0xFFF9F9F9);
  static const Color dark = Color(0xFF191919);
  static const Color blueGray = Color(0xFFBCC8D8);
  static const Color lightGray = Color(0xFFBCC8D8);

  static const Color antiqueWhite = Color(0xFFFAEBD7);
  static const Color whiteSmoke = Color(0xFFF5F5F5);

  static const List<Color> homeLinearGradient = [
    Color(0xFFEEEEEE),
    Colors.white,
    Colors.white,
    Colors.white,
    Color(0xFFEEEEEE)
  ];

  static Color bisqueColor = const Color(0xFFF2780C).withOpacity(.2);
  static Color blueSea = const Color(0xFF4285F4).withOpacity(.25);
  static Color grayButton = const Color(0xFFBCC8D8).withOpacity(.4);
  static const Color commentTagColor = Color(0xFF4285F4);
  static const Color greenSea = Color(0xFF00B88C);

  static Color commentPending = const Color(0xFFF2780C).withOpacity(.1);
}
