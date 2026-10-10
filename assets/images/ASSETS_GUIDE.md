# Assets Integration Guide — يلّا! Nature Adventure

## 🎨 Recommended Free Asset Packs

### 1. Kenney Assets (kenney.nl) — FREE
Best for: game objects, UI elements, sprites

Download:
- **Nature Pack** → kenney.nl/assets/nature-kit
- **Animal Pack** → kenney.nl/assets/animal-pack
- **UI Pack** → kenney.nl/assets/ui-pack

Place in: `assets/sprites/`

Naming convention used in code:
```
assets/sprites/tree_oak.png
assets/sprites/tree_pine.png
assets/sprites/animal_panda.png
assets/sprites/animal_lion.png
assets/sprites/trash_plastic.png
assets/sprites/trash_glass.png
assets/sprites/solar_panel.png
assets/sprites/recycle_bin.png
```

---

### 2. Icons8 Ouch (icons8.com/ouch) — FREE for basic
Best for: 3D cartoon characters, illustrations

Download PNG/SVG from:
- https://icons8.com/ouch/category/people
- https://icons8.com/ouch/category/nature

Place in: `assets/images/characters/`

```
assets/images/characters/child_hero.png        # main mascot
assets/images/characters/child_playing.png
assets/images/characters/guardian_forest.png
assets/images/characters/guardian_ocean.png
```

---

### 3. Quaternius (quaternius.com) — FREE
Best for: 3D low-poly models (for model_viewer_plus)

Download .glb files:
- Animals pack
- Environment pack

Place in: `assets/images/` (or `assets/3d/`)

```
assets/3d/earth_globe.glb       # model_viewer_plus in Earth world
assets/3d/animal_panda.glb
assets/3d/tree_oak.glb
```

Code usage (model_viewer_plus):
```dart
ModelViewer(
  src: 'assets/3d/earth_globe.glb',
  autoRotate: true,
  cameraControls: true,
)
```

---

### 4. CraftPix (craftpix.net) — FREE pack available
Best for: game backgrounds, animated characters

Free pack: https://craftpix.net/freebies/

Place in: `assets/images/worlds/`

```
assets/images/worlds/bg_forest.png         # used in ParallaxWorldScene
assets/images/worlds/bg_ocean.png
assets/images/worlds/bg_jungle.png
assets/images/worlds/bg_city.png
assets/images/worlds/bg_energy.png
assets/images/worlds/bg_space.png
```

---

### 5. Rive (rive.app) — Community
Best for: animated mascot, button interactions

Download from rive.app/community:
- Search: "educational character" or "kids mascot"

Place in: `assets/rive/`

```
assets/rive/eco_mascot.riv     # REQUIRED — state machine "MascotState"
                                # inputs: happy(bool), wrong(bool),
                                #         excited(bool), calm(bool)
```

See: `docs/rive_file_contract.md` for full spec.

---

### 6. LottieFiles (lottiefiles.com) — FREE
Best for: success animations, loading, rewards

Download JSON:

```
assets/animations/splash_leaf.json      # splash screen floating leaf
assets/animations/reward_open.json      # reward box opening
assets/animations/confetti.json         # celebration
assets/animations/loading.json          # level loading
```

---

## 🖼️ Image Slots Used in Code

| Path | Usage | Source |
|------|-------|--------|
| `assets/rive/eco_mascot.riv` | Interactive mascot all screens | Rive community |
| `assets/images/characters/child_hero.png` | Home avatar | Icons8 Ouch |
| `assets/images/worlds/bg_forest.png` | Fallback world bg | CraftPix |
| `assets/sprites/tree_oak.png` | Level map nodes | Kenney |
| `assets/sprites/trash_plastic.png` | Flame recycle game | Kenney |
| `assets/animations/reward_open.json` | Result screen | LottieFiles |
| `assets/sounds/success.mp3` | Correct answer | freesound.org |
| `assets/sounds/wrong_soft.mp3` | Wrong answer | freesound.org |
| `assets/sounds/tap_soft.mp3` | Button tap | freesound.org |

---

## ✅ Quick Start Checklist

- [ ] Download Kenney Nature Pack → place in `assets/sprites/`
- [ ] Download 1 Rive mascot from community → rename to `eco_mascot.riv`
- [ ] Download 2-3 Lottie JSONs → place in `assets/animations/`
- [ ] Download 3 short MP3 sounds → place in `assets/sounds/`
- [ ] Run `flutter pub get` after adding sounds (flame_audio)

The app works perfectly with emoji fallbacks until real assets are added.
