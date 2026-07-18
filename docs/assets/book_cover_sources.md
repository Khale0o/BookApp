# Book cover sources

The bundled catalog covers were retrieved on 2026-07-18 through the [Open Library Covers API](https://openlibrary.org/dev/docs/api/covers). Open Library provides cover lookup by identifiers such as ISBN. These images are used for a non-commercial portfolio demonstration; Leaf & Loom does not claim ownership of the cover artwork. Rights remain with their respective copyright holders and publishers. Reconfirm rights or replace assets before commercial distribution.

Valid backend `bookImage` values always remain the first presentation choice. These files appear only when a backend value is missing, invalid, unreachable, or fails to load. The generated editorial system remains the final technical fallback.

| API title | ISBN lookup | Bundled asset | Usage |
|---|---:|---|---|
| To Kill a Mockingbird | 9780061120084 | `assets/covers/to_kill_a_mockingbird.jpg` | Remote-image fallback |
| 1984 | 9780451524935 | `assets/covers/1984.jpg` | Remote-image fallback |
| The Great Gatsby | 9780743273565 | `assets/covers/the_great_gatsby.jpg` | Remote-image fallback |
| Pride and Prejudice | 9780141439518 | `assets/covers/pride_and_prejudice.jpg` | Remote-image fallback |
| The Hobbit | 9780547928227 | `assets/covers/the_hobbit.jpg` | Missing-image fallback |
| The Catcher in the Rye | 9780316769488 | `assets/covers/the_catcher_in_the_rye.jpg` | Missing-image fallback |
| The Lord of the Rings | 9780544003415 | `assets/covers/the_lord_of_the_rings.jpg` | Missing-image fallback |
| Harry Potter and the Philosopher's Stone | 9780747532699 | `assets/covers/harry_potter_philosophers_stone.jpg` | Missing-image fallback |
| The Martian | 9780553418026 | `assets/covers/the_martian.jpg` | Missing-image fallback |

Direct source pattern: `https://covers.openlibrary.org/b/isbn/{ISBN}-L.jpg?default=false`.

The backend currently pairs several titles with incorrect authors. Covers are selected from the exact API title only; visible author text remains the unmodified API value. Backend seed correction is required to make the complete title/author/cover presentation internally consistent.
