# Sample `.riv` Setup Checklist

Use this checklist when exporting/updating `eco_mascot.riv`.

## 1) Naming and Structure

- [ ] File exported as `eco_mascot.riv`
- [ ] Copied to `assets/rive/`
- [ ] Artboard exists and character is centered
- [ ] State machine name is exactly `MascotState`

## 2) Inputs

- [ ] Bool input `happy` exists
- [ ] Bool input `wrong` exists
- [ ] Default values are both `false`

## 3) States and Transitions

- [ ] Idle state is default
- [ ] Happy state connected with `happy == true`
- [ ] Wrong state connected with `wrong == true`
- [ ] Happy returns to Idle when `happy == false`
- [ ] Wrong returns to Idle when `wrong == false`

## 4) Visual QA

- [ ] Idle feels calm and readable
- [ ] Happy feels celebratory and quick
- [ ] Wrong feels soft (not scary/aggressive)
- [ ] No clipping on top/bottom at mobile aspect ratio

## 5) App Integration QA

- [ ] `flutter pub get` succeeds
- [ ] App loads mascot in Splash/Game/Result/Home
- [ ] Trigger correct answer -> mascot turns happy
- [ ] Trigger wrong answer -> mascot turns wrong
- [ ] Return to neutral flow -> mascot returns idle
