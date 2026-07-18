import 'package:bookapp/core/config/app_config.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final booksRepositoryProvider = Provider<BooksRepository>(
  (ref) => ApiBooksRepository(ref.watch(apiClientProvider)),
);

final homeBooksProvider = FutureProvider<List<Book>>((ref) async {
  return ref
      .watch(booksRepositoryProvider)
      .getBooks(pageSize: AppConfig.homePageSize);
});

final bookDetailsProvider = FutureProvider.autoDispose.family<Book, int>((
  ref,
  id,
) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel('Book details request disposed'));
  return ref
      .watch(booksRepositoryProvider)
      .getBook(id, cancelToken: cancelToken);
});
