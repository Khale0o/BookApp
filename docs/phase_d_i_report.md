# Phases D–I report — Details, auth, profile, cart, checkout, and orders

## Delivered

- Book Details preserves immediate route data, refresh, deep links, cover Hero ownership, and staged motion while adding verified metadata, authenticated Add to bag, read-only paged reviews, and related books based only on shared author/category values.
- Authentication includes signup, login, forgot/reset password, defensive token extraction, secure platform storage, restoration, logout, centralized bearer attachment, 401 clearing, form validation, busy/error states, and protected experiences.
- Profile displays actual returned account fields, loads/adds/edits documented addresses, uploads validated profile images with progress while preserving the prior profile on failure, links real order history, and signs out.
- Cart loads documented cart values, adds and removes books, prevents duplicate actions, preserves items on mutation failure, computes an accurately labelled item subtotal, and exposes loading/empty/error/retry states.
- Checkout posts the documented `Cart[]`, accepts no invented shipping/card fields, and opens an external provider only when the returned string is a strict HTTPS URI. Returning does not imply success.
- Orders defensively render actual IDs, statuses, dates, lines, quantities, and values when present. Missing undocumented fields remain absent.
- Nine current API-title covers are bundled from Open Library’s identifier-based Covers API and fully attributed. Backend images remain first choice; generated covers remain the final technical fallback.

## Backend blockers and deliberate omissions

- Authentication, account, address, cart, and order success response schemas are absent. Parsing is isolated and defensive; successful live auth requires user-owned credentials.
- Cart has add/remove endpoints but no documented quantity update or clear operation. Quantity is displayed from the server and is not mutated speculatively.
- Address deletion is not documented and is not offered.
- Checkout returns a string but documents no provider, callback, return route, or verification endpoint. No payment/order success is claimed.
- The order-list response schema is absent and order creation is not coupled to an unverifiable payment return.
- Seed title/author mismatches and the unreachable Azure Blob host still require backend correction.

## Validation

- `dart format .`: passed.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed, 45 tests.
- No Flutter runtime target was launched.
