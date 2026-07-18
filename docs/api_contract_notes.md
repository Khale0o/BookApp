# API contract notes

Source: `docs/openapi.json`. Base API used by the existing app: `https://bookstoreapi.runasp.net`.

## Verified contract surface

- Books: paged/searchable/filterable `GET /api/Books`, read-by-query `bookId`, administrative mutation endpoints, image upload, and paged read-only reviews.
- Authentication: signup, login, forgot password, and reset password input DTOs. Success response bodies are not described.
- User: user info/update, address read/add/edit, cart read/add/remove, orders read/create/update, and profile-image upload. Success response bodies are not described.
- Checkout: accepts `Cart[]` and returns a string.

## Deliberate client constraints

- No currency code or symbol is attached to numeric prices.
- No total book/review count is assumed.
- No rating filter, bestseller status, language, page count, ISBN, publisher, discount, tax, shipping fee, saved payment method, tracking state, or delivery estimate is invented.
- Reviews are read-only because no review mutation endpoint exists.
- Address deletion is omitted because no delete endpoint exists.
- Cart quantity update and clear-all are not assumed. The documented add/remove path is kept behind a repository so verified live semantics can be introduced without changing UI ownership.
- Checkout output is not assumed to be a URL. External navigation is allowed only after strict HTTPS URI validation.
- Order/user/cart/address response parsing is defensive because response schemas are omitted.

## Security ambiguity

The OpenAPI document declares a global bearer security requirement and does not override it on signup/login/reset routes. Requiring a bearer token to acquire a bearer token is internally inconsistent and likely a generated-document omission. The client excludes authentication acquisition routes from token attachment and attaches a restored bearer token centrally elsewhere. Tokens, credentials, authorization headers, and response bodies are never logged.

## Known backend data issues

- Seed titles and authors contain mismatched pairings. The client preserves server values unchanged.
- Four observed Azure Blob image URLs use an unreachable hostname and five observed books contain null image values. Valid remote images remain first choice; a deterministic editorial cover is the fallback.
- Two observed image paths contained literal spaces; the centralized resolver safely percent-encodes them.
