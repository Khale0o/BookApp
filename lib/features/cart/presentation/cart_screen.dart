import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/auth/presentation/auth_screens.dart';
import 'package:bookapp/features/cart/domain/cart_item.dart';
import 'package:bookapp/features/cart/presentation/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppColors.midnight,
    body: SafeArea(
      bottom: false,
      child: RequireAuth(
        message: 'Sign in to load and manage the bag attached to your account.',
        child: _AuthenticatedCart(state: ref.watch(cartControllerProvider)),
      ),
    ),
  );
}

class _AuthenticatedCart extends ConsumerWidget {
  const _AuthenticatedCart({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartControllerProvider.notifier);
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return AsyncMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Your bag could not be loaded',
        message: state.errorMessage!,
        actionLabel: 'Try again',
        onAction: controller.load,
      );
    }
    if (state.items.isEmpty) {
      return const AsyncMessage(
        icon: Icons.shopping_bag_outlined,
        title: 'Your bag is empty',
        message: 'Add an available book from its details page to begin.',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: CustomScrollView(
        key: const PageStorageKey('cart-scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: ContentShell(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.xl,
                  0,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your bag',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    Text(
                      '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ContentShell(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 820;
                  final list = Column(
                    children: [
                      for (final item in state.items) ...[
                        _CartItemCard(
                          item: item,
                          pending: state.pendingBookIds.contains(item.bookId),
                          onRemove: () => controller.removeBook(item.bookId),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                  final summary = _CartSummary(state: state);
                  if (!wide) {
                    return Column(
                      children: [
                        list,
                        const SizedBox(height: AppSpacing.lg),
                        summary,
                        const SizedBox(height: AppSpacing.huge),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: list),
                      const SizedBox(width: AppSpacing.xl),
                      SizedBox(width: 340, child: summary),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.pending,
    required this.onRemove,
  });
  final CartItem item;
  final bool pending;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: AppMotion.quick,
    opacity: pending ? .58 : 1,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: BookCover(
                image: item.bookImage,
                semanticLabel: 'Cover of ${item.displayTitle}',
                bookId: item.bookId,
                title: item.bookTitle,
                author: null,
                category: null,
                borderRadius: AppRadii.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.displayPrice,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Quantity ${item.quantity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove ${item.displayTitle}',
              onPressed: pending ? null : onRemove,
              icon: pending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadii.md),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bag summary', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(child: Text('Subtotal')),
              Text(
                state.subtotal.toStringAsFixed(2),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Currency, shipping, tax, and discounts are not documented by the API and are not included.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.pendingBookIds.isNotEmpty
                  ? null
                  : () => context.push(AppRoutes.checkout),
              child: const Text('Proceed to checkout'),
            ),
          ),
        ],
      ),
    ),
  );
}
