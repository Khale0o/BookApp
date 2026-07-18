import 'package:bookapp/core/errors/api_failure_mapper.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/cart/data/cart_repository.dart';
import 'package:bookapp/features/cart/domain/cart_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => ApiCartRepository(ref.watch(apiClientProvider)),
);

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

@immutable
class CartState {
  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.pendingBookIds = const {},
    this.errorMessage,
  });

  final List<CartItem> items;
  final bool isLoading;
  final Set<int> pendingBookIds;
  final String? errorMessage;

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    Set<int>? pendingBookIds,
    Object? errorMessage = _unchanged,
  }) => CartState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    pendingBookIds: pendingBookIds ?? this.pendingBookIds,
    errorMessage: identical(errorMessage, _unchanged)
        ? this.errorMessage
        : errorMessage as String?,
  );
}

const _unchanged = Object();

class CartController extends Notifier<CartState> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  CartState build() {
    final authenticated = ref.watch(authControllerProvider).isAuthenticated;
    if (authenticated) Future<void>.microtask(load);
    return const CartState();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.getCart();
      state = CartState(items: items);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapApiFailure(error),
      );
    }
  }

  Future<bool> addBook(int bookId) async {
    if (state.pendingBookIds.contains(bookId)) return false;
    state = state.copyWith(
      pendingBookIds: {...state.pendingBookIds, bookId},
      errorMessage: null,
    );
    try {
      await _repository.addBook(bookId);
      await load();
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: mapApiFailure(error));
      return false;
    } finally {
      state = state.copyWith(
        pendingBookIds: {...state.pendingBookIds}..remove(bookId),
      );
    }
  }

  Future<void> removeBook(int bookId) async {
    if (state.pendingBookIds.contains(bookId)) return;
    final previous = state.items;
    state = state.copyWith(
      items: previous.where((item) => item.bookId != bookId).toList(),
      pendingBookIds: {...state.pendingBookIds, bookId},
      errorMessage: null,
    );
    try {
      await _repository.removeBook(bookId);
    } catch (error) {
      state = state.copyWith(
        items: previous,
        errorMessage: mapApiFailure(error),
      );
    } finally {
      state = state.copyWith(
        pendingBookIds: {...state.pendingBookIds}..remove(bookId),
      );
    }
  }
}
