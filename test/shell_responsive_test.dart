import 'package:bookapp/app/shell/app_shell.dart';
import 'package:bookapp/app/theme/app_theme.dart';
import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/explore/presentation/explore_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _StatePage extends StatefulWidget {
  const _StatePage(this.name);
  final String name;

  @override
  State<_StatePage> createState() => _StatePageState();
}

class _StatePageState extends State<_StatePage> {
  var count = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${widget.name} page'),
        Text('$count', key: ValueKey('${widget.name}-count')),
        FilledButton(
          key: ValueKey('${widget.name}-increment'),
          onPressed: () => setState(() => count++),
          child: const Text('Increment'),
        ),
      ],
    ),
  );
}

GoRouter _shellRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        for (final path in const ['/home', '/explore', '/cart', '/profile'])
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: path,
                builder: (_, _) => _StatePage(path.substring(1)),
              ),
            ],
          ),
      ],
    ),
  ],
);

class _ExploreRepository implements BooksRepository {
  @override
  Future<Book> getBook(int id, {CancelToken? cancelToken}) async =>
      Book(id: id);

  @override
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    String? categoryName,
    String? searchValue,
    String? sortOrder,
    CancelToken? cancelToken,
  }) async => const [
    Book(
      id: 1,
      bookTitle:
          'A deliberately long title that must remain inside its catalog card',
      authorName: 'A Long Author Name',
      categoryName: 'Fiction',
      bookPrice: 10,
      quantityInStock: 2,
    ),
  ];
}

void main() {
  testWidgets('indexed shell preserves branch state on phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = _shellRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-increment')));
    await tester.pump();
    expect(find.byKey(const ValueKey('home-count')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('explore page'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-count')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('wide shell uses the compact editorial rail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = _shellRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('L&L'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testWidgets('narrow Explore tolerates increased text scale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(_ExploreRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(1.8),
            ),
            child: ExploreScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('catalog-card-1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('deliberately long title'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
