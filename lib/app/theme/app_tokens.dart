import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const midnight = Color(0xFF090F1B);
  static const midnightElevated = Color(0xFF111A2A);
  static const slate = Color(0xFF1B2638);
  static const ivory = Color(0xFFF6F1E7);
  static const pearl = Color(0xFFE4E2DF);
  static const warmWhite = Color(0xFFFFFCF7);
  static const lightSurface = Color(0xFFF0EEE9);
  static const gold = Color(0xFFC6A86A);
  static const antiqueGold = Color(0xFFA7894F);
  static const burgundy = Color(0xFF552B39);
  static const emerald = Color(0xFF21483F);
  static const coolGrey = Color(0xFF6D7480);
  static const darkBorder = Color(0xFF334057);
  static const lightBorder = Color(0xFFD7D2C8);
  static const success = Color(0xFF6FA58B);
  static const warning = Color(0xFFC6A86A);
  static const error = Color(0xFFC86B72);
  static const disabled = Color(0xFF858A94);

  // Kept as semantic cover-art roles for the generated editorial covers.
  static const ink = midnight;
  static const paper = ivory;
}

abstract final class AppTypography {
  static const displayFamily = 'Cormorant Garamond';
  static const bodyFamily = 'Manrope';
}

abstract final class AppSystemOverlay {
  static const immersiveDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const huge = 72.0;
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 24.0;
  static const sheet = 30.0;
}

abstract final class AppLayout {
  static const maxContentWidth = 1240.0;
  static const readableWidth = 680.0;
  static const tablet = 720.0;
  static const desktop = 1050.0;
  static const pagePadding = 24.0;
}

abstract final class AppMotion {
  static const splash = Duration(milliseconds: 1100);
  static const press = Duration(milliseconds: 100);
  static const quick = Duration(milliseconds: 120);
  static const selectedCopy = Duration(milliseconds: 220);
  static const shelfReveal = Duration(milliseconds: 320);
  static const detailsOpen = Duration(milliseconds: 460);
  static const detailsClose = Duration(milliseconds: 360);
  static const standard = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 520);
  static const curve = Curves.easeOutCubic;
  static const smoothCurve = Curves.easeInOutCubic;
}
