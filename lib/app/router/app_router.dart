import 'package:bookapp/features/books/presentation/book_details_screen.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/home/presentation/home_screen.dart';
import 'package:bookapp/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const bookName = 'book-details';
  static String book(int id) => '/books/$id';
}

@immutable
class BookDetailsRouteExtra {
  const BookDetailsRouteExtra({required this.book, required this.heroTag});
  final Book book;
  final Object heroTag;

  bool matches(int? bookId) => bookId != null && book.id == bookId;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/books/:bookId',
      name: AppRoutes.bookName,
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['bookId'] ?? '');
        final extra = state.extra is BookDetailsRouteExtra
            ? state.extra as BookDetailsRouteExtra
            : null;
        final initialBook = extra != null && extra.matches(id)
            ? extra.book
            : null;
        final reduceMotion =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        return CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 280),
          child: BookDetailsScreen(
            bookId: id,
            heroTag: initialBook == null ? null : extra!.heroTag,
            initialBook: initialBook,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
      },
    ),
  ],
);
