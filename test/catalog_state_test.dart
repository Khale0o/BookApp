import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/explore/domain/catalog_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'categories are trimmed, sorted, and deduplicated case-insensitively',
    () {
      const state = CatalogState(
        books: [
          Book(id: 1, categoryName: ' Fiction '),
          Book(id: 2, categoryName: 'fiction'),
          Book(id: 3, categoryName: 'Classic'),
          Book(id: 4),
        ],
      );

      expect(state.normalizedCategories, ['Classic', 'Fiction']);
    },
  );

  test('verified sort fields place missing publication years last', () {
    const state = CatalogState(
      sort: CatalogSort.yearNewest,
      books: [
        Book(id: 1, bookTitle: 'Unknown year'),
        Book(id: 2, bookTitle: 'Older', publicationYear: 1980),
        Book(id: 3, bookTitle: 'Newer', publicationYear: 2020),
      ],
    );

    expect(state.visibleBooks.map((book) => book.id), [3, 2, 1]);
  });

  test('stock filter uses only documented quantity values', () {
    const state = CatalogState(
      inStockOnly: true,
      books: [
        Book(id: 1, quantityInStock: 2),
        Book(id: 2, quantityInStock: 0),
        Book(id: 3),
      ],
    );

    expect(state.visibleBooks.map((book) => book.id), [1]);
  });
}
