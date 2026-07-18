# Leaf & Loom portfolio case study

## Problem

An approved Flutter walking skeleton had strong cinematic Home/Details motion but stopped before becoming a believable product. The backend was sparse and inconsistent: unreachable cover storage, null images, mismatched title/author seed values, undocumented authenticated response bodies, and no currency or checkout verification contract.

## Product direction

The solution adapts an eleven-screen visual reference into a responsive midnight editorial bookstore. The interface favors covers, restrained champagne emphasis, local literary typography, compact navigation, quiet borders, and realistic density rather than generic Material cards or fabricated commerce data.

## Design decisions

- Preserve the approved carousel, deterministic atmosphere, generated fallback technology, Hero choreography, and dark themes.
- Introduce a state-preserving four-destination shell and rebuild reference compositions with widgets.
- Source title-matched portfolio covers through Open Library while retaining backend-image priority and documenting rights.
- Keep every price currency-neutral and every category/count/status tied to actual server values.

## Architecture decisions

Riverpod controllers own persistent catalog, auth, cart, and account state. Repositories isolate every API operation and undocumented response tolerance. go_router owns deep links, typed initial Details data, indexed branches, and full-screen commerce/account routes. A centralized Dio interceptor handles the restored bearer token and protected 401s.

## API challenges

The catalog exposes useful query fields but no total count or sort vocabulary. Client sorting therefore applies to accumulated pages. Authenticated success schemas are absent, so response parsing remains defensive and isolated. Cart quantity mutation and payment verification are intentionally not guessed. Seed mismatches remain visible for backend correction.

## Animation system

PageController interpolation creates continuous cover pose and atmosphere. Details lets the cover Hero own the transition while supporting content is delayed and exits early. Central tokens keep feedback short and weighted. Reduced motion removes perspective, travel, stagger, and exaggerated scale without removing interaction.

## Accessibility and performance

The app uses semantic cover/control labels, live feedback regions, practical targets, focus theming, scalable card sizing, dark system UI, keyboard-safe forms, constrained reading widths, cached imagery, optimized local covers, paged data, scoped watches, and state-preserving shell branches.

## Testing and outcome

Automated tests cover parsers, repositories, pagination integrity, deterministic visuals, route data, session storage behavior, bearer interception, cart totals, strict checkout destinations, narrow layouts, typography, contrast roles, and reduced motion. Static analysis and the complete test suite pass without launching a runtime.

The result is a coherent portfolio-grade implementation and an honest boundary around what the backend still cannot prove. Future improvements should begin with formal authenticated response schemas, cart quantity semantics, payment verification, seed correction, and restored image storage—not invented client features.
