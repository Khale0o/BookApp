import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/book_atmosphere.dart';
import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
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
    value: AppSystemOverlay.lightHeader,
    child: Scaffold(
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
    _controller = AnimationController(vsync: this, duration: AppMotion.slow)
      ..forward();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                key: const ValueKey('details-atmosphere'),
                height: wide ? 570 : 500,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BookAtmosphere(palette: palette),
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
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .48),
                                    blurRadius: 32,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: BookCover(
                                image: book.bookImage,
                                semanticLabel: 'Cover of ${book.displayTitle}',
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
                                  : Offset(0, 14 * (1 - curve.value)),
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

class _DetailsCopy extends StatelessWidget {
  const _DetailsCopy({required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
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
    );
  }
}
