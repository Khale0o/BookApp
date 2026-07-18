# Leaf & Loom

Leaf & Loom is a responsive Flutter bookstore app built as a portfolio project.

The goal was to create something that feels closer to a real product than a typical demo app: a dark editorial interface, smooth book transitions, responsive layouts, and real API integration across browsing, authentication, cart, profile, and checkout flows.

> This is a portfolio project, not a live commercial bookstore. Payment completion and some account operations depend on the capabilities of the connected backend.

## Highlights

- Cinematic Home carousel with animated book covers
- Responsive layouts for mobile, tablet, and web
- Search, categories, sorting, filters, and paginated results
- Book Details with reviews and related books
- Login, signup, password recovery, and session restoration
- Profile information, addresses, and profile image upload
- Cart management and external checkout handoff
- Order history
- Reduced-motion support and keyboard-friendly navigation
- Loading, empty, error, retry, and no-results states

## Tech Stack

- Flutter and Dart
- Riverpod
- go_router
- Dio
- cached_network_image
- flutter_secure_storage
- image_picker
- url_launcher

The project follows a feature-first architecture:

```text
UI → Riverpod state → Repository → API client
```

Widgets do not call the API directly.

More details are available in [docs/architecture.md](docs/architecture.md).

## API

The app currently connects to:

```text
https://bookstoreapi.runasp.net
```

A different API URL can be provided at build time:

```powershell
flutter run --dart-define=BOOKSTORE_API_BASE_URL=https://your-api-url.com
```

The backend does not provide a currency code, so prices are displayed as numeric values only.

## Run Locally

```powershell
flutter pub get
flutter run
```

Run the project checks with:

```powershell
dart format .
flutter analyze
flutter test
```

## Project Structure

```text
lib/
├── app/
├── core/
└── features/
```

Each feature owns its presentation, state, models, and data access where appropriate.

## Documentation

- [Architecture](docs/architecture.md)
- [API notes](docs/api_contract_notes.md)
- [Design system](docs/design_system.md)
- [Motion system](docs/motion_system.md)
- [Testing](docs/testing.md)
- [Manual QA](docs/manual_qa.md)
- [Deployment](docs/deployment.md)
- [Portfolio case study](docs/portfolio_case_study.md)
- [Book cover sources](docs/assets/book_cover_sources.md)

## Known Limitations

The current backend has a few limitations that affect the app:

- Some book titles and authors do not match correctly
- Several original cover-image URLs are missing or unavailable
- Some authenticated response schemas are not documented
- Cart quantity updates and cart clearing are not defined
- The API does not provide a currency code
- Checkout does not provide a documented payment callback or verification flow

The app handles these cases without inventing missing data.

## Assets

Cormorant Garamond and Manrope are included under the SIL Open Font License.

Fallback book-cover sources are documented in [docs/assets/book_cover_sources.md](docs/assets/book_cover_sources.md).