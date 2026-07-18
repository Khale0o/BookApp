import 'package:bookapp/features/books/domain/book.dart';
import 'package:flutter/foundation.dart';

enum CatalogSort {
  apiOrder('API order'),
  titleAscending('Title A–Z'),
  titleDescending('Title Z–A'),
  priceAscending('Price low to high'),
  priceDescending('Price high to low'),
  yearNewest('Publication year newest'),
  yearOldest('Publication year oldest');

  const CatalogSort(this.label);
  final String label;
}

@immutable
class CatalogState {
  const CatalogState({
    this.books = const [],
    this.knownCategories = const [],
    this.query = '',
    this.category,
    this.sort = CatalogSort.apiOrder,
    this.inStockOnly = false,
    this.page = 0,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<Book> books;
  final List<String> knownCategories;
  final String query;
  final String? category;
  final CatalogSort sort;
  final bool inStockOnly;
  final int page;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreError;

  CatalogState copyWith({
    List<Book>? books,
    List<String>? knownCategories,
    String? query,
    Object? category = _unchanged,
    CatalogSort? sort,
    bool? inStockOnly,
    int? page,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? errorMessage = _unchanged,
    Object? loadMoreError = _unchanged,
  }) => CatalogState(
    books: books ?? this.books,
    knownCategories: knownCategories ?? this.knownCategories,
    query: query ?? this.query,
    category: identical(category, _unchanged)
        ? this.category
        : category as String?,
    sort: sort ?? this.sort,
    inStockOnly: inStockOnly ?? this.inStockOnly,
    page: page ?? this.page,
    isInitialLoading: isInitialLoading ?? this.isInitialLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    errorMessage: identical(errorMessage, _unchanged)
        ? this.errorMessage
        : errorMessage as String?,
    loadMoreError: identical(loadMoreError, _unchanged)
        ? this.loadMoreError
        : loadMoreError as String?,
  );

  Iterable<String> get normalizedCategories {
    if (knownCategories.isNotEmpty) return knownCategories;
    final values = <String, String>{};
    for (final book in books) {
      final value = book.categoryName?.trim();
      if (value == null || value.isEmpty) continue;
      values.putIfAbsent(value.toLowerCase(), () => value);
    }
    final result = values.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  List<Book> get visibleBooks {
    final filtered = books
        .where((book) {
          if (inStockOnly && !book.isInStock) return false;
          return true;
        })
        .toList(growable: false);
    int compareMissingLast<T extends Comparable<T>>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    }

    switch (sort) {
      case CatalogSort.apiOrder:
        return filtered;
      case CatalogSort.titleAscending:
        return [...filtered]..sort(
          (a, b) => compareMissingLast(
            a.bookTitle?.toLowerCase(),
            b.bookTitle?.toLowerCase(),
          ),
        );
      case CatalogSort.titleDescending:
        return [...filtered]..sort(
          (a, b) => compareMissingLast(
            b.bookTitle?.toLowerCase(),
            a.bookTitle?.toLowerCase(),
          ),
        );
      case CatalogSort.priceAscending:
        return [...filtered]
          ..sort((a, b) => a.bookPrice.compareTo(b.bookPrice));
      case CatalogSort.priceDescending:
        return [...filtered]
          ..sort((a, b) => b.bookPrice.compareTo(a.bookPrice));
      case CatalogSort.yearNewest:
        return [...filtered]..sort((a, b) {
          final aYear = a.publicationYear;
          final bYear = b.publicationYear;
          if (aYear == null && bYear == null) return 0;
          if (aYear == null) return 1;
          if (bYear == null) return -1;
          return bYear.compareTo(aYear);
        });
      case CatalogSort.yearOldest:
        return [...filtered]..sort(
          (a, b) => compareMissingLast(a.publicationYear, b.publicationYear),
        );
    }
  }
}

const _unchanged = Object();
