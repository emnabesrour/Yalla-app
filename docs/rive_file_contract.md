# Rive File Contract - `eco_mascot.riv`

This contract defines exactly how the Flutter app expects the mascot `.riv` file to be built.

## File Location

- Path: `assets/rive/eco_mascot.riv`
- Declared in `pubspec.yaml` under `assets/rive/`

## Artboard

- Recommended artboard name: `Main`
- Target aspect: portrait-friendly (character centered)
- Keep safe margins around character to avoid clipping in `BoxFit.contain`.

## State Machine (Required)

- State machine name: `MascotState`
- Required bool inputs:
  - `happy`
  - `wrong`
- Optional bool inputs (for richer home reactions):
  - `excited`
  - `calm`

### Runtime semantics in app

- `idle`: `happy = false` and `wrong = false`
- `happy`: `happy = true`, `wrong = false`
- `wrong`: `happy = false`, `wrong = true`
- `excited` (optional): `excited = true` (and internally treated as happy if needed)
- `calm` (optional): `calm = true`

## Animations

At least these three visual states must exist and be reachable from `MascotState`:

- Idle loop
- Happy reaction loop (or short loop)
- Wrong/try-again reaction loop

## Transition Rules (Recommended)

- Idle -> Happy when `happy == true`
- Idle -> Wrong when `wrong == true`
- Happy -> Idle when `happy == false`
- Wrong -> Idle when `wrong == false`
- If both inputs become true by mistake, prioritize `wrong` (safer UX feedback).

## Performance Budget

- Keep file size lightweight for mobile startup.
- Prefer simple vector hierarchy and avoid heavy nested effects.
- Test on low-end Android target for smooth 60fps.

## Validation in App

The app uses:

- `StateMachineController.fromArtboard(artboard, 'MascotState')`
- `findInput<bool>('happy')`
- `findInput<bool>('wrong')`

If names differ, mascot falls back to emoji UI.

## Home CTA Mapping Contract

Use this mapping for consistent feedback across design/dev/QA:

| Button | Mascot Mood | Sound | Route |
|---|---|---|---|
| ابدأ اللعب | happy | tap_soft | `/worlds` |
| العوالم والمستويات | happy | tap_soft | `/worlds` |
| المكافآت | excited | tap_soft | `/rewards` |
| الملف الشخصي | idle | tap_soft | `/profile` |
| لوحة الولي | calm | tap_soft | `/parent-dashboard` |
| الإعدادات | calm | tap_soft | `/settings` |

Notes:
- Sound plays only when `soundOn == true`.
- Mood reaction is shown before navigation (short delay for polish).
- If optional Rive inputs (`excited`, `calm`) are missing, app still works with fallback behavior.
