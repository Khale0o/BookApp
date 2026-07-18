import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

enum BookAtmosphereStyle { midnight, burgundy, emerald, slate, champagne }

@immutable
class BookAtmospherePalette {
  const BookAtmospherePalette({
    required this.style,
    required this.base,
    required this.field,
    required this.accent,
  });
  final BookAtmosphereStyle style;
  final Color base;
  final Color field;
  final Color accent;
}

BookAtmospherePalette bookAtmosphereFor({int? bookId, String? title}) {
  final value = bookId ?? _stableTextValue(title);
  final style = BookAtmosphereStyle
      .values[value.abs() % BookAtmosphereStyle.values.length];
  return switch (style) {
    BookAtmosphereStyle.midnight => const BookAtmospherePalette(
      style: BookAtmosphereStyle.midnight,
      base: AppColors.midnight,
      field: Color(0xFF1A2942),
      accent: AppColors.gold,
    ),
    BookAtmosphereStyle.burgundy => const BookAtmospherePalette(
      style: BookAtmosphereStyle.burgundy,
      base: Color(0xFF170E17),
      field: AppColors.burgundy,
      accent: Color(0xFFC4A271),
    ),
    BookAtmosphereStyle.emerald => const BookAtmospherePalette(
      style: BookAtmosphereStyle.emerald,
      base: Color(0xFF071713),
      field: AppColors.emerald,
      accent: Color(0xFFBBA66F),
    ),
    BookAtmosphereStyle.slate => const BookAtmospherePalette(
      style: BookAtmosphereStyle.slate,
      base: Color(0xFF111824),
      field: Color(0xFF35435A),
      accent: Color(0xFFC6B481),
    ),
    BookAtmosphereStyle.champagne => const BookAtmospherePalette(
      style: BookAtmosphereStyle.champagne,
      base: Color(0xFF181612),
      field: Color(0xFF5A4B36),
      accent: AppColors.gold,
    ),
  };
}

int _stableTextValue(String? value) {
  var hash = 23;
  for (final unit in value?.trim().toLowerCase().codeUnits ?? const <int>[]) {
    hash = (hash * 37 + unit) & 0x7fffffff;
  }
  return hash;
}

class BookAtmosphere extends StatelessWidget {
  const BookAtmosphere({
    super.key,
    required this.palette,
    this.duration = AppMotion.standard,
  });
  final BookAtmospherePalette palette;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : duration,
    curve: AppMotion.curve,
    color: palette.base,
    child: RepaintBoundary(
      child: CustomPaint(painter: _AtmospherePainter(palette)),
    ),
  );
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter(this.palette);
  final BookAtmospherePalette palette;
  @override
  void paint(Canvas canvas, Size size) {
    final field = Paint()..color = palette.field.withValues(alpha: .62);
    final accent = Paint()..color = palette.accent.withValues(alpha: .12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .82, size.height * .22),
        width: size.width * .76,
        height: size.height * .72,
      ),
      field,
    );
    canvas.drawCircle(
      Offset(size.width * .12, size.height * .83),
      size.shortestSide * .24,
      accent,
    );
    final line = Paint()
      ..color = palette.accent.withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .5,
        size.height * .06,
        size.width * .58,
        size.height * .7,
      ),
      1.4,
      2.1,
      false,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.palette.style != palette.style;
}
