import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('single-book response selection', () {
    test('prefers the matching book ID', () {
      final result = selectSingleBook([
        {'id': 1, 'bookTitle': 'First', 'bookPrice': 1},
        {'id': 2, 'bookTitle': 'Match', 'bookPrice': 2},
      ], 2);
      expect(result.displayTitle, 'Match');
    });

    test('falls back to the first valid item', () {
      final result = selectSingleBook([
        {'id': 1, 'bookTitle': 'First', 'bookPrice': 1},
        {'id': 3, 'bookTitle': 'Third', 'bookPrice': 3},
      ], 99);
      expect(result.id, 1);
    });

    test('throws not found for an empty list', () {
      expect(
        () => selectSingleBook([], 1),
        throwsA(isA<BookNotFoundException>()),
      );
    });
  });
}
