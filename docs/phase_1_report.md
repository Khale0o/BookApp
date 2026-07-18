# Phase 1 report

## Implementation summary

Phase 1 delivers a complete walking skeleton: a short branded splash, a real-API Home catalog, and deep-linkable Book Details. Home includes a real featured book and a limited curated shelf. Loading skeletons, empty, API failure, retry, not-found, missing-image, and broken-image states are included.

## Architecture

The app uses a pragmatic feature-first structure. `ApiClient` owns Dio configuration, `ApiBooksRepository` owns endpoint access and safe list selection, manual immutable `Book` models own defensive parsing and presentation helpers, and Riverpod providers expose async state. UI code never calls Dio. `go_router` centrally defines `/`, `/home`, and `/books/:bookId`.

## Design direction

The visual language is editorial and literary: deep ink and warm paper surfaces, terracotta accent, system-font editorial hierarchy, restrained borders and shadows, large cover art, generous spacing, readable line lengths, and centered wide-screen constraints. Material 3 light and dark themes follow the system setting. Brand strings and semantic design tokens are centralized.

## Motion and reduced motion

Splash uses one opacity/scale reveal and advances after 1.1 seconds. Home major sections reveal once with a small stagger and upward offset. Cards use short press scale/opacity feedback. Cover navigation uses stable context-specific Hero tags; direct detail URLs omit the Hero safely. Details copy fades upward once. When `MediaQuery.disableAnimations` is true, stagger, translation, scale exaggeration, and route transition duration are removed while feedback and navigation remain clear.

## API endpoints

- `GET /api/Books?pageNumber=1&pageSize=12`
- `GET /api/Books?bookId=<id>`

Base URL: `https://bookstoreapi.runasp.net`. The single-book array is checked for an exact ID, then the first parsed item, then an explicit not-found error. Dio uses connection, send, and receive timeouts. Debug logging excludes headers and bodies.

## Dependencies added

- `flutter_riverpod`
- `go_router`
- `dio`
- `cached_network_image`

## Tests and validation

Tests cover complete and missing model data; int, double, numeric-string, and null parsing; image URL resolution; exact/fallback/empty single-book selection; a repository-backed Riverpod state; and the stable accessible missing-cover fallback.

- `dart format .` — passed
- `flutter analyze` — passed with no issues
- `flutter test` — passed, 21 tests

No emulator, browser, desktop runtime, `flutter run`, or integration test was launched.

## Assumptions and known API limitations

- The OpenAPI contract documents a bare `Book[]`; no response envelope is assumed.
- The API does not document a currency code, so the interface displays only the numeric API value with two decimal places. Add a currency only after the backend contract confirms one.
- The backend seed data contains inconsistent title/author pairings (for example, returned titles are paired with authors of other books). The client deliberately preserves these API values; the seed data requires backend correction.
- The current first page returns four absolute Azure Blob HTTPS image values and five null values. Two image paths contain literal spaces. The resolver safely percent-encodes these values, but the returned storage hostname `bookstoreazure.blob.core.windows.net` did not resolve during Phase 1.1 diagnostics, including for paths without spaces. The backend storage host or image data must be restored/corrected for those covers to load.
- Missing stock is shown as unavailable information, not as an invented quantity. A documented zero is shown as out of stock.
- Image paths may be absolute or relative to the API origin; malformed, blank, null, and remotely broken images use stable fallbacks.
- Phase 1 intentionally excludes authentication, full catalog, search, pagination UI, cart, reviews, favorites, and purchasing actions.

## Phase 1.1 visual repair

Live payload inspection found absolute HTTPS image URLs, absolute URLs containing unescaped spaces, and null image values. The centralized resolver now also supports trimmed values, relative and filename-only paths, leading slashes, backslashes, scheme-relative URLs, and safely inferable hostnames without schemes. Debug builds log only each book ID and raw `bookImage` value; headers and response bodies remain unlogged. Cover failures use a compact neutral editorial fallback. Narrow featured content and curated cards were tightened, the inactive search affordance was removed, status-bar contrast is route/theme appropriate, and unconfirmed currency symbols were removed.

## Phase 1.2 generated covers

Missing, invalid, and failed remote images now fall back to original Flutter-rendered Leaf & Loom editorial covers. Six deterministic motifs—layered pages, arch, botanical, typographic blocks, paper waves, and geometric frame—use only title, author, and category values returned by the API. A stable book ID selects the motif; a manual title hash is used only when the ID is absent. Generated covers have no network or file work, preserve the existing aspect ratio and Hero system, and render identically in Home and Details. Valid remote images remain the first choice; the unresolved Azure Blob storage host still requires backend correction.

## Phase 1.3 signature luxury redesign

### Palette and typography

The application now uses a Midnight Editorial Luxury system. Dark mode combines near-black midnight navy, blue-black elevated surfaces, dark slate, soft ivory, pearl grey, and restrained champagne gold, with burgundy and emerald used only as controlled atmosphere accents. Light mode uses soft ivory, warm white, deep midnight text, cool grey secondary text, antique gold, and quiet borders. Generated covers retain their controlled individual art palettes.

Display typography uses Cormorant Garamond at weight 600 for the wordmark, featured titles, section headings, and the Details title. Functional typography uses Manrope weights 400, 500, 600, and 700 for body copy, authors, prices, labels, metadata, status, buttons, and compact shelf text. Both variable-font files are bundled locally from the official Google Fonts `google/fonts` repository and licensed under the SIL Open Font License 1.1. Repository copies are stored at `assets/fonts/licenses/CormorantGaramond-OFL.txt` and `assets/fonts/licenses/Manrope-OFL.txt`. No runtime font fetching is used.

### Home and carousel

Home now opens with a minimal imprint header and an edge-to-edge cinematic featured scene using the already-loaded API books. A `PageController` provides snapping, controlled adjacent-cover peeking, swipe-linked scale, very small perspective, deterministic atmosphere changes, directional selected-copy crossfades, and a compact editorial line indicator. Selection never triggers an API call. The selected book continues to expose only real API title, author, category, description, price, and stock information. The curated shelf remains a premium horizontal collection with fixed cover/card widths, bounded titles, consistent edge padding, and stable context-specific Hero tags.

### Atmosphere and Details

Each book maps deterministically from its ID, or a manual title hash when the ID is absent, to one of five palettes: midnight, burgundy, emerald, slate, or champagne. Lightweight painted fields and lines create depth without blur, shaders, image-color extraction, or random values. Details reuses the same atmosphere and cover, removes the conventional AppBar, adds a compact floating back control, and overlaps a responsive elevated information sheet over the visual opening scene. Direct links work without a Hero source.

### Motion and reduced motion

Normal motion uses transform and opacity only: swipe-linked cover pose, short atmosphere transitions, selected-copy crossfade/up movement, press response, the existing cover Hero, and Details copy reveal. With `MediaQuery.disableAnimations`, rotation, perspective, decorative translation, entrance stagger, and atmosphere duration are removed. Carousel swiping, selection, immediate press feedback, Hero-safe routing, and navigation remain available.

## Manual runtime commands

From the project root, choose one target after starting the appropriate device yourself:

```powershell
flutter pub get
flutter run -d chrome
```

For a connected Android device instead:

```powershell
flutter pub get
flutter devices
flutter run -d <device-id>
```

To review a direct details route with Flutter Web's default hash URL strategy, open `http://localhost:<printed-port>/#/books/<real-book-id>` after launch.

## Focused visual-review checklist

- Confirm splash timing, restrained reveal, and smooth move to Home.
- Confirm local Cormorant Garamond display text and Manrope functional text render on every target.
- Swipe the featured carousel in both directions; review snapping, intentional cover peeking, atmosphere changes, selected copy, and line indicator.
- Enable reduced motion and confirm swiping/selection remain functional without perspective or decorative translation.
- Review featured composition on narrow phone, tablet, and desktop widths.
- Verify real titles, authors, prices, descriptions, stock, and images from the API.
- Open featured and shelf books; confirm cover continuity and consistent back navigation.
- Open Details directly and from both carousel and shelf contexts; confirm atmosphere continuity, floating back control, lower-sheet overlap, and reverse Hero behavior.
- Refresh Home and exercise offline failure/retry plus loading skeletons.
- Review missing/broken covers without layout jumping.
- Check direct `/books/<id>`, invalid ID, and not-found behavior.
- Compare light/dark system themes, high text scaling, keyboard focus, and reduced-motion mode.
