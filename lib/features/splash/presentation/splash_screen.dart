import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    Future<void>.delayed(AppMotion.splash, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.curve,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Center(
          child: FadeTransition(
            opacity: reduced ? const AlwaysStoppedAnimation(1) : animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BookMark(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.ivory,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizeTransition(
                  sizeFactor: reduced
                      ? const AlwaysStoppedAnimation(1)
                      : animation,
                  axis: Axis.horizontal,
                  axisAlignment: 0,
                  child: Container(width: 72, height: 1, color: AppColors.gold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A CONSIDERED COLLECTION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.pearl.withValues(alpha: .72),
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookMark extends StatelessWidget {
  const _BookMark();
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${AppConfig.appName} book mark',
      child: SizedBox(
        width: 72,
        height: 58,
        child: CustomPaint(painter: _BookMarkPainter()),
      ),
    );
  }
}

class _BookMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.ivory
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final accent = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final left = Path()
      ..moveTo(size.width / 2, 13)
      ..quadraticBezierTo(22, 4, 8, 12)
      ..lineTo(8, 45)
      ..quadraticBezierTo(24, 38, size.width / 2, 50)
      ..close();
    final right = Path()
      ..moveTo(size.width / 2, 13)
      ..quadraticBezierTo(50, 4, 64, 12)
      ..lineTo(64, 45)
      ..quadraticBezierTo(48, 38, size.width / 2, 50)
      ..close();
    canvas.drawPath(left, line);
    canvas.drawPath(right, line);
    canvas.drawLine(
      Offset(size.width / 2, 13),
      Offset(size.width / 2, 50),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
