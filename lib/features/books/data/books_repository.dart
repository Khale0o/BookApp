import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract interface class BooksRepository {
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    String? categoryName,
    String? searchValue,
    String? sortOrder,
    CancelToken? cancelToken,
  });
  Future<Book> getBook(int id, {CancelToken? cancelToken});
}

class ApiBooksRepository implements BooksRepository {
  ApiBooksRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<Book>> getBooks({
    int pageNumber = 1,
    int pageSize = 12,
    String? categoryName,
    String? searchValue,
    String? sortOrder,
    CancelToken? cancelToken,
  }) async {
    final query = <String, Object>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (categoryName?.trim().isNotEmpty ?? false) {
      query['categoryName'] = categoryName!.trim();
    }
    if (searchValue?.trim().isNotEmpty ?? false) {
      query['searchValue'] = searchValue!.trim();
    }
    if (sortOrder?.trim().isNotEmpty ?? false) {
      query['sortOrder'] = sortOrder!.trim();
    }
    final response = await _client.dio.get<Object?>(
      '/api/Books',
      queryParameters: query,
      cancelToken: cancelToken,
    );
    final books = parseBookList(response.data);
    _debugLogBookImages(books);
    return books;
  }

  @override
  Future<Book> getBook(int id, {CancelToken? cancelToken}) async {
    final response = await _client.dio.get<Object?>(
      '/api/Books',
      queryParameters: {'bookId': id},
      cancelToken: cancelToken,
    );
    final book = selectSingleBook(response.data, id);
    _debugLogBookImages([book]);
    return book;
  }
}

void _debugLogBookImages(List<Book> books) {
  if (!kDebugMode) return;
  for (final book in books) {
    debugPrint(
      '[Books API] id=${book.id ?? 'unknown'} bookImage=${book.bookImage ?? '<null>'}',
    );
  }
}

List<Book> parseBookList(Object? data) {
  if (data is! List) {
    throw const AppException('The bookstore returned an unexpected response.');
  }
  return data
      .whereType<Map>()
      .map((item) => Book.fromJson(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

Book selectSingleBook(Object? data, int requestedId) {
  final books = parseBookList(data);
  if (books.isEmpty) throw const BookNotFoundException();
  for (final book in books) {
    if (book.id == requestedId) return book;
  }
  return books[0];
}
