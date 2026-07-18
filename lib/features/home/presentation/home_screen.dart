import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/config/app_config.dart';
import 'package:bookapp/core/utils/book_hero_tags.dart';
import 'package:bookapp/core/widgets/async_message.dart';
import 'package:bookapp/core/widgets/book_atmosphere.dart';
import 'package:bookapp/core/widgets/book_cover.dart';
import 'package:bookapp/core/widgets/content_shell.dart';
import 'package:bookapp/features/books/domain/book.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/explore/presentation/catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(homeBooksProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.immersiveDark,
      child: Scaffold(
        backgroundColor: AppColors.midnight,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(homeBooksProvider.future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _EntranceReveal(
                    animation: _entrance,
                    interval: const Interval(0, .4),
                    child: const _MinimalHeader(),
                  ),
                ),
                books.when(
                  loading: () =>
                      const SliverToBoxAdapter(child: _HomeSkeleton()),
                  error: (error, stack) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: AsyncMessage(
                      icon: Icons.wifi_off_rounded,
                      title: 'The shelves are out of reach',
                      message:
                          'We could not contact the bookstore. Check your connection and try once more.',
                      actionLabel: 'Try again',
                      onAction: () => ref.invalidate(homeBooksProvider),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AsyncMessage(
                          icon: Icons.library_books_outlined,
                          title: 'A quiet shelf',
                          message: 'There are no books in the catalog yet.',
                        ),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _EntranceReveal(
                            animation: _entrance,
                            interval: const Interval(.1, .76),
                            child: FeaturedCarousel(books: items),
                          ),
                          _EntranceReveal(
                            animation: _entrance,
                            interval: const Interval(.32, 1),
                            child: _CuratedShelf(
                              title: 'Curated for you',
                              subtitle:
                                  'A measured selection from the current collection.',
                              books: items
                                  .skip(1)
                                  .take(8)
                                  .toList(growable: false),
                              onSeeAll: () => context.go(AppRoutes.explore),
                            ),
                          ),
                          _CuratedShelf(
                            title:
                                items.any(
                                  (book) => book.publicationYear != null,
                                )
                                ? 'New on the shelf'
                                : 'More to explore',
                            subtitle:
                                items.any(
                                  (book) => book.publicationYear != null,
                                )
                                ? 'Recent publication years from the current catalog.'
                                : 'Continue through the collection.',
                            books:
                                (items.any(
                                          (book) =>
                                              book.publicationYear != null,
                                        )
                                        ? ([...items]..sort(
                                            (a, b) => (b.publicationYear ?? -1)
                                                .compareTo(
                                                  a.publicationYear ?? -1,
                                                ),
                                          ))
                                        : items.reversed.toList())
                                    .take(8)
                                    .toList(growable: false),
                            onSeeAll: () => context.go(AppRoutes.explore),
                          ),
                          _CategorySection(
                            books: items,
                            onSelected: (category) {
                              ref
                                  .read(catalogControllerProvider.notifier)
                                  .setCategory(category);
                              context.go(AppRoutes.explore);
                            },
                          ),
                          const SizedBox(height: AppSpacing.huge),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntranceReveal extends StatelessWidget {
  const _EntranceReveal({
    required this.animation,
    required this.interval,
    required this.child,
  });
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}

class _MinimalHeader extends StatelessWidget {
  const _MinimalHeader();

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const ValueKey('home-header-surface'),
    color: Theme.of(context).colorScheme.surface,
    child: ContentShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                AppConfig.appName,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(letterSpacing: .25),
              ),
            ),
            Text(
              'EDITORIAL BOOKS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

@immutable
class CarouselPose {
  const CarouselPose({
    required this.scale,
    required this.rotationY,
    required this.translationX,
    required this.translationY,
    required this.opacity,
  });
  final double scale;
  final double rotationY;
  final double translationX;
  final double translationY;
  final double opacity;
}

CarouselPose carouselPoseFor(double pageOffset, {required bool reducedMotion}) {
  final distance = pageOffset.abs().clamp(0.0, 1.0);
  if (reducedMotion) {
    return const CarouselPose(
      scale: 1,
      rotationY: 0,
      translationX: 0,
      translationY: 0,
      opacity: 1,
    );
  }
  return CarouselPose(
    scale: 1.035 - distance * .115,
    rotationY: pageOffset.clamp(-1.0, 1.0) * -.026,
    translationX: pageOffset * -8,
    translationY: distance * 14,
    opacity: 1 - distance * .28,
  );
}

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    super.key,
    required this.books,
    this.onSelectionChanged,
  });
  final List<Book> books;
  final ValueChanged<Book>? onSelectionChanged;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late final PageController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .54);
  }

  @override
  void didUpdateWidget(covariant FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.books.length) {
      _selectedIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.books[_selectedIndex];
    final palette = bookAtmosphereFor(
      bookId: selected.id,
      title: selected.bookTitle,
    );
    final wide = MediaQuery.sizeOf(context).width >= AppLayout.tablet;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedContainer(
      key: const ValueKey('featured-carousel'),
      duration: reduced ? Duration.zero : AppMotion.standard,
      color: palette.base,
      child: Stack(
        children: [
          Positioned.fill(
            child: BookAtmosphere(
              palette: palette,
              duration: reduced ? Duration.zero : AppMotion.standard,
            ),
          ),
          Positioned(
            top: 22,
            right: 24,
            child: Text(
              '${(_selectedIndex + 1).toString().padLeft(2, '0')} / ${widget.books.length.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontFamily: AppTypography.bodyFamily,
                color: AppColors.ivory.withValues(alpha: .9),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ContentShell(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: wide ? AppSpacing.xxl : AppSpacing.xl,
              ),
              child: wide
                  ? Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: _carouselStage(
                            controller: _controller,
                            books: widget.books,
                            selectedIndex: _selectedIndex,
                            reducedMotion: reduced,
                            height: 470,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxl),
                        Expanded(
                          flex: 5,
                          child: _SelectedBookInfo(
                            book: selected,
                            palette: palette,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _carouselStage(
                          controller: _controller,
                          books: widget.books,
                          selectedIndex: _selectedIndex,
                          reducedMotion: reduced,
                          height: 300,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SelectedBookInfo(book: selected, palette: palette),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(int index) {
    setState(() => _selectedIndex = index);
    widget.onSelectionChanged?.call(widget.books[index]);
  }

  Widget _carouselStage({
    required PageController controller,
    required List<Book> books,
    required int selectedIndex,
    required bool reducedMotion,
    required double height,
  }) {
    return Column(
      children: [
        SizedBox(
          key: const ValueKey('carousel-stage'),
          height: height,
          child: PageView.builder(
            controller: controller,
            itemCount: books.length,
            allowImplicitScrolling: true,
            onPageChanged: _select,
            itemBuilder: (context, index) {
              final book = books[index];
              return AnimatedBuilder(
                animation: controller,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.lg,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .38),
                          blurRadius: 24,
                          offset: const Offset(0, 18),
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
                      heroTag: carouselBookHeroTag(book),
                      borderRadius: AppRadii.sm,
                    ),
                  ),
                ),
                builder: (context, child) {
                  final page =
                      controller.hasClients &&
                          controller.position.hasContentDimensions
                      ? (controller.page ?? selectedIndex.toDouble())
                      : selectedIndex.toDouble();
                  final pose = carouselPoseFor(
                    index - page,
                    reducedMotion: reducedMotion,
                  );
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, .0007)
                    ..translateByDouble(pose.translationX, 0, 0, 1)
                    ..rotateY(pose.rotationY)
                    ..scaleByDouble(pose.scale, pose.scale, 1, 1);
                  return Opacity(
                    opacity: pose.opacity,
                    child: Transform.translate(
                      offset: Offset(0, pose.translationY),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: transform,
                        child: child,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _EditorialIndicator(count: books.length, selectedIndex: selectedIndex),
      ],
    );
  }
}

class _EditorialIndicator extends StatelessWidget {
  const _EditorialIndicator({required this.count, required this.selectedIndex});
  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Book ${selectedIndex + 1} of $count',
    child: SizedBox(
      height: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AppMotion.quick,
              width: index == selectedIndex ? 28 : 10,
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: index == selectedIndex
                  ? AppColors.gold
                  : AppColors.pearl.withValues(alpha: .34),
            ),
        ],
      ),
    ),
  );
}

class _SelectedBookInfo extends StatelessWidget {
  const _SelectedBookInfo({required this.book, required this.palette});
  final Book book;
  final BookAtmospherePalette palette;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : AppMotion.selectedCopy,
      switchInCurve: AppMotion.curve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: reduced
            ? child
            : SlideTransition(
                position: Tween(
                  begin: const Offset(.025, .04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
      ),
      child: ConstrainedBox(
        key: ValueKey('selected-info-${book.id ?? book.displayTitle}'),
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 26, height: 1, color: palette.accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  book.categoryName?.toUpperCase() ?? 'SELECTED EDITION',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFamily,
                    color: palette.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              book.displayTitle,
              key: const ValueKey('selected-title'),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: AppColors.ivory),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              book.displayAuthor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.pearl.withValues(alpha: .92),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (book.bookDescription != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                book.bookDescription!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.pearl.withValues(alpha: .84),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  book.displayPrice,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.ivory),
                ),
                _StockLabel(book: book, onDark: true),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: book.id == null
                  ? null
                  : () => context.push(
                      AppRoutes.book(book.id!),
                      extra: BookDetailsRouteExtra(
                        book: book,
                        heroTag: carouselBookHeroTag(book),
                      ),
                    ),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.book, this.onDark = false});
  final Book book;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final unknown = book.quantityInStock == null;
    final color = unknown
        ? (onDark
              ? AppColors.pearl.withValues(alpha: .82)
              : Theme.of(context).colorScheme.onSurfaceVariant)
        : (book.isInStock ? AppColors.success : AppColors.warning);
    final label = unknown
        ? 'Stock unavailable'
        : (book.isInStock ? 'In stock' : 'Out of stock');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          unknown
              ? Icons.help_outline
              : (book.isInStock
                    ? Icons.check_circle_outline
                    : Icons.remove_circle_outline),
          size: 15,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _CuratedShelf extends StatefulWidget {
  const _CuratedShelf({
    required this.title,
    required this.subtitle,
    required this.books,
    required this.onSeeAll,
  });
  final String title;
  final String subtitle;
  final List<Book> books;
  final VoidCallback onSeeAll;

  @override
  State<_CuratedShelf> createState() => _CuratedShelfState();
}

class _CuratedShelfState extends State<_CuratedShelf>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: AppMotion.shelfReveal,
    )..forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ColoredBox(
      key: ValueKey(
        widget.title == 'Curated for you'
            ? 'shelf-surface'
            : 'shelf-surface-${widget.title}',
      ),
      color: Theme.of(context).colorScheme.surface,
      child: ContentShell(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAll,
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                key: ValueKey(
                  widget.title == 'Curated for you'
                      ? 'curated-shelf'
                      : 'shelf-${widget.title}',
                ),
                height: 390,
                child: ListView.separated(
                  clipBehavior: Clip.hardEdge,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  itemCount: widget.books.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) => _ShelfReveal(
                    animation: _revealController,
                    index: index,
                    reducedMotion: reduced,
                    child: SizedBox(
                      width: 176,
                      child: _ShelfBookCard(
                        book: widget.books[index],
                        index: index,
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

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.books, required this.onSelected});

  final List<Book> books;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final unique = <String, String>{};
    for (final book in books) {
      final category = book.categoryName?.trim();
      if (category == null || category.isEmpty) continue;
      unique.putIfAbsent(category.toLowerCase(), () => category);
    }
    final categories = unique.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (categories.isEmpty) return const SizedBox.shrink();
    return ContentShell(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by category',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Explore categories represented in the loaded collection.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final category in categories)
                  Semantics(
                    button: true,
                    label: 'Explore $category books',
                    child: OutlinedButton.icon(
                      onPressed: () => onSelected(category),
                      icon: const Icon(Icons.menu_book_outlined, size: 17),
                      label: Text(category),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfReveal extends StatelessWidget {
  const _ShelfReveal({
    required this.animation,
    required this.index,
    required this.reducedMotion,
    required this.child,
  });
  final Animation<double> animation;
  final int index;
  final bool reducedMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reducedMotion) return child;
    final start = (index * .07).clamp(0.0, .42).toDouble();
    final end = (start + .58).clamp(0.0, 1.0).toDouble();
    final reveal = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: AppMotion.curve),
    );
    return AnimatedBuilder(
      animation: reveal,
      child: child,
      builder: (context, child) => Opacity(
        opacity: reveal.value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - reveal.value)),
          child: child,
        ),
      ),
    );
  }
}

class _ShelfBookCard extends StatefulWidget {
  const _ShelfBookCard({required this.book, required this.index});
  final Book book;
  final int index;
  @override
  State<_ShelfBookCard> createState() => _ShelfBookCardState();
}

class _ShelfBookCardState extends State<_ShelfBookCard> {
  bool _pressed = false;
  bool _opening = false;

  Future<void> _openBook(Book book, Object tag, bool reduced) async {
    if (_opening || book.id == null) return;
    setState(() {
      _pressed = false;
      _opening = true;
    });
    if (!reduced) {
      await Future<void>.delayed(AppMotion.press);
    }
    if (!mounted) return;
    await context.push(
      AppRoutes.book(book.id!),
      extra: BookDetailsRouteExtra(book: book, heroTag: tag),
    );
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final tag = shelfBookHeroTag(book, widget.index);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: book.id != null,
      label: 'Open ${book.displayTitle} by ${book.displayAuthor}',
      child: GestureDetector(
        key: ValueKey('shelf-card-${book.id ?? 'unknown'}-${widget.index}'),
        onTapDown: book.id == null
            ? null
            : (details) => setState(() => _pressed = true),
        onTapCancel: book.id == null
            ? null
            : () => setState(() => _pressed = false),
        onTapUp: book.id == null
            ? null
            : (details) => _openBook(book, tag, reduced),
        child: AnimatedScale(
          duration: AppMotion.press,
          curve: AppMotion.curve,
          scale: _opening && !reduced ? 1.012 : (_pressed ? .985 : 1),
          child: AnimatedOpacity(
            duration: AppMotion.press,
            opacity: _pressed ? .82 : 1,
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
                  borderRadius: AppRadii.sm,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 42,
                  child: Text(
                    book.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
                    if (book.quantityInStock != null && !book.isInStock)
                      const Icon(
                        Icons.remove_circle_outline,
                        semanticLabel: 'Out of stock',
                        size: 16,
                        color: AppColors.warning,
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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) {
    final block = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: [
        Container(
          height: 610,
          color: AppColors.midnightElevated,
          child: Center(
            child: Container(
              width: 190,
              height: 285,
              decoration: BoxDecoration(
                color: block.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
          ),
        ),
        ContentShell(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 220, height: 32, color: block),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 280,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == 2 ? 0 : AppSpacing.md,
                            ),
                            child: Container(color: block),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
