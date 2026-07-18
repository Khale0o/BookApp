import 'package:bookapp/features/books/domain/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book parsing', () {
    test('parses complete data', () {
      final book = Book.fromJson({
        'id': 7,
        'bookTitle': 'A Book',
        'authorName': 'An Author',
        'categoryName': 'Fiction',
        'bookPrice': 19.5,
        'bookImage': '/covers/7.jpg',
        'bookDescription': 'A description.',
        'quantityInStock': 3,
        'publicationYear': 2024,
      });

      expect(book.id, 7);
      expect(book.displayTitle, 'A Book');
      expect(book.displayAuthor, 'An Author');
      expect(book.displayCategory, 'Fiction');
      expect(book.displayPrice, '19.50');
      expect(book.isInStock, isTrue);
      expect(book.publicationYear, 2024);
    });

    test('handles missing, blank, and null values', () {
      final book = Book.fromJson({'bookTitle': '  ', 'bookPrice': null});

      expect(book.id, isNull);
      expect(book.bookTitle, isNull);
      expect(book.displayTitle, 'Untitled book');
      expect(book.displayAuthor, 'Author unavailable');
      expect(book.bookPrice, 0);
      expect(book.quantityInStock, isNull);
      expect(book.isInStock, isFalse);
    });
  });

  group('numeric parsing', () {
    test('parses int, double, numeric string, and null', () {
      expect(Book.parseDouble(4), 4.0);
      expect(Book.parseDouble(4.25), 4.25);
      expect(Book.parseDouble(' 4.5 '), 4.5);
      expect(Book.parseDouble(null), isNull);
      expect(Book.parseInt(4), 4);
      expect(Book.parseInt(4.9), 4);
      expect(Book.parseInt('12'), 12);
      expect(Book.parseInt(null), isNull);
    });
  });
}
