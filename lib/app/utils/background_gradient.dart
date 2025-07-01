import 'package:flutter/material.dart';

import 'app_colors.dart';


class AppDecorations {
  static const BoxDecoration gradientBackground =
  BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}