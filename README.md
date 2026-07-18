# Leaf & Loom

Leaf & Loom is a responsive Flutter bookstore portfolio application with a midnight editorial art direction. It combines a cinematic, cover-led catalog with real API browsing, read-only reviews, secure authentication, account/address management, cart operations, external checkout handoff, and order history.

> Portfolio demonstration: this repository is not a deployed commercial bookstore and makes no claims about real users, revenue, conversion, or production payment processing.

## Screenshots

Capture final runtime screenshots after the manual QA pass:

- phone: splash, Home carousel, Home shelves, Explore search/filter, Details, Profile, Cart, Checkout;
- tablet: Home, Explore with adaptive grid, Details;
- desktop/Web: rail navigation, Explore side filters, wide Details.

The authoritative composition reference is `docs/design/image.png`; it is rebuilt with Flutter widgets and is not embedded in the app.

## Features

- state-preserving Home, Explore, Cart, and Profile shell;
- PageController-driven cinematic carousel, deterministic atmospheres, Hero transitions, and reduced motion;
- debounced API search, normalized categories, verified filters/sorting, defensive pagination, refresh, retry, and no-results states;
- responsive cover catalog and immediate-data/deep-link Book Details;
- read-only paged reviews and metadata-derived related books;
- signup, login, forgot/reset password, secure token restoration, bearer interception, 401 clearing, and logout;
- profile summary, address read/add/edit, validated profile-image upload, and order history;
- authenticated cart read/add/remove with mutation protection and item subtotal;
- strict HTTPS validation before external checkout handoff;
- attributed title-matched covers after remote failure, with deterministic generated covers as the final fallback;
- semantic labels, keyboard-friendly controls, visible focus treatment, scalable-text safeguards, and dark system UI.

## Architecture and stack

Flutter, Dart, Riverpod, go_router, Dio, cached_network_image, flutter_secure_storage, image_picker, and url_launcher. The feature-first architecture keeps widgets away from Dio: UI → Riverpod controller/provider → repository → centralized client. See [architecture](docs/architecture.md).

## API

The default backend is `https://bookstoreapi.runasp.net`. `docs/openapi.json` is the contract source. Override the base URL at build time:

```powershell
flutter run --dart-define=BOOKSTORE_API_BASE_URL=https://example.invalid
```

Prices are shown as numeric values with two decimal places because the API defines no currency. See [API contract notes](docs/api_contract_notes.md).

## Setup

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
```

Use an HTTPS origin for Web secure storage. Do not commit credentials, bearer tokens, provider secrets, or private callback URLs.

## Documentation

- [Master plan](docs/master_implementation_plan.md)
- [Architecture](docs/architecture.md)
- [Design system](docs/design_system.md)
- [Motion system](docs/motion_system.md)
- [Testing](docs/testing.md)
- [Manual QA](docs/manual_qa.md)
- [Deployment](docs/deployment.md)
- [Portfolio case study](docs/portfolio_case_study.md)
- [Cover sources](docs/assets/book_cover_sources.md)

## Known backend limitations

- Seed titles and authors are mismatched; the app preserves backend data.
- The Azure Blob cover hostname is unreachable and five book images are null.
- Auth/account/cart/address/order success response schemas are omitted.
- Cart quantity update and clear, address deletion, payment verification/callback, currency, and total catalog counts are undocumented.
- Checkout returns a string with no documented provider or success verification.

## Accessibility and performance

The product supports reduced motion, semantics, practical targets, focus treatment, adaptive phone/tablet/desktop layouts, cached remote images, bundled optimized covers, scoped animation rebuilds, state-preserving branches, and paged catalog/review loading. Final device-specific verification remains in the [manual QA checklist](docs/manual_qa.md).

## Assets

Cormorant Garamond and Manrope are bundled under the SIL Open Font License. Cover images are attributed in [book_cover_sources.md](docs/assets/book_cover_sources.md); rights remain with their respective holders and must be reconfirmed for commercial distribution.
