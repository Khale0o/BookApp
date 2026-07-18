String? curatedBookCoverAsset(String? title) {
  final key = title?.trim().toLowerCase();
  return const <String, String>{
    'to kill a mockingbird': 'assets/covers/to_kill_a_mockingbird.jpg',
    '1984': 'assets/covers/1984.jpg',
    'the great gatsby': 'assets/covers/the_great_gatsby.jpg',
    'pride and prejudice': 'assets/covers/pride_and_prejudice.jpg',
    'the hobbit': 'assets/covers/the_hobbit.jpg',
    'the catcher in the rye': 'assets/covers/the_catcher_in_the_rye.jpg',
    'the lord of the rings': 'assets/covers/the_lord_of_the_rings.jpg',
    "harry potter and the philosopher's stone":
        'assets/covers/harry_potter_philosophers_stone.jpg',
    'the martian': 'assets/covers/the_martian.jpg',
  }[key];
}
