import 'package:bookapp/features/books/data/books_repository.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/explore/domain/catalog_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogControllerProvider =
    NotifierProvider<CatalogController, CatalogState>(CatalogController.new);

class CatalogController extends Notifier<CatalogState> {
  static const pageSize = 12;
  final Set<int> _requestedPages = {};
  final Set<String> _pageSignatures = {};
  int _generation = 0;

  BooksRepository get _repository => ref.read(booksRepositoryProvider);

  @override
  CatalogState build() {
    Future<void>.microtask(loadInitial);
    return const CatalogState(isInitialLoading: true);
  }

  Future<void> loadInitial() async {
    final generation = ++_generation;
    _requestedPages.clear();
    _pageSignatures.clear();
    state = state.copyWith(
      books: const [],
      page: 0,
      isInitialLoading: true,
      isLoadingMore: false,
      hasMore: true,
      errorMessage: null,
      loadMoreError: null,
    );
    await _loadPage(1, generation: generation, initial: true);
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasMore) return;
    await _loadPage(state.page + 1, generation: _generation);
  }

  Future<void> _loadPage(
    int page, {
    required int generation,
    bool initial = false,
  }) async {
    if (_requestedPages.contains(page)) return;
    _requestedPages.add(page);
    if (!initial) {
      state = state.copyWith(isLoadingMore: true, loadMoreError: null);
    }
    try {
      final result = await _repository.getBooks(
        pageNumber: page,
        pageSize: pageSize,
        categoryName: state.category,
        searchValue: state.query,
      );
      if (generation != _generation) return;
      final signature = result
          .map((book) => book.id?.toString() ?? book.displayTitle)
          .join('|');
      final repeatedPage =
          signature.isNotEmpty && !_pageSignatures.add(signature);
      final byId = <int, Book>{};
      final withoutId = <Book>[];
      for (final book in [...state.books, ...result]) {
        if (book.id case final id?) {
          byId.putIfAbsent(id, () => book);
        } else if (!withoutId.any(
          (existing) =>
              existing.displayTitle == book.displayTitle &&
              existing.displayAuthor == book.displayAuthor,
        )) {
          withoutId.add(book);
        }
      }
      state = state.copyWith(
        books: [...byId.values, ...withoutId],
        page: page,
        isInitialLoading: false,
        isLoadingMore: false,
        hasMore: !repeatedPage && result.length >= pageSize,
        errorMessage: null,
        loadMoreError: null,
      );
    } catch (_) {
      if (generation != _generation) return;
      _requestedPages.remove(page);
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        errorMessage: initial
            ? 'The catalog could not be loaded. Please try again.'
            : state.errorMessage,
        loadMoreError: initial
            ? null
            : 'More books could not be loaded. Your current shelf is still here.',
      );
    }
  }

  Future<void> setQuery(String value) async {
    final normalized = value.trim();
    if (normalized == state.query) return;
    state = state.copyWith(query: normalized);
    await loadInitial();
  }

  Future<void> setCategory(String? value) async {
    final normalized = value?.trim();
    if (normalized == state.category) return;
    state = state.copyWith(
      category: normalized?.isEmpty ?? true ? null : normalized,
    );
    await loadInitial();
  }

  void setSort(CatalogSort value) => state = state.copyWith(sort: value);

  void setInStockOnly(bool value) => state = state.copyWith(inStockOnly: value);

  Future<void> clearFilters() async {
    state = state.copyWith(
      query: '',
      category: null,
      sort: CatalogSort.apiOrder,
      inStockOnly: false,
    );
    await loadInitial();
  }
}
