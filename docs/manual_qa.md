# Manual runtime QA

The implementation and automated audit intentionally did not launch a Flutter runtime. Complete this checklist on user-controlled targets before publishing screenshots.

## Targets

- narrow Android phone (~320–360 logical px);
- standard/large phone (~390–430 px);
- tablet portrait and landscape;
- Chrome desktop at 1024, 1280, and 1440 px;
- resizable Windows/macOS desktop if included in the portfolio.

## Core flow

1. Verify splash icon contrast and one restrained reveal.
2. Swipe Home carousel both ways; confirm adjacent peeking, selected metadata, local/remote covers, indicator, and no settle jump.
3. Switch Home → Explore → Cart → Profile → Home; confirm carousel, scroll, query, filter, sorting, and loaded pages are retained.
4. Exercise Explore search clear/keyboard action, categories, sort, stock filter, reset, pull-to-refresh, pagination, no-results, offline initial error, and later-page retry.
5. Open Details from carousel, shelf, catalog, and a direct URL; confirm immediate in-app data, deep-link loading, Hero continuity, back transition, reviews, related books, stock gating, and no text ghosting.
6. Sign up/login only with user-owned test credentials. Restart the app to verify restoration; test invalid/expired session and logout.
7. Review Profile fields, add/edit address, cancel forms, upload valid/invalid/oversize images, and confirm the prior image remains after failure.
8. Add an in-stock book, prevent duplicate taps, load Cart, remove an item, and verify the numeric subtotal. Confirm quantity is read-only pending backend semantics.
9. Create checkout only with a disposable test cart. Confirm non-HTTPS output is rejected and no return is labelled successful without backend verification.
10. Review empty and populated Orders using actual backend values only.

## Visual and accessibility

- Test 100%, 150%, and 200% text scaling; inspect long titles, forms, bottom destinations, catalog cards, Cart, and Details.
- Enable reduced motion; verify decorative perspective/travel/stagger disappears while all controls work.
- Traverse Web/Desktop by keyboard; verify logical order and visible focus.
- Use TalkBack/VoiceOver on navigation, covers, stock, ratings returned by reviews, image upload, remove controls, and form errors.
- Verify status-bar icons remain light on every dark route and no white frame flashes during push/pop.
- Inspect hover/press/focus, minimum targets, contrast, landscape insets, notches, and software keyboard avoidance.

## Backend-specific checks

- Record the actual successful login token shape and user/cart/address/order response bodies without logging credentials or authorization headers.
- Confirm whether repeated POST `/api/Users/Cart/{bookId}` increments quantity and whether DELETE removes one unit or the entire line before enabling quantity controls.
- Confirm checkout provider URL, callback/return scheme, payment verification, cart clearing, and order-creation ownership.
- Confirm Azure Blob DNS/storage restoration and correct seed title/author pairings.
