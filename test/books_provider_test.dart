import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBooksRepository implements BooksRepository {
  @override
  Future<Book> getBook(int id, {CancelToken? cancelToken}) async =>
      Book(id: id, bookTitle: 'Loaded book', bookPrice: 8);

  @override
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    CancelToken? cancelToken,
  }) async => const [Book(id: 4, bookTitle: 'Provider book', bookPrice: 12)];
}

void main() {
  test('home provider exposes repository books', () async {
    final container = ProviderContainer(
      overrides: [
        booksRepositoryProvider.overrideWithValue(_FakeBooksRepository()),
      ],
    );
    addTearDown(container.dispose);

    final books = await container.read(homeBooksProvider.future);

    expect(books, hasLength(1));
    expect(books.single.displayTitle, 'Provider book');
  });
}
