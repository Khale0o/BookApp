import 'package:bookapp/features/books/presentation/book_details_screen.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/app/shell/app_shell.dart';
import 'package:bookapp/features/auth/presentation/auth_screens.dart';
import 'package:bookapp/features/cart/presentation/cart_screen.dart';
import 'package:bookapp/features/checkout/presentation/checkout_screen.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/explore/presentation/explore_screen.dart';
import 'package:bookapp/features/home/presentation/home_screen.dart';
import 'package:bookapp/features/orders/presentation/orders_screen.dart';
import 'package:bookapp/features/profile/presentation/profile_screen.dart';
import 'package:bookapp/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const explore = '/explore';
  static const cart = '/cart';
  static const profile = '/profile';
  static const login = '/auth/login';
  static const signUp = '/auth/signup';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const checkout = '/checkout';
  static const orders = '/orders';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const PasswordRecoveryScreen(reset: false),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.resetPassword,
      builder: (context, state) => const PasswordRecoveryScreen(reset: true),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
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
              : AppMotion.detailsOpen,
          reverseTransitionDuration: reduceMotion
              ? Duration.zero
              : AppMotion.detailsClose,
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
