# Testing

## Commands

```powershell
dart format .
flutter analyze
flutter test
```

No emulator, browser, desktop application, or Flutter runtime is required for automated validation.

## Coverage

- defensive Book, review, cart, account, address, and order parsing;
- image URL resolution, bundled-cover selection, generated fallbacks, and Hero shuttle text safety;
- repository single-book selection and provider boundaries;
- deterministic cover/atmosphere selection and carousel/reduced-motion values;
- immediate Details data, direct Details loading, mismatched route extras, and system overlay roles;
- category normalization, verified sorting/filtering, pagination de-duplication, and repeated-page defence;
- auth token response tolerance, session restoration/logout, bearer attachment, public auth exclusion, and 401 clearing;
- cart subtotal and defensive envelopes;
- strict checkout URL validation;
- narrow Home overflow, shelf navigation, text roles, and typography.

## Test principles

Tests assert behavior and integrity boundaries rather than inflating counts. Network and secure-storage dependencies are replaced with fakes where required. Live credentials and payment calls are never used in automated tests.

## Remaining manual coverage

Platform plugin behavior, keyboard traversal on real desktop/Web, Android system bars, external payment return, authenticated backend response shapes, image upload, and real-device text scaling require the manual QA pass.
