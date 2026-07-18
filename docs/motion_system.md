# Motion system

Motion is weighted, subtle, interruptible, and purposeful. Durations and curves live in `AppMotion`; no heavy animation package is used.

## Behaviors

- Splash: one restrained brand reveal.
- Home: PageController interpolation drives cover scale, opacity, vertical pose, restrained perspective, selected copy, atmosphere, and line indicator without API calls.
- Shelves/catalog: short press/hover feedback and a one-time restrained reveal.
- Details: the cover Hero owns the major transition; atmosphere and supporting content enter after it and exit early on reverse navigation.
- Shell: selected destination uses restrained scale/color emphasis while branch state remains mounted.
- Cart: mutations use opacity/progress feedback without bounce.

## Reduced motion

`MediaQuery.disableAnimations` removes perspective, decorative translation, large scale differences, and stagger. It preserves swiping, selection, feedback, navigation, and Hero-safe route behavior. Zero-duration route transitions are used where appropriate.

## Performance discipline

Animation rebuilds are scoped through `AnimatedBuilder`, `FadeTransition`, and local state. No blur shaders, looping decoration, random motion, or full-screen rebuild per carousel pixel is introduced.
