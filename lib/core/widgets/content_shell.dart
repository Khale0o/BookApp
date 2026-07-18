import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class ContentShell extends StatelessWidget {
  const ContentShell({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContentWidth,
  });
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < 500
                ? AppSpacing.md
                : AppLayout.pagePadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
