import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

enum EditorialCoverStyle {
  layeredPages,
  arch,
  botanical,
  typeBlocks,
  paperWaves,
  geometricFrame,
}

EditorialCoverStyle editorialCoverStyleFor({int? bookId, String? title}) {
  final value = bookId ?? _stableTitleValue(title);
  return EditorialCoverStyle.values[value.abs() %
      EditorialCoverStyle.values.length];
}

int _stableTitleValue(String? title) {
  var hash = 17;
  for (final codeUnit
      in (title?.trim().toLowerCase().codeUnits ?? const <int>[])) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

class GeneratedEditorialCover extends StatelessWidget {
  const GeneratedEditorialCover({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.category,
  });
  final int? bookId;
  final String? title;
  final String? author;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final style = editorialCoverStyleFor(bookId: bookId, title: title);
    final palette = _CoverPalette.forStyle(style);
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 175;
          return ColoredBox(
            color: palette.paper,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _EditorialMotifPainter(
                      style: style,
                      palette: palette,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(compact ? 12 : 18),
                  child: _CoverTypography(
                    title: title ?? 'Untitled book',
                    author: author ?? 'Author unavailable',
                    category: category,
                    compact: compact,
                    palette: palette,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CoverTypography extends StatelessWidget {
  const _CoverTypography({
    required this.title,
    required this.author,
    required this.category,
    required this.compact,
    required this.palette,
  });
  final String title;
  final String author;
  final String? category;
  final bool compact;
  final _CoverPalette palette;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.2).toDouble();
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LeafLoomMark(color: palette.ink),
              const Spacer(),
              if (category != null)
                Flexible(
                  child: Text(
                    category!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    textScaler: TextScaler.linear(scale),
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: .82),
                      fontSize: compact ? 7 : 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: compact ? .7 : 1.1,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: compact ? 12 : 22),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.linear(scale),
                style: TextStyle(
                  color: palette.ink,
                  fontSize: compact ? 17 : 24,
                  height: .98,
                  fontWeight: FontWeight.w700,
                  letterSpacing: compact ? -.5 : -.8,
                ),
              ),
            ),
          ),
          Container(height: 1, color: palette.ink.withValues(alpha: .45)),
          SizedBox(height: compact ? 6 : 9),
          Text(
            author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.linear(scale),
            style: TextStyle(
              color: palette.ink.withValues(alpha: .9),
              fontSize: compact ? 8 : 10,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafLoomMark extends StatelessWidget {
  const _LeafLoomMark({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 19,
    height: 15,
    child: CustomPaint(painter: _LeafLoomMarkPainter(color)),
  );
}

class _LeafLoomMarkPainter extends CustomPainter {
  const _LeafLoomMarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final mid = size.width / 2;
    canvas.drawLine(Offset(mid, 2), Offset(mid, size.height - 1), paint);
    canvas.drawArc(
      Rect.fromLTWH(1, 2, mid - 1, size.height - 3),
      -1.25,
      2.5,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(mid, 2, mid - 1, size.height - 3),
      1.9,
      2.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafLoomMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CoverPalette {
  const _CoverPalette(this.paper, this.ink, this.accent, this.secondary);
  final Color paper;
  final Color ink;
  final Color accent;
  final Color secondary;
  static _CoverPalette forStyle(EditorialCoverStyle style) => switch (style) {
    EditorialCoverStyle.layeredPages => const _CoverPalette(
      Color(0xFFE9DDC8),
      AppColors.ink,
      Color(0xFFB56D45),
      Color(0xFF879E87),
    ),
    EditorialCoverStyle.arch => const _CoverPalette(
      Color(0xFFDCE3D7),
      Color(0xFF23352C),
      Color(0xFF9A4D4D),
      Color(0xFFC6A66A),
    ),
    EditorialCoverStyle.botanical => const _CoverPalette(
      Color(0xFFE8E5D7),
      Color(0xFF263C37),
      Color(0xFF5D7F69),
      Color(0xFFB56D45),
    ),
    EditorialCoverStyle.typeBlocks => const _CoverPalette(
      Color(0xFFE7D7C5),
      Color(0xFF252A3A),
      Color(0xFF823F4A),
      Color(0xFF65738C),
    ),
    EditorialCoverStyle.paperWaves => const _CoverPalette(
      Color(0xFFEFE5D3),
      Color(0xFF26332F),
      Color(0xFFB56D45),
      Color(0xFF8DA59A),
    ),
    EditorialCoverStyle.geometricFrame => const _CoverPalette(
      Color(0xFFDDE3E5),
      Color(0xFF202D3E),
      Color(0xFF9B5148),
      Color(0xFF6A887D),
    ),
  };
}

class _EditorialMotifPainter extends CustomPainter {
  const _EditorialMotifPainter({required this.style, required this.palette});
  final EditorialCoverStyle style;
  final _CoverPalette palette;
  @override
  void paint(Canvas canvas, Size size) {
    final accent = Paint()..color = palette.accent.withValues(alpha: .8);
    final secondary = Paint()..color = palette.secondary.withValues(alpha: .58);
    final line = Paint()
      ..color = palette.ink.withValues(alpha: .23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    switch (style) {
      case EditorialCoverStyle.layeredPages:
        for (var i = 0; i < 4; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                size.width * (.45 + i * .06),
                size.height * (.15 + i * .045),
                size.width * .62,
                size.height * .62,
              ),
              const Radius.circular(14),
            ),
            i.isEven ? accent : secondary,
          );
        }
      case EditorialCoverStyle.arch:
        canvas.drawArc(
          Rect.fromLTWH(
            size.width * .45,
            size.height * .18,
            size.width * .72,
            size.height * .72,
          ),
          3.14,
          3.14,
          true,
          secondary,
        );
        canvas.drawCircle(
          Offset(size.width * .77, size.height * .34),
          size.width * .12,
          accent,
        );
      case EditorialCoverStyle.botanical:
        final stem = Path()
          ..moveTo(size.width * .82, size.height * .95)
          ..quadraticBezierTo(
            size.width * .64,
            size.height * .55,
            size.width * .87,
            size.height * .13,
          );
        canvas.drawPath(stem, line..strokeWidth = 2);
        for (var i = 0; i < 5; i++) {
          final y = size.height * (.25 + i * .12);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(size.width * (.72 + (i.isEven ? .05 : -.03)), y),
              width: size.width * .14,
              height: size.height * .06,
            ),
            i.isEven ? accent : secondary,
          );
        }
      case EditorialCoverStyle.typeBlocks:
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .62,
            0,
            size.width * .38,
            size.height * .36,
          ),
          accent,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            0,
            size.height * .68,
            size.width * .72,
            size.height * .32,
          ),
          secondary,
        );
        canvas.drawLine(
          Offset(size.width * .12, size.height * .58),
          Offset(size.width * .88, size.height * .58),
          line,
        );
      case EditorialCoverStyle.paperWaves:
        final path = Path()
          ..moveTo(0, size.height * .65)
          ..quadraticBezierTo(
            size.width * .23,
            size.height * .45,
            size.width * .5,
            size.height * .68,
          )
          ..quadraticBezierTo(
            size.width * .78,
            size.height * .88,
            size.width,
            size.height * .56,
          )
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, secondary);
        canvas.drawCircle(
          Offset(size.width * .78, size.height * .2),
          size.width * .1,
          accent,
        );
      case EditorialCoverStyle.geometricFrame:
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .09,
            size.height * .1,
            size.width * .82,
            size.height * .8,
          ),
          line..strokeWidth = 2,
        );
        canvas.drawCircle(
          Offset(size.width * .74, size.height * .31),
          size.width * .13,
          accent,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .6,
            size.height * .63,
            size.width * .3,
            size.height * .16,
          ),
          secondary,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _EditorialMotifPainter oldDelegate) =>
      oldDelegate.style != style;
}
