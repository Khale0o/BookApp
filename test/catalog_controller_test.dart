import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/explore/presentation/catalog_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _PagedRepository implements BooksRepository {
  final requests = <int>[];

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
  }) async {
    requests.add(pageNumber);
    return List.generate(
      pageSize,
      (index) => Book(
        id: index + 1,
        bookTitle: 'Book ${index + 1}',
        categoryName: categoryName,
      ),
    );
  }
}

void main() {
  test('catalog deduplicates IDs and stops repeated server pages', () async {
    final repository = _PagedRepository();
    final container = ProviderContainer(
      overrides: [booksRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final controller = container.read(catalogControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.loadMore();

    final state = container.read(catalogControllerProvider);
    expect(state.books, hasLength(CatalogController.pageSize));
    expect(state.hasMore, isFalse);
    expect(repository.requests.where((page) => page == 2), hasLength(1));
  });
}
