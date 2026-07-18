import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_theme.dart';
import 'package:bookapp/core/config/app_config.dart';
import 'package:flutter/material.dart';

class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
