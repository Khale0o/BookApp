import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? AppColors.gold : AppColors.antiqueGold,
      onPrimary: AppColors.midnight,
      secondary: dark ? AppColors.emerald : AppColors.burgundy,
      onSecondary: AppColors.ivory,
      error: AppColors.error,
      onError: Colors.white,
      surface: dark ? AppColors.midnight : AppColors.ivory,
      onSurface: dark ? AppColors.ivory : AppColors.midnight,
      surfaceContainer: dark ? AppColors.midnightElevated : AppColors.warmWhite,
      surfaceContainerHighest: dark ? AppColors.slate : AppColors.lightSurface,
      onSurfaceVariant: dark
          ? const Color(0xFFC9CED6)
          : const Color(0xFF596474),
      outline: dark ? AppColors.darkBorder : AppColors.lightBorder,
      shadow: Colors.black,
    );
    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
      fontFamily: AppTypography.bodyFamily,
    );
    final text = base.textTheme;
    TextStyle? display(
      TextStyle? style,
      double size,
      double height,
      FontWeight weight,
      double spacing,
    ) => style?.copyWith(
      fontFamily: AppTypography.displayFamily,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: spacing,
    );
    TextStyle? body(
      TextStyle? style,
      double size,
      double height,
      FontWeight weight,
    ) => style?.copyWith(
      fontFamily: AppTypography.bodyFamily,
      fontSize: size,
      height: height,
      fontWeight: weight,
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        displayLarge: display(
          text.displayLarge,
          62,
          .96,
          FontWeight.w600,
          -1.8,
        ),
        displayMedium: display(
          text.displayMedium,
          46,
          1,
          FontWeight.w600,
          -1.1,
        ),
        displaySmall: display(
          text.displaySmall,
          38,
          1.04,
          FontWeight.w600,
          -.8,
        ),
        headlineLarge: display(
          text.headlineLarge,
          34,
          1.06,
          FontWeight.w600,
          -.6,
        ),
        headlineMedium: display(
          text.headlineMedium,
          28,
          1.1,
          FontWeight.w600,
          -.35,
        ),
        headlineSmall: display(
          text.headlineSmall,
          23,
          1.15,
          FontWeight.w600,
          -.2,
        ),
        titleLarge: body(text.titleLarge, 20, 1.25, FontWeight.w600),
        titleMedium: body(text.titleMedium, 16, 1.3, FontWeight.w600),
        titleSmall: body(text.titleSmall, 14, 1.3, FontWeight.w600),
        bodyLarge: body(text.bodyLarge, 16, 1.65, FontWeight.w400),
        bodyMedium: body(text.bodyMedium, 14, 1.55, FontWeight.w400),
        bodySmall: body(text.bodySmall, 12, 1.45, FontWeight.w400),
        labelLarge: body(
          text.labelLarge,
          14,
          1.2,
          FontWeight.w700,
        )?.copyWith(letterSpacing: .25),
        labelMedium: body(
          text.labelMedium,
          12,
          1.2,
          FontWeight.w600,
        )?.copyWith(letterSpacing: .4),
        labelSmall: body(
          text.labelSmall,
          10,
          1.2,
          FontWeight.w700,
        )?.copyWith(letterSpacing: .9),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: body(
          text.titleMedium,
          16,
          1.2,
          FontWeight.w600,
        )?.copyWith(color: scheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: .65),
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFamily,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      focusColor: scheme.primary.withValues(alpha: .18),
    );
  }
}
