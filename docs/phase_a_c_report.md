# Phases A–C report — shell, Home, Explore, and catalog

## Delivered

- A `StatefulShellRoute.indexedStack` preserves Home, Explore, Cart, and Profile branches.
- Phones use a safe-area-aware editorial bottom bar; wide layouts use a compact rail.
- Home retains its approved carousel/Hero/reduced-motion behavior and adds Curated for you, publication-year-aware New on the shelf (or neutral More to explore), and categories derived from loaded API books.
- Explore provides persistent controller state, 300 ms debounced server search, normalized API categories, reset, documented stock filtering, verified-field client sorting, mobile filter sheet, wide filter panel, adaptive catalog grid, refresh, prefetching, pagination retry, and no-results states.
- Catalog pagination prevents concurrent/duplicate page requests, de-duplicates IDs, stops on short pages, detects repeated server pages, and preserves loaded books after later-page failures.

## Data boundaries

No category counts, total counts, popularity, ratings, language, page counts, discounts, or currency were introduced. The OpenAPI document lists `sortOrder` but does not define accepted values, so sorting is applied to accumulated pages in the client and that limitation is visible in contract documentation.

## Validation

- `dart format .`: passed.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed, 33 tests.
- No Flutter runtime target was launched.
