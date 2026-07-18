abstract final class AppConfig {
  static const appName = 'Leaf & Loom';
  static const browsingMessage = 'Stories worth lingering over.';
  static const apiBaseUrl = String.fromEnvironment(
    'BOOKSTORE_API_BASE_URL',
    defaultValue: 'https://bookstoreapi.runasp.net',
  );
  static const homePageSize = 12;
}
