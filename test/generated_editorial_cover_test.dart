import 'package:bookapp/core/widgets/generated_editorial_cover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('style selection is deterministic for the same book', () {
    final first = editorialCoverStyleFor(bookId: 42, title: 'A title');
    final second = editorialCoverStyleFor(
      bookId: 42,
      title: 'A different title',
    );
    expect(first, second);
  });

  test('different IDs always map to valid style values', () {
    final styles = <EditorialCoverStyle>{
      for (var id = 0; id < 30; id++) editorialCoverStyleFor(bookId: id),
    };
    expect(styles, isNotEmpty);
    expect(styles.every(EditorialCoverStyle.values.contains), isTrue);
  });

  test('title fallback is stable when an ID is missing', () {
    expect(
      editorialCoverStyleFor(title: 'A stable title'),
      editorialCoverStyleFor(title: 'A stable title'),
    );
  });
}
