import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/core/utils/image_url_resolver.dart';
import 'package:bookapp/core/utils/book_cover_assets.dart';
import 'package:bookapp/core/widgets/generated_editorial_cover.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.bookId,
    this.title,
    this.author,
    this.category,
    this.heroTag,
    this.borderRadius = AppRadii.sm,
  });

  final String? image;
  final String semanticLabel;
  final int? bookId;
  final String? title;
  final String? author;
  final String? category;
  final Object? heroTag;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);
    final cover = Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
        child: Semantics(
          image: true,
          label: semanticLabel,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: _CoverImage(
                url: resolveBookImageUrl(image),
                bookId: bookId,
                title: title,
                author: author,
                category: category,
              ),
            ),
          ),
        ),
      ),
    );
    if (heroTag == null) return cover;
    return Hero(
      tag: heroTag!,
      transitionOnUserGestures: true,
      flightShuttleBuilder:
          (flightContext, animation, direction, fromContext, toContext) {
            final hero =
                (direction == HeroFlightDirection.push
                        ? fromContext.widget
                        : toContext.widget)
                    as Hero;
            Widget shuttle = Theme(
              data: theme,
              child: Material(
                type: MaterialType.transparency,
                child: DefaultTextStyle(
                  style: (theme.textTheme.bodyMedium ?? const TextStyle())
                      .copyWith(
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                  child: hero.child,
                ),
              ),
            );
            if (mediaQuery != null) {
              shuttle = MediaQuery(data: mediaQuery, child: shuttle);
            }
            return shuttle;
          },
      child: cover,
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.url,
    this.bookId,
    this.title,
    this.author,
    this.category,
  });
  final String? url;
  final int? bookId;
  final String? title;
  final String? author;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = _CoverFallback(
      bookId: bookId,
      title: title,
      author: author,
      category: category,
    );
    if (url == null) return fallback;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: AppMotion.standard,
      placeholder: (context, url) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: scheme.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => fallback,
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({this.bookId, this.title, this.author, this.category});
  final int? bookId;
  final String? title;
  final String? author;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final asset = curatedBookCoverAsset(title);
    final generated = GeneratedEditorialCover(
      bookId: bookId,
      title: title,
      author: author,
      category: category,
    );
    if (asset == null) return generated;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => generated,
    );
  }
}
