import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing imagery renders generated cover metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: BookCover(
              image: null,
              semanticLabel: 'Cover of Missing Book',
              bookId: 19,
              title: 'Missing Book',
              author: 'A Real Author',
              category: 'Fiction',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Missing Book'), findsOneWidget);
    expect(find.text('A Real Author'), findsOneWidget);
    expect(find.text('FICTION'), findsOneWidget);
    expect(find.text('No cover'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Cover of Missing Book',
      ),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(AspectRatio)), const Size(200, 300));
  });

  testWidgets('invalid remote imagery uses the generated fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: BookCover(
              image: 'file:///unsupported-cover.jpg',
              semanticLabel: 'Cover of Unsupported Book',
              bookId: 20,
              title: 'Unsupported Book',
              author: 'An Author',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Unsupported Book'), findsOneWidget);
    expect(find.text('An Author'), findsOneWidget);
    expect(tester.getSize(find.byType(AspectRatio)), const Size(120, 180));
  });

  testWidgets('compact generated cover handles long titles without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: BookCover(
              image: null,
              semanticLabel: 'Cover of a long title',
              bookId: 33,
              title:
                  'An Exceptionally Long Title That Remains Contained on a Compact Editorial Cover',
              author: 'An Author With a Considerably Long Name',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('An Exceptionally Long Title'), findsOneWidget);
  });
}
