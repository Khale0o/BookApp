# Design system

## Direction

Midnight Editorial Luxury: near-black navy canvas, elevated blue-black surfaces, soft ivory type, pearl secondary text, thin slate borders, and champagne gold used only for selection and primary emphasis. Burgundy and emerald appear as deterministic atmospheric accents.

## Typography

- Cormorant Garamond: brand, page titles, featured titles, editorial headings, and Details title.
- Manrope: copy, metadata, prices, controls, forms, navigation, feedback, and status.

Both variable fonts are local and licensed under SIL OFL 1.1. Text styles are centralized in `AppTheme`.

## Tokens

`app_tokens.dart` centralizes semantic colors, spacing (4–72), radii, content widths, breakpoints, motion durations, curves, and dark system-overlay behavior. Common buttons, inputs, chips, sheets, focus, and snackbars are themed centrally.

## Component rules

- thin tonal borders rather than large shadows;
- stable 2:3 cover ratio and bounded metadata;
- gold only for active/primary emphasis;
- practical touch targets and visible focus;
- readable line lengths and constrained wide content;
- no fake ratings, counts, currency, fees, marketing claims, or profile data;
- no large white areas, neon, glassmorphism, heavy blur, or generic floating pills.

## Cover hierarchy

1. valid backend image;
2. attributed, title-matched bundled cover for the current nine-book API catalog;
3. deterministic code-rendered editorial fallback for unknown/future books.

The title controls fallback selection; API author text is never corrected locally.

## Responsive composition

- under 720 px: bottom destinations, compact headers, mobile filters, one/two-column catalog;
- 720–1049 px: compact rail and adaptive grids;
- 1050 px and above: rail, constrained content, multi-column grids, side filters, and wide Details composition.
