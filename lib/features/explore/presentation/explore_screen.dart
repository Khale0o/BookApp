import 'dart:async';

import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/utils/book_hero_tags.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/explore/domain/catalog_state.dart';
import 'package:bookapp/features/explore/presentation/catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_prefetch);
  }

  void _prefetch() {
    if (_scrollController.position.extentAfter < 640) {
      ref.read(catalogControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(catalogControllerProvider.notifier).setQuery(value),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_prefetch)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(catalogControllerProvider);
    final wide = MediaQuery.sizeOf(context).width >= AppLayout.desktop;
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: ref.read(catalogControllerProvider.notifier).loadInitial,
          child: CustomScrollView(
            key: const PageStorageKey('explore-scroll'),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Search the catalog by title, author, or category.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SearchField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmitted: (value) {
                            _debounce?.cancel();
                            ref
                                .read(catalogControllerProvider.notifier)
                                .setQuery(value);
                          },
                          onClear: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _CategoryStrip(state: state),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.query.isEmpty
                                    ? 'The collection'
                                    : 'Search results',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            if (!wide)
                              OutlinedButton.icon(
                                onPressed: () => _showFilters(context),
                                icon: const Icon(Icons.tune_rounded, size: 18),
                                label: const Text('Filter & sort'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.isInitialLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null && state.books.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AsyncMessage(
                    icon: Icons.wifi_off_rounded,
                    title: 'The catalog is unavailable',
                    message: state.errorMessage!,
                    actionLabel: 'Try again',
                    onAction: ref
                        .read(catalogControllerProvider.notifier)
                        .loadInitial,
                  ),
                )
              else if (state.visibleBooks.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AsyncMessage(
                    icon: Icons.search_off_rounded,
                    title: 'No books found',
                    message:
                        'Try a broader search or clear the current filters.',
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: ContentShell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (wide) ...[
                          SizedBox(
                            width: 250,
                            child: _FilterPanel(state: state),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                        ],
                        Expanded(
                          child: _CatalogGrid(books: state.visibleBooks),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: state.isLoadingMore
                        ? const CircularProgressIndicator()
                        : state.loadMoreError != null
                        ? TextButton.icon(
                            onPressed: ref
                                .read(catalogControllerProvider.notifier)
                                .loadMore,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry loading more'),
                          )
                        : !state.hasMore && state.books.isNotEmpty
                        ? Text(
                            'You have reached the end of the loaded catalog.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          )
                        : const SizedBox(height: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFilters(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.midnightElevated,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _FilterPanel(state: ref.watch(catalogControllerProvider)),
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      labelText: 'Search books, authors, or categories',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
    ),
  );
}

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip({required this.state});
  final CatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = state.normalizedCategories.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: state.category == null,
            onSelected: (_) =>
                ref.read(catalogControllerProvider.notifier).setCategory(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: AppSpacing.xs),
            ChoiceChip(
              label: Text(category),
              selected: state.category?.toLowerCase() == category.toLowerCase(),
              onSelected: (_) => ref
                  .read(catalogControllerProvider.notifier)
                  .setCategory(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  const _FilterPanel({required this.state});
  final CatalogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(catalogControllerProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<CatalogSort>(
          initialValue: state.sort,
          decoration: const InputDecoration(labelText: 'Sort by'),
          items: [
            for (final value in CatalogSort.values)
              DropdownMenuItem(value: value, child: Text(value.label)),
          ],
          onChanged: (value) {
            if (value != null) controller.setSort(value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('In stock only'),
          subtitle: const Text('Uses documented quantity values'),
          value: state.inStockOnly,
          onChanged: controller.setInStockOnly,
        ),
      ],
    );
  }
}

class _CatalogGrid extends StatelessWidget {
  const _CatalogGrid({required this.books});
  final List<Book> books;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final columns = width < 330
          ? 1
          : width < 650
          ? 2
          : width < 950
          ? 3
          : 4;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: books.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio:
              (columns == 1 ? 1.75 : .55) /
              (1 + (textScale - 1).clamp(0, 1) * .18),
        ),
        itemBuilder: (context, index) => _CatalogCard(book: books[index]),
      );
    },
  );
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final tag = catalogBookHeroTag(book);
    return Semantics(
      button: book.id != null,
      label: 'Open ${book.displayTitle} by ${book.displayAuthor}',
      child: InkWell(
        onTap: book.id == null
            ? null
            : () => context.push(
                AppRoutes.book(book.id!),
                extra: BookDetailsRouteExtra(book: book, heroTag: tag),
              ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: .6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: BookCover(
                      image: book.bookImage,
                      semanticLabel: 'Cover of ${book.displayTitle}',
                      bookId: book.id,
                      title: book.bookTitle,
                      author: book.authorName,
                      category: book.categoryName,
                      heroTag: tag,
                      borderRadius: AppRadii.sm,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  book.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  book.displayAuthor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.displayPrice,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    if (book.quantityInStock != null)
                      Icon(
                        book.isInStock
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        semanticLabel: book.isInStock
                            ? 'In stock'
                            : 'Out of stock',
                        size: 16,
                        color: book.isInStock
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
