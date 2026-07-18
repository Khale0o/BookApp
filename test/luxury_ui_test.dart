import 'dart:async';

import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_theme.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/utils/book_hero_tags.dart';
import 'package:bookapp/core/widgets/book_atmosphere.dart';
import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/book_details_screen.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/home/presentation/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _books = [
  Book(
    id: 1,
    bookTitle: 'First Edition',
    authorName: 'First Author',
    categoryName: 'Fiction',
    bookPrice: 12,
    quantityInStock: 4,
  ),
  Book(
    id: 2,
    bookTitle: 'Second Edition',
    authorName: 'Second Author',
    categoryName: 'Essays',
    bookPrice: 18,
    quantityInStock: 0,
  ),
  Book(
    id: 3,
    bookTitle:
        'A Long and Deliberately Expansive Editorial Book Title That Must Stay Inside Its Composition',
    authorName: 'A Writer With a Long Name',
    categoryName: 'Literature',
    bookPrice: 21,
  ),
];

class _LuxuryFakeRepository implements BooksRepository {
  @override
  Future<Book> getBook(int id, {CancelToken? cancelToken}) async =>
      _books.firstWhere((book) => book.id == id);

  @override
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    CancelToken? cancelToken,
  }) async => _books;
}

class _PendingDetailsRepository implements BooksRepository {
  _PendingDetailsRepository() : _pending = Completer<Book>();
  final Completer<Book> _pending;

  @override
  Future<Book> getBook(int id, {CancelToken? cancelToken}) => _pending.future;

  @override
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    CancelToken? cancelToken,
  }) async => _books;
}

Widget _testApp(Widget child, {bool reducedMotion = false}) => MaterialApp(
  theme: AppTheme.light,
  home: MediaQuery(
    data: const MediaQueryData(
      size: Size(390, 844),
    ).copyWith(disableAnimations: reducedMotion),
    child: child,
  ),
);

void main() {
  test('atmosphere and Hero identities are deterministic', () {
    final first = bookAtmosphereFor(bookId: 7, title: 'Ignored title');
    final repeated = bookAtmosphereFor(bookId: 7, title: 'Another title');
    expect(repeated.style, first.style);
    expect(bookAtmosphereFor(bookId: 8).style, isA<BookAtmosphereStyle>());
    expect(
      carouselBookHeroTag(_books.first),
      carouselBookHeroTag(_books.first),
    );
    expect(
      shelfBookHeroTag(_books.first, 0),
      isNot(shelfBookHeroTag(_books.first, 1)),
    );
  });

  testWidgets('carousel swipe changes the selected book', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: SingleChildScrollView(child: FeaturedCarousel(books: _books)),
        ),
      ),
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('selected-title'))).data,
      'First Edition',
    );

    await tester.drag(find.byType(PageView), const Offset(-260, 0));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('selected-title'))).data,
      'Second Edition',
    );
  });

  testWidgets('reduced motion removes perspective but preserves swiping', (
    tester,
  ) async {
    final pose = carouselPoseFor(.75, reducedMotion: true);
    expect(pose.rotationY, 0);
    expect(pose.translationX, 0);
    expect(pose.scale, 1);

    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: SingleChildScrollView(child: FeaturedCarousel(books: _books)),
        ),
        reducedMotion: true,
      ),
    );
    await tester.drag(find.byType(PageView), const Offset(-260, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('selected-title'))).data,
      'Second Edition',
    );
  });

  testWidgets('narrow carousel contains a long selected title', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const Scaffold(
          body: SingleChildScrollView(
            child: FeaturedCarousel(
              books: [
                Book(
                  id: 3,
                  bookTitle:
                      'A Long and Deliberately Expansive Editorial Book Title That Must Stay Inside Its Composition',
                  authorName: 'A Writer With a Long Name',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('selected-title')), findsOneWidget);
  });

  testWidgets('Home shelf remains within narrow viewport boundaries', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(_LuxuryFakeRepository()),
        ],
        child: _testApp(const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final shelfRect = tester.getRect(
      find.byKey(const ValueKey('curated-shelf')),
    );
    expect(shelfRect.left, greaterThanOrEqualTo(0));
    expect(shelfRect.right, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Details renders from a direct book ID without a Hero source', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(_LuxuryFakeRepository()),
        ],
        child: _testApp(const BookDetailsScreen(bookId: 2)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('details-atmosphere')), findsOneWidget);
    expect(find.text('Second Edition'), findsWidgets);
    expect(find.byType(Hero), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Details renders matching initial Book data before refresh completes',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            booksRepositoryProvider.overrideWithValue(
              _PendingDetailsRepository(),
            ),
          ],
          child: _testApp(
            BookDetailsScreen(
              bookId: 1,
              initialBook: _books.first,
              heroTag: 'initial-book-cover',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('details-atmosphere')), findsOneWidget);
      expect(find.text('First Edition'), findsWidgets);
    },
  );

  testWidgets('mismatched initial Book is not trusted for Details path', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(
            _PendingDetailsRepository(),
          ),
        ],
        child: _testApp(
          BookDetailsScreen(bookId: 2, initialBook: _books.first),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('details-atmosphere')), findsNothing);
    expect(find.text('First Edition'), findsNothing);
    expect(
      BookDetailsRouteExtra(book: _books.first, heroTag: 'cover').matches(2),
      isFalse,
    );
  });

  testWidgets('Home and Details apply route-appropriate status-bar styles', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(_LuxuryFakeRepository()),
        ],
        child: _testApp(const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnnotatedRegion<SystemUiOverlayStyle> &&
            widget.value.statusBarIconBrightness == Brightness.dark,
      ),
      findsWidgets,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          booksRepositoryProvider.overrideWithValue(_LuxuryFakeRepository()),
        ],
        child: _testApp(const BookDetailsScreen(bookId: 1)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnnotatedRegion<SystemUiOverlayStyle> &&
            widget.value.statusBarIconBrightness == Brightness.light,
      ),
      findsWidgets,
    );
  });

  test('theme assigns editorial and functional font families', () {
    expect(
      AppTheme.light.textTheme.displayLarge?.fontFamily,
      AppTypography.displayFamily,
    );
    expect(
      AppTheme.light.textTheme.headlineMedium?.fontFamily,
      AppTypography.displayFamily,
    );
    expect(
      AppTheme.light.textTheme.bodyLarge?.fontFamily,
      AppTypography.bodyFamily,
    );
    expect(
      AppTheme.dark.textTheme.labelLarge?.fontFamily,
      AppTypography.bodyFamily,
    );
  });

  test('secondary semantic text remains readable against theme surfaces', () {
    double contrast(Color first, Color second) {
      final light = first.computeLuminance() + .05;
      final dark = second.computeLuminance() + .05;
      return light > dark ? light / dark : dark / light;
    }

    expect(
      contrast(
        AppTheme.light.colorScheme.onSurfaceVariant,
        AppTheme.light.colorScheme.surface,
      ),
      greaterThan(4.5),
    );
    expect(
      contrast(
        AppTheme.dark.colorScheme.onSurfaceVariant,
        AppTheme.dark.colorScheme.surface,
      ),
      greaterThan(4.5),
    );
  });
}
