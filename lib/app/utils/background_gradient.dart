import 'package:flutter/material.dart';

import 'app_colors.dart';


class AppDecorations {
  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.xlightback1,
        AppColors.xlightback2,
        AppColors.xlightback3, // End color
      ],
    ),
  );
}