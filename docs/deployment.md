# Deployment notes

## Configuration

The API base defaults to `https://bookstoreapi.runasp.net` and can be replaced at compile time:

```powershell
flutter build web --dart-define=BOOKSTORE_API_BASE_URL=https://api.example.com
flutter build apk --release --dart-define=BOOKSTORE_API_BASE_URL=https://api.example.com
```

No API, payment, or signing secret is required or stored by the client. Never pass secrets through `--dart-define`; compiled values are discoverable.

## Platform requirements

- Web must be served over HTTPS for `flutter_secure_storage` Web protection and must receive appropriate CORS responses from the API.
- Native release signing, package IDs, icons, privacy disclosures, and store metadata are deployment-owner responsibilities.
- External checkout requires an allowlisted HTTPS provider URL and a documented return/verification design before production use.
- Profile image selection may require platform photo-library usage descriptions and permissions according to current image_picker platform guidance.

## Pre-release gate

1. Complete `docs/manual_qa.md` on supported targets.
2. Verify backend auth/cart/order response schemas and checkout callbacks.
3. Replace or clear commercial cover rights for the intended distribution context.
4. Run `dart format .`, `flutter analyze`, and `flutter test`.
5. Scan the repository and build configuration for secrets.
6. Build the intended release artifact in CI and perform smoke testing; this implementation pass did not launch or build runtime targets.
