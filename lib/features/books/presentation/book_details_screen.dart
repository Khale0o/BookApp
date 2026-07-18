import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/book_atmosphere.dart';
import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/core/utils/book_hero_tags.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:bookapp/features/cart/presentation/cart_controller.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/reviews/domain/book_review.dart';
import 'package:bookapp/features/reviews/presentation/reviews_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.heroTag,
    this.initialBook,
  });
  final int? bookId;
  final Object? heroTag;
  final Book? initialBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookId == null) {
      return const _DetailsStateFrame(
        child: AsyncMessage(
          icon: Icons.menu_book_outlined,
          title: 'Invalid book address',
          message: 'The book ID in this address is not valid.',
        ),
      );
    }
    final initial = initialBook?.id == bookId ? initialBook : null;
    final state = ref.watch(bookDetailsProvider(bookId!));
    if (initial != null) {
      final refreshed = state is AsyncData<Book> ? state.value : initial;
      return _DetailsScene(book: refreshed, heroTag: heroTag);
    }
    return state.when(
      loading: () => const _DetailsLoading(),
      error: (error, stack) => _DetailsStateFrame(
        child: AsyncMessage(
          icon: error is BookNotFoundException
              ? Icons.find_in_page_outlined
              : Icons.wifi_off_rounded,
          title: error is BookNotFoundException
              ? 'Book not found'
              : 'This page could not be loaded',
          message: error is BookNotFoundException
              ? 'The requested book is no longer in the catalog.'
              : 'The bookstore did not respond as expected. Please try again.',
          actionLabel: error is BookNotFoundException ? null : 'Try again',
          onAction: error is BookNotFoundException
              ? null
              : () => ref.invalidate(bookDetailsProvider(bookId!)),
        ),
      ),
      data: (book) => _DetailsScene(book: book, heroTag: heroTag),
    );
  }
}

void _goBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    context.go(AppRoutes.home);
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton();
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Back',
    child: Material(
      color: AppColors.midnight.withValues(alpha: .64),
      shape: const CircleBorder(side: BorderSide(color: Color(0x447F8795))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _goBack(context),
        child: const SizedBox.square(
          dimension: 46,
          child: Icon(Icons.arrow_back, color: AppColors.ivory, size: 20),
        ),
      ),
    ),
  );
}

class _DetailsStateFrame extends StatelessWidget {
  const _DetailsStateFrame({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: AppSystemOverlay.immersiveDark,
    child: Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.md,
              child: _FloatingBackButton(),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailsScene extends StatefulWidget {
  const _DetailsScene({required this.book, this.heroTag});
  final Book book;
  final Object? heroTag;
  @override
  State<_DetailsScene> createState() => _DetailsSceneState();
}

class _DetailsSceneState extends State<_DetailsScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.detailsOpen,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final wide = MediaQuery.sizeOf(context).width >= AppLayout.tablet;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final palette = bookAtmosphereFor(bookId: book.id, title: book.bookTitle);
    final curve = CurvedAnimation(parent: _controller, curve: AppMotion.curve);
    final routeAnimation = ModalRoute.of(context)?.animation;
    final supportingRouteAnimation =
        reduced || routeAnimation is! Animation<double>
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(.55, 1, curve: Curves.easeOut),
          );
    final Animation<double> atmosphereRouteAnimation =
        reduced || routeAnimation is! Animation<double>
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0, .7, curve: Curves.easeOut),
            reverseCurve: const Interval(0, .9, curve: Curves.easeInOut),
          );
    final coverSettle = reduced
        ? const AlwaysStoppedAnimation<double>(1)
        : Tween<double>(begin: .985, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: AppMotion.curve),
          );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        backgroundColor: AppColors.midnight,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                key: const ValueKey('details-atmosphere'),
                height: wide ? 570 : 500,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FadeTransition(
                      opacity: atmosphereRouteAnimation,
                      child: BookAtmosphere(palette: palette),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
                      left: AppSpacing.md,
                      child: const _FloatingBackButton(),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: FadeTransition(
                        opacity: supportingRouteAnimation,
                        child: Text(
                          book.categoryName?.toUpperCase() ??
                              'LEAF & LOOM EDITION',
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFamily,
                            color: palette.accent.withValues(alpha: .96),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                    ContentShell(
                      child: Align(
                        alignment: wide
                            ? Alignment.bottomLeft
                            : Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: wide ? AppSpacing.xxl : AppSpacing.xl,
                            left: wide ? AppSpacing.xxl : 0,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: wide ? 300 : 235,
                            ),
                            child: ScaleTransition(
                              scale: coverSettle,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: .48,
                                      ),
                                      blurRadius: 32,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: BookCover(
                                  image: book.bookImage,
                                  semanticLabel:
                                      'Cover of ${book.displayTitle}',
                                  bookId: book.id,
                                  title: book.bookTitle,
                                  author: book.authorName,
                                  category: book.categoryName,
                                  heroTag: widget.heroTag,
                                  borderRadius: AppRadii.sm,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (wide)
                      FadeTransition(
                        opacity: supportingRouteAnimation,
                        child: ContentShell(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 560,
                              child: Text(
                                book.displayTitle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: AppColors.ivory.withValues(
                                        alpha: .13,
                                      ),
                                      fontSize: 72,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: supportingRouteAnimation,
                child: Transform.translate(
                  offset: const Offset(0, -34),
                  child: Container(
                    key: const ValueKey('details-info-surface'),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.sheet),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: .5),
                        ),
                      ),
                    ),
                    child: ContentShell(
                      maxWidth: 1040,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          wide ? AppSpacing.xxl : AppSpacing.lg,
                          wide ? AppSpacing.xxl : AppSpacing.xl,
                          wide ? AppSpacing.xxl : AppSpacing.lg,
                          AppSpacing.huge,
                        ),
                        child: FadeTransition(
                          opacity: reduced
                              ? const AlwaysStoppedAnimation(1)
                              : curve,
                          child: AnimatedBuilder(
                            animation: curve,
                            child: _DetailsCopy(book: book),
                            builder: (context, child) => Transform.translate(
                              offset: reduced
                                  ? Offset.zero
                                  : Offset(0, 20 * (1 - curve.value)),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCopy extends ConsumerWidget {
  const _DetailsCopy({required this.book});
  final Book book;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= AppLayout.tablet;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.readableWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 30, height: 1, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  book.categoryName?.toUpperCase() ?? 'BOOK DETAILS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _PrimaryBookAction(book: book),
          const SizedBox(height: AppSpacing.md),
          Text(
            book.displayTitle,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: wide
                ? Theme.of(context).textTheme.displayLarge
                : Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            book.displayAuthor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Meta(label: 'Price', value: book.displayPrice),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _DetailsStock(book: book)),
            ],
          ),
          if (book.publicationYear != null || book.quantityInStock != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xxl,
              runSpacing: AppSpacing.lg,
              children: [
                if (book.publicationYear != null)
                  _Meta(label: 'Published', value: '${book.publicationYear}'),
                if (book.quantityInStock != null)
                  _Meta(label: 'Quantity', value: '${book.quantityInStock}'),
              ],
            ),
          ],
          if (book.bookDescription != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'About this book',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              book.bookDescription!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (book.id != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            _ReviewsSection(bookId: book.id!),
          ],
          _RelatedBooks(
            current: book,
            books: ref.watch(homeBooksProvider).value,
          ),
        ],
      ),
    );
  }
}

class _PrimaryBookAction extends ConsumerWidget {
  const _PrimaryBookAction({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(authControllerProvider).isAuthenticated;
    final cart = ref.watch(cartControllerProvider);
    final pending = book.id != null && cart.pendingBookIds.contains(book.id);
    final available = book.quantityInStock != null && book.isInStock;
    final label = book.quantityInStock == null
        ? 'Availability not provided'
        : !book.isInStock
        ? 'Out of stock'
        : authenticated
        ? 'Add to bag'
        : 'Sign in to add to bag';
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: !available || pending || book.id == null
            ? null
            : () async {
                if (!authenticated) {
                  await context.push(AppRoutes.login);
                  return;
                }
                final added = await ref
                    .read(cartControllerProvider.notifier)
                    .addBook(book.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? '${book.displayTitle} was added to your bag.'
                            : ref.read(cartControllerProvider).errorMessage ??
                                  'The book could not be added.',
                      ),
                    ),
                  );
                }
              },
        icon: pending
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.shopping_bag_outlined),
        label: Text(label),
      ),
    );
  }
}

class _ReviewsSection extends ConsumerStatefulWidget {
  const _ReviewsSection({required this.bookId});
  final int bookId;

  @override
  ConsumerState<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<_ReviewsSection> {
  static const _pageSize = 6;
  final _reviews = <BookReview>[];
  var _page = 0;
  var _loading = true;
  var _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadMore);
  }

  Future<void> _loadMore() async {
    if ((_loading && _page > 0) || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await ref
          .read(reviewsRepositoryProvider)
          .getReviews(
            widget.bookId,
            pageNumber: _page + 1,
            pageSize: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _reviews.addAll(next);
        _page++;
        _hasMore = next.length >= _pageSize;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Reviews could not be loaded.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reader reviews',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Reviews are provided by the bookstore and are read-only.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_loading && _reviews.isEmpty)
          const LinearProgressIndicator()
        else if (_error != null && _reviews.isEmpty)
          TextButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_error!),
          )
        else if (_reviews.isEmpty)
          Text(
            'No reviews have been returned for this book.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          for (final review in _reviews) _ReviewCard(review: review),
          if (_hasMore)
            TextButton(
              onPressed: _loading ? null : _loadMore,
              child: Text(_loading ? 'Loading…' : 'Load more reviews'),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final BookReview review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.displayName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (review.ratingValue != null)
                  Semantics(
                    label: 'Rating ${review.ratingValue} out of 5',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(review.ratingValue!.toStringAsFixed(1)),
                      ],
                    ),
                  ),
              ],
            ),
            if (review.comment != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(review.comment!),
            ],
            if (review.reviewDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${review.reviewDate!.year}-${review.reviewDate!.month.toString().padLeft(2, '0')}-${review.reviewDate!.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _RelatedBooks extends StatelessWidget {
  const _RelatedBooks({required this.current, required this.books});
  final Book current;
  final List<Book>? books;

  @override
  Widget build(BuildContext context) {
    final related = (books ?? const <Book>[])
        .where(
          (book) =>
              book.id != current.id &&
              ((current.categoryName != null &&
                      book.categoryName?.toLowerCase() ==
                          current.categoryName?.toLowerCase()) ||
                  (current.authorName != null &&
                      book.authorName?.toLowerCase() ==
                          current.authorName?.toLowerCase())),
        )
        .take(6)
        .toList(growable: false);
    if (related.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Related books',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Selected from shared author or category metadata.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final book = related[index];
                final tag = relatedBookHeroTag(book);
                return SizedBox(
                  width: 104,
                  child: InkWell(
                    onTap: book.id == null
                        ? null
                        : () => context.pushReplacement(
                            AppRoutes.book(book.id!),
                            extra: BookDetailsRouteExtra(
                              book: book,
                              heroTag: tag,
                            ),
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookCover(
                          image: book.bookImage,
                          semanticLabel: 'Cover of ${book.displayTitle}',
                          bookId: book.id,
                          title: book.bookTitle,
                          author: book.authorName,
                          category: book.categoryName,
                          heroTag: tag,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          book.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsStock extends StatelessWidget {
  const _DetailsStock({required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) {
    final unknown = book.quantityInStock == null;
    final color = unknown
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (book.isInStock ? AppColors.success : AppColors.warning);
    final value = unknown
        ? 'Not provided'
        : (book.isInStock ? 'Available' : 'Out of stock');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              unknown
                  ? Icons.help_outline
                  : (book.isInStock
                        ? Icons.check_circle_outline
                        : Icons.remove_circle_outline),
              size: 17,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();
  @override
  Widget build(BuildContext context) {
    final block = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        backgroundColor: AppColors.midnight,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.midnightElevated),
                  ),
                  const Positioned(
                    top: AppSpacing.xl,
                    left: AppSpacing.md,
                    child: SafeArea(child: _FloatingBackButton()),
                  ),
                  Center(
                    child: Container(
                      width: 220,
                      height: 330,
                      decoration: BoxDecoration(
                        color: AppColors.slate,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 260,
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 110, height: 12, color: block),
                  const SizedBox(height: AppSpacing.md),
                  Container(width: double.infinity, height: 52, color: block),
                  const SizedBox(height: AppSpacing.md),
                  Container(width: 190, height: 18, color: block),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
