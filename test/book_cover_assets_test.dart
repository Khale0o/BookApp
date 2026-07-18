import 'package:bookapp/core/utils/book_cover_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known live API titles resolve to bundled attributed covers', () {
    expect(
      curatedBookCoverAsset(' The Hobbit '),
      'assets/covers/the_hobbit.jpg',
    );
    expect(curatedBookCoverAsset('1984'), 'assets/covers/1984.jpg');
  });

  test('unknown and missing titles remain on generated technical fallback', () {
    expect(curatedBookCoverAsset('An API title not yet sourced'), isNull);
    expect(curatedBookCoverAsset(null), isNull);
  });
}
