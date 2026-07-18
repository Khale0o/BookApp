# Leaf & Loom master implementation plan

## Baseline

The Phase 1 application is a clean, tested Flutter walking skeleton with Riverpod, go_router, Dio, local typography, a cinematic Home carousel, deep-linkable Book Details, deterministic image fallbacks, Hero choreography, and reduced-motion support.

Baseline recorded on 2026-07-18:

- `dart format --output=none --set-exit-if-changed .`: passed, 29 files unchanged.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed, 29 tests.
- Working tree before product work: only the user-supplied `docs/design/` directory was untracked.

## Authoritative inputs

1. `docs/design/image.png` defines the midnight editorial visual direction and screen hierarchy.
2. `docs/openapi.json` defines all server fields and operations.
3. Existing architecture and Phase 1 behavior remain the technical foundation.

The composite reference is rebuilt with responsive Flutter widgets; it is never embedded or cropped into the application.

## Delivery sequence

### Foundation and application shell

- Expand semantic color, type, spacing, radius, breakpoint, elevation, focus, and motion tokens.
- Introduce a state-preserving `StatefulShellRoute.indexedStack` for Home, Explore, Cart, and Profile.
- Use a safe-area-aware editorial bottom destination bar on phones and compact side rail at wide widths.
- Keep Details, authentication, checkout, and order details above the shell.

### Phase A — Home evolution

- Retain the approved PageController carousel and deterministic atmosphere.
- Add functional Curated, More to explore/New on the shelf, and API-derived category sections.
- Route shelf and category actions into persistent Explore state.

### Phases B–C — Explore and catalog

- Add a focused Riverpod catalog controller with documented server pagination, request de-duplication, ID de-duplication, repeated-page defence, prefetching, refresh, and later-page error preservation.
- Add persistent debounced search, normalized categories, verified filters, client/server sorting boundaries, mobile filter sheet, wide filter panel, and adaptive catalog grid.

### Phase D — Details and reviews

- Extend the approved immediate-data Details route with real metadata, authenticated cart action, read-only paged reviews, and related books derived from shared API category/author values.
- Preserve the cover-owned Hero and staged supporting-content motion.

### Phases E–I — Account and commerce

- Build defensive authentication parsing, secure session storage, central bearer interception, restoration, logout, route guards, and polished signup/login/reset flows.
- Build authenticated profile, address view/add/edit, image upload, and order history using only documented operations.
- Build cart load/add/remove plus only those quantity semantics confirmed by the backend contract; calculate and label subtotal without currency or invented fees.
- Validate checkout-session strings before external handoff; never imply payment success without a verifiable callback.
- Render orders defensively because response schemas are absent from the OpenAPI document.

### Phases J–N — Product quality

- Centralize weighted, interruptible motion and reduced-motion variants.
- Apply consistent editorial composition, responsive breakpoints, keyboard/focus behavior, semantics, scalable-text safeguards, cached imagery, scoped provider watches, and pagination performance.

### Phases O–R — Integrity, tests, documentation, audit

- Keep all server access behind clients/repositories and map failures to safe user messages.
- Add behavioral coverage for parsing, repositories, auth/session, routing, shell preservation, catalog, Details/reviews, cart, checkout validation, responsive layouts, and accessibility roles.
- Complete architecture, API, design, motion, asset, testing, QA, deployment, and portfolio documentation.
- Remove stale code and debug diagnostics; verify flashes, overflow, image fallbacks, system UI, reduced motion, deep links, state preservation, all asynchronous states, local font licensing, secrets, and final validation.

## Contract constraints that shape implementation

- Currency is absent; prices remain numeric with two decimal places.
- Book responses are bare arrays and expose no total count.
- Reviews are read-only.
- Cart documents add and remove but no explicit quantity-update or clear operation.
- Address documents add/edit/read but no delete operation.
- Login, user, cart, address, and order success response bodies are undocumented.
- The global bearer requirement appears to cover every path, including authentication paths; the client treats public auth endpoints as an explicit exception while documenting this generator ambiguity.
- Checkout returns a string; it is opened only when it parses as an allowed HTTPS URL.
- Existing seed title/author mismatches and unreachable Azure Blob URLs require backend correction.

## Phase gate

Each implementation phase ends with formatting, static analysis, the complete test suite, updated documentation, and a conventional commit when the repository remains in a safe committable state. No emulator, browser, desktop runner, or Flutter runtime is launched.
