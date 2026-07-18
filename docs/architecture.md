# Architecture

## Shape

Leaf & Loom uses a pragmatic feature-first structure:

```text
presentation widgets
  → Riverpod providers/controllers and immutable state
    → feature repository interfaces
      → API repository implementations
        → centralized Dio client + bearer interceptor
```

UI code never calls Dio. Models own defensive conversion of nullable values, numeric strings, unexpected numeric types, and undocumented response envelopes. Repository interfaces make controllers testable without a runtime or network.

## Navigation

`StatefulShellRoute.indexedStack` owns four preserved branches:

- `/home`
- `/explore`
- `/cart`
- `/profile`

Full experiences sit above the shell:

- `/books/:bookId`
- `/auth/login`, `/auth/signup`, `/auth/forgot-password`, `/auth/reset-password`
- `/checkout`
- `/orders`

Book routes accept a typed `BookDetailsRouteExtra`. Matching initial data renders immediately while a repository refresh runs; mismatched path/extra IDs are rejected. Direct links fetch by ID. Details alone owns the supporting route surface while the cover owns the Hero.

## State ownership

- Home books: `FutureProvider`, retained while the indexed branch remains mounted.
- Explore: `CatalogController` owns persistent query, category, sort, stock filter, accumulated pages, de-duplication, end detection, and later-page errors.
- Auth: `AuthController` restores and clears the platform-secured bearer session.
- Cart: `CartController` owns server items and per-book mutation locks.
- Account: `AccountController` owns profile, addresses, and upload state.
- Details/reviews/orders use focused providers or local paged state with repository boundaries.

## Security

`BearerTokenInterceptor` skips token-acquisition routes, reads the current token for protected calls, and clears storage after a protected 401. Native and Web storage use `flutter_secure_storage`; Web deployment must use HTTPS. Headers and bodies are excluded from debug logging, and tokens/credentials are never printed.

## Failure strategy

`mapApiFailure` converts connectivity and HTTP status families into restrained user copy. Raw response bodies are not surfaced. Initial, later-page, empty, not-found, offline, mutation, image, and retry states preserve useful prior data whenever possible.

## Known architectural constraints

The generated OpenAPI document omits success response schemas for authenticated resources. Defensive parser tolerance is isolated in data layers so verified future schemas can replace it without rewriting presentation code.
