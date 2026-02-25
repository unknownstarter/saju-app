# Production UI System — Saju-Inyeon

> **Perspective**: Senior Product Designer at Tinder + Toss
> **Target**: 20-35 MZ generation in Korea
> **Core tension**: Emotionally immersive yet clean. Mystic yet trustworthy.

---

## 1. Visual Language

### Tone
- **Not Dribbble**: No decorative gradients, no glassmorphism, no unnecessary blur
- **Not childish**: Characters exist but they're guides, not the brand
- **Toss-level clean**: Information hierarchy through whitespace, not decoration
- **Tinder-level confident**: Bold numbers, clear CTAs, no hesitation in layout

### Density
- **Comfortable**: 48-56px touch targets, generous padding
- **Scannable**: One primary action per screen, max 3 visual layers
- **Breathing room**: 20-32px section gaps, 16px card inner padding

### Hierarchy (3-layer rule)
1. **Hero element**: Score number, profile photo, match card (large, dominant)
2. **Supporting info**: Name, age, distance, element badge (medium, readable)
3. **Tertiary**: Timestamps, labels, metadata (small, subdued)

---

## 2. Spacing System (4px grid, strict)

| Token | Value | Usage |
|-------|-------|-------|
| `space2` | 2px | Icon internal padding, hairline gaps |
| `space4` | 4px | Inline text gaps, badge padding |
| `space6` | 6px | Chip padding, tight element spacing |
| `space8` | 8px | Inline element spacing, small padding |
| `space12` | 12px | Card inner side padding (compact), list item gap |
| `space16` | 16px | Card inner padding (default), section inner spacing |
| `space20` | 20px | Page horizontal margin (mobile) |
| `space24` | 24px | Section gap (within page) |
| `space32` | 32px | Major section separator |
| `space40` | 40px | Page top padding, hero spacing |
| `space48` | 48px | Screen-level vertical breathing room |
| `space64` | 64px | Splash/hero vertical offset |

**Page layout**: `horizontal: 20px`, `top: safe area + 16px`, `bottom: 32px + safe area`

---

## 3. Typography Scale (Pretendard)

Font: **Pretendard** (Korean-optimized, Apple SF-like neutrality)
Fallback: `-apple-system, SF Pro Display, Roboto, system-ui`

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `hero` | 48px | Bold(700) | 1.1 | -1.5 | Compatibility score splash |
| `display1` | 32px | Bold(700) | 1.2 | -0.8 | Page title, major number |
| `display2` | 24px | SemiBold(600) | 1.25 | -0.4 | Section hero, saju result |
| `heading1` | 20px | SemiBold(600) | 1.35 | -0.3 | Section title |
| `heading2` | 17px | SemiBold(600) | 1.4 | -0.2 | Card title, list title |
| `heading3` | 15px | SemiBold(600) | 1.4 | -0.1 | Subsection title |
| `body1` | 16px | Regular(400) | 1.55 | 0 | Primary body text |
| `body2` | 14px | Regular(400) | 1.5 | 0 | Secondary body text |
| `caption1` | 13px | Medium(500) | 1.4 | 0 | Labels, tags |
| `caption2` | 12px | Medium(500) | 1.35 | 0 | Metadata, timestamps |
| `overline` | 11px | Medium(500) | 1.3 | 0.2 | Badge text, tiny labels |

### Korean-specific tuning
- All heading weights capped at SemiBold(600) — Bold(700) only for hero numbers
- `letter-spacing: -0.1 ~ -0.8` for headings (Korean density compensation)
- `line-height: 1.5+` for body text (Korean readability)
- No ALL_CAPS (meaningless in Korean)

---

## 4. Color Token System

### Semantic tokens (theme-aware)

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `bg.primary` | `#F7F3EE` (한지) | `#1D1E23` (먹색) | Page background |
| `bg.secondary` | `#F0EDE8` | `#2A2B32` | Section/group background |
| `bg.elevated` | `#FEFCF9` | `#35363F` | Card, elevated surface |
| `text.primary` | `#2D2D2D` | `#E8E4DF` | Main text |
| `text.secondary` | `#6B6B6B` | `#A09B94` | Supporting text |
| `text.tertiary` | `#A0A0A0` | `#6B6B6B` | Hint, placeholder |
| `text.inverse` | `#FEFCF9` | `#2D2D2D` | Text on filled buttons |
| `border.default` | `#E8E4DF` | `#35363F` | Card border, divider |
| `border.focus` | `#A8C8E8` | `#A8C8E8 @ 60%` | Input focus ring |
| `fill.brand` | `#A8C8E8` | `#A8C8E8` | Primary CTA fill |
| `fill.accent` | `#F2D0D5` | `#F2D0D5` | Secondary accent fill |
| `fill.disabled` | `#E8E4DF` | `#35363F` | Disabled state fill |

### Fixed tokens (same in both modes)

| Token | Value | Usage |
|-------|-------|-------|
| `element.wood` | `#8FB89A` | 목(木) element |
| `element.fire` | `#D4918E` | 화(火) element |
| `element.earth` | `#C8B68E` | 토(土) element |
| `element.metal` | `#B8BCC0` | 금(金) element |
| `element.water` | `#89B0CB` | 수(水) element |
| `compat.excellent` | `#C27A88` | 90-100점 |
| `compat.good` | `#C49A7C` | 70-89점 |
| `compat.normal` | `#A8B0A0` | 50-69점 |
| `compat.low` | `#959EA2` | 0-49점 |
| `mystic.glow` | `#C8B68E` | Dark mode gold glow |
| `mystic.accent` | `#D4C9A8` | Dark mode warm accent |
| `status.success` | `#8FB89A` | Success |
| `status.error` | `#D4918E` | Error |
| `status.warning` | `#C8B68E` | Warning |

---

## 5. Elevation System

No Material-style shadow stacking. Instead: **surface layering + subtle border**.

| Level | Light | Dark | Usage |
|-------|-------|------|-------|
| `flat` | No shadow, no border | No shadow, no border | Inline content |
| `low` | `0 1px 2px rgba(0,0,0,0.04)` | `border: 1px #35363F` | List items, chips |
| `medium` | `0 2px 8px rgba(0,0,0,0.06)` | `border: 1px #35363F` | Cards, dialogs |
| `high` | `0 4px 16px rgba(0,0,0,0.08)` | `border: 1px #444` + subtle glow | Bottom sheets, FABs |
| `mystic` | N/A | `0 0 20px rgba(200,182,142,0.15)` | Compatibility reveal, saju result |

**Key principle**: Dark mode uses borders, not shadows. Mystic mode uses warm glow, not elevation.

---

## 6. Component States

Every interactive component has exactly 5 states:

| State | Visual Change | Timing |
|-------|---------------|--------|
| `default` | Base appearance | — |
| `pressed` | opacity: 0.7 + scale: 0.97 | instant (0ms) |
| `disabled` | opacity: 0.4, no pointer events | — |
| `loading` | Content replaced with skeleton or spinner | — |
| `focused` | Brand color focus ring (2px, 2px offset) | — |

### Button-specific
- **Primary (filled)**: bg `fill.brand`, text `text.inverse`
- **Secondary (outlined)**: border `border.default`, text `text.primary`
- **Ghost**: no bg, text `fill.brand`
- **Danger**: bg `status.error`, text `text.inverse`

### Card-specific
- Default → Pressed: scale(0.98), 150ms ease-out
- Selected: Left border accent (3px `fill.brand`)

---

## 7. Interaction Feedback System

| Trigger | Feedback | Duration |
|---------|----------|----------|
| **Tap** | Opacity 0.7 + scale 0.97 | 100ms ease-out |
| **Long press** | Scale 0.95 + haptic (medium) | 200ms |
| **Swipe (card)** | Card follows finger, opacity fade at edges | Gesture-driven |
| **Pull to refresh** | Custom saju spinner (rotating bagua) | Until complete |
| **Tab switch** | Cross-fade (no slide) | 200ms |
| **Page transition** | iOS-style slide right (CupertinoPageRoute) | 300ms |
| **Bottom sheet** | Spring physics (damping: 0.8) | ~400ms |
| **Success** | Checkmark scale-in + haptic (success) | 300ms |
| **Error** | Shake (3x, 4px) + haptic (error) | 300ms |
| **Score reveal** | CountUp animation + gauge fill | 1800ms ease-out-cubic |
| **Match reveal** | Card flip + particle burst | 600ms |
| **Like sent** | Heart scale-up + float-away | 500ms |

### Haptic philosophy
- **Light**: Tap, selection change
- **Medium**: Long press, drag start
- **Success**: Match confirmed, payment complete
- **Error**: Validation fail, action blocked
- **Never**: Scroll, passive viewing

---

## 8. Micro-interaction Philosophy

### Core principle: "Earned delight"
- Micro-interactions are rewards, not decoration
- 80% of the app is clean and functional (Toss)
- 20% is emotionally charged moments (Tinder "It's a Match!")

### When to animate
1. **Score reveal**: Full cinematic (gauge fill, number count-up, grade fade-in)
2. **Match success**: Celebration (card flip, confetti, haptic burst)
3. **Like sent**: Satisfying (heart pop + float away)
4. **Profile card flip**: Playful (3D perspective rotation to reveal saju info)

### When NOT to animate
- Navigation transitions (standard iOS slide)
- List loading (skeleton shimmer only)
- Form input (instant response)
- Tab switching (simple cross-fade)

### Easing curves
- **Entrance**: `Curves.easeOutCubic` (fast start, slow end)
- **Exit**: `Curves.easeInCubic` (slow start, fast end)
- **Bounce**: `Curves.elasticOut` (score reveal only)
- **Spring**: `SpringDescription(mass: 1, stiffness: 200, damping: 20)` (bottom sheets, drag)

---

## Implementation Notes

### Files to modify
1. `pubspec.yaml` — Activate Pretendard font declarations
2. `lib/core/theme/app_theme.dart` — Apply Pretendard fontFamily, refine typography scale, add elevation tokens
3. `lib/core/widgets/` — Update components to follow new state system

### Pretendard activation
```yaml
fonts:
  - family: Pretendard
    fonts:
      - asset: assets/fonts/Pretendard-Regular.otf
      - asset: assets/fonts/Pretendard-Medium.otf
        weight: 500
      - asset: assets/fonts/Pretendard-SemiBold.otf
        weight: 600
      - asset: assets/fonts/Pretendard-Bold.otf
        weight: 700
```
