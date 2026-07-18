import 'package:bookapp/core/utils/image_url_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves observed and supported book image formats safely', () {
    const base = 'https://example.test';
    expect(
      resolveBookImageUrl(' https://cdn.test/a.jpg ', baseUrl: base),
      'https://cdn.test/a.jpg',
    );
    expect(
      resolveBookImageUrl('https://cdn.test/the great book.jpg', baseUrl: base),
      'https://cdn.test/the%20great%20book.jpg',
    );
    expect(
      resolveBookImageUrl('/images/a cover.jpg', baseUrl: base),
      'https://example.test/images/a%20cover.jpg',
    );
    expect(
      resolveBookImageUrl('images\\a.jpg', baseUrl: base),
      'https://example.test/images/a.jpg',
    );
    expect(
      resolveBookImageUrl('cover.jpg', baseUrl: base),
      'https://example.test/cover.jpg',
    );
    expect(
      resolveBookImageUrl('cdn.test/covers/a.jpg', baseUrl: base),
      'https://cdn.test/covers/a.jpg',
    );
    expect(
      resolveBookImageUrl('//cdn.test/covers/a.jpg', baseUrl: base),
      'https://cdn.test/covers/a.jpg',
    );
    expect(resolveBookImageUrl('  ', baseUrl: base), isNull);
    expect(resolveBookImageUrl(null, baseUrl: base), isNull);
    expect(resolveBookImageUrl('file:///private/a.jpg', baseUrl: base), isNull);
  });
}
