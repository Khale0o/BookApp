import 'package:bookapp/core/errors/api_failure_mapper.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/profile/data/account_repository.dart';
import 'package:bookapp/features/profile/domain/account_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => ApiAccountRepository(ref.watch(apiClientProvider)),
);

final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(AccountController.new);

@immutable
class AccountState {
  const AccountState({
    this.profile,
    this.addresses = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.uploadProgress,
    this.errorMessage,
  });
  final UserProfile? profile;
  final List<UserAddress> addresses;
  final bool isLoading;
  final bool isMutating;
  final double? uploadProgress;
  final String? errorMessage;

  AccountState copyWith({
    Object? profile = _unchanged,
    List<UserAddress>? addresses,
    bool? isLoading,
    bool? isMutating,
    Object? uploadProgress = _unchanged,
    Object? errorMessage = _unchanged,
  }) => AccountState(
    profile: identical(profile, _unchanged)
        ? this.profile
        : profile as UserProfile?,
    addresses: addresses ?? this.addresses,
    isLoading: isLoading ?? this.isLoading,
    isMutating: isMutating ?? this.isMutating,
    uploadProgress: identical(uploadProgress, _unchanged)
        ? this.uploadProgress
        : uploadProgress as double?,
    errorMessage: identical(errorMessage, _unchanged)
        ? this.errorMessage
        : errorMessage as String?,
  );
}

const _unchanged = Object();

class AccountController extends Notifier<AccountState> {
  AccountRepository get _repository => ref.read(accountRepositoryProvider);

  @override
  AccountState build() {
    if (ref.watch(authControllerProvider).isAuthenticated) {
      Future<void>.microtask(load);
    }
    return const AccountState();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final values = await Future.wait<Object>([
        _repository.getProfile(),
        _repository.getAddresses(),
      ]);
      state = AccountState(
        profile: values[0] as UserProfile,
        addresses: values[1] as List<UserAddress>,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapApiFailure(error),
      );
    }
  }

  Future<bool> saveAddress(UserAddress address) async {
    if (state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    try {
      if (address.id == null) {
        await _repository.addAddress(address);
      } else {
        await _repository.editAddress(address);
      }
      final addresses = await _repository.getAddresses();
      state = state.copyWith(addresses: addresses, isMutating: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: mapApiFailure(error),
      );
      return false;
    }
  }

  Future<bool> uploadImage(String filename, List<int> bytes) async {
    if (state.isMutating) return false;
    state = state.copyWith(
      isMutating: true,
      uploadProgress: 0.0,
      errorMessage: null,
    );
    final previous = state.profile;
    try {
      await _repository.uploadImage(
        filename: filename,
        bytes: bytes,
        onProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
          }
        },
      );
      final profile = await _repository.getProfile();
      state = state.copyWith(
        profile: profile,
        isMutating: false,
        uploadProgress: null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        profile: previous,
        isMutating: false,
        uploadProgress: null,
        errorMessage: mapApiFailure(error),
      );
      return false;
    }
  }
}
