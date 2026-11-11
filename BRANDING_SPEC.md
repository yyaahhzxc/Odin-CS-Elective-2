# PokéMart UI/UX Specification (Pokémon GO / Niantic Design System)

> **Document Status:** Extracted, reverse-engineered, and verified directly from `branding inspo/PokemonGoUIKIT_v05_carasusan_Vallve.sketch`.  
> **Source Breakdown:** Master symbols (`Shop Button`, `Rucksack Button`, `PokemanBall`, `Back Button`, `Cancel Button`, `Evolve Button`, `Power Button`, `Number Switch`, `Attack Overlay`, `BG Menu`), color palettes (MSColor/NSColor instances), and typography metadata (`Lato-Bold`, `Lato-Medium`, `Lato-Regular`).

---

## 1. Concrete Visual Analysis of the Pokémon GO UI Kit

Direct extraction from the Sketch database (`PokemonGoUIKIT_v05_carasusan_Vallve.sketch`) reveals the exact visual and ergonomic anatomy that defines the Pokémon GO interface:

### 1.1 The Signature Teal-to-Mint Gradient System
In Pokémon GO, interactive actions never use flat monochrome fills; they use radiant, organic two-stop horizontal gradients:
* **Primary Action Gradient (`pogoMintGradient`):**
  - Start: `#A8DD9C` (Soft Spring Mint Lime)
  - End: `#23CCA9` (Vibrant Emerald Mint Teal)
  - Applied to: Primary action capsules ("POWER UP", "EVOLVE", "BUY NOW", "CHECKOUT").
* **Secondary / Floating Back Gradient (`pogoCyanGradient`):**
  - Start: `#AEFBA8` (Electric Light Lime)
  - End: `#5FEED1` (Radiant Cyan Mint)
  - Applied to: Circular Floating Back/Close buttons (`Back Button`, `Cancel Button`, `CP Button`).
* **Deep Framing Accent (`pogoTealPrimary`):**
  - `#1C8696` (Deep Sea Teal / Niantic Teal)
  - 67 occurrences across all symbols. Used as the crisp high-contrast border (4px on circular pads, 1.5px on cards) and icon glyph color.

### 1.2 Concentric Circular Menu & Bag Buttons
The core navigation buttons in Pokémon GO (`Shop Button`, `Rucksack Button`, `Pokemon Button`) feature a triple-layered concentric circle construction:
1. **Outer Ring (215×215):** Subtle neutral border (`#B4B4B4` / `#969696`, 2px).
2. **Middle Disc (204×204):** Pure white solid base (`#FFFFFF`).
3. **Inner Pad (172×172):** Soft pastel mint fill (`#F0FFF1`) bounded by a bold **4px Deep Teal border (`#1C8696`)**.
4. **Center Icon:** Minimalist 2D line icon rendered in deep teal (`#1C8696`).

### 1.3 The Floating Poké Ball & Dismiss 'X' Controls
* **Floating Poké Ball (170×170):**
  - Positioned bottom-center.
  - Top hemisphere: `#FF3844` (PoGO Valor Red).
  - Bottom hemisphere: `#FFFFFF` (Pure White).
  - Center button: Concentric white & silver rings (`#FFFFFF`, `#B9B9B9`) with 1px slate divider (`#969696`).
* **Floating Close 'X' Button (145×145 / 147×147):**
  - Positioned bottom-center on sub-screens.
  - Gradient disc: `#AEFBA8` -> `#5FEED1` with 8px blur drop shadow (`rgba(0, 0, 0, 0.40)`).
  - Deep teal 'X' icon (`#1C8696`) centered inside.

### 1.4 Two-Tone Action Capsules (`Button Evolve` & `Button Power`)
* In PoGO, the primary button (1004×151 in master symbol) is an elongated stadium capsule (`Radius.circular(28-32)`):
  - Left segment: Cost / item currency chip (e.g. Candy or Stardust icon + price count).
  - Right segment: Action title in bold uppercase sans-serif (`Lato-Bold`).
  - Fill: Seamless `#A8DD9C` -> `#23CCA9` gradient with a subtle 1px border.

### 1.5 Clean Translucent & Frosted Mint Surfaces
* Backgrounds in PoGO are clean, soft, and luminous:
  - **Scaffold / Canvas:** `#F0FFF1` (Ultra-light frosted mint).
  - **Cards & Dialogs:** Pure `#FFFFFF` (White) with subtle mint tint or `#D7D7D7` 1px border.
  - **Modal Backdrops (`BG Menu`):** Dark cyan/teal overlay (`#1C8696` or `#266378` at 65% opacity).

---

## 2. Pokémon GO Color Tokens

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  DEEP SEA TEAL      VIBRANT MINT        NEON CYAN MINT      SOFT LIME MINT   │
│     #1C8696             #23CCA9             #5FEED1            #A8DD9C       │
│  (Brand Primary)    (Gradient Stop 2)   (Gradient Stop 2)   (Gradient Stop 1)│
├──────────────────────────────────────────────────────────────────────────────┤
│  FROSTED MINT BG    CLEAN WHITE CARD    VALOR RED           POKÉCOIN GOLD    │
│     #F0FFF1             #FFFFFF             #FF3844            #F5A623       │
│  (Scaffold BG)      (Card Surfaces)     (Poké Ball / Alert) (Coins / Price)  │
├──────────────────────────────────────────────────────────────────────────────┤
│  DEEP CHARCOAL      MUTED SLATE         OUTLINE BORDER      POKÉSTOP BLUE    │
│     #1E2833             #7E8C88             #D7D7D7            #28AEFF       │
│  (Header Text)      (Subtitles/Labels)  (Subtle Dividers)   (Info / Links)   │
└──────────────────────────────────────────────────────────────────────────────┘
```

| Token Name | Hex Code | Flutter Definition | PoGO Role |
| :--- | :--- | :--- | :--- |
| `pogoTealPrimary` | `#1C8696` | `const Color(0xFF1C8696)` | Primary brand color, circular button borders, dark glyphs |
| `pogoMintEnd` | `#23CCA9` | `const Color(0xFF23CCA9)` | Primary button gradient right stop (Emerald Mint) |
| `pogoMintStart` | `#A8DD9C` | `const Color(0xFFA8DD9C)` | Primary button gradient left stop (Spring Lime) |
| `pogoCyanEnd` | `#5FEED1` | `const Color(0xFF5FEED1)` | Floating circular button gradient right stop |
| `pogoLimeStart` | `#AEFBA8` | `const Color(0xFFAEFBA8)` | Floating circular button gradient left stop |
| `pogoScaffoldBg` | `#F0FFF1` | `const Color(0xFFF0FFF1)` | Ultra-light frosted mint scaffold background |
| `pogoCardBg` | `#FFFFFF` | `const Color(0xFFFFFFFF)` | Pure white card surfaces with rounded corners |
| `pogoValorRed` | `#FF3844` | `const Color(0xFFFF3844)` | Poké Ball top hemisphere, remove action, low stock |
| `pogoCoinGold` | `#F5A623` | `const Color(0xFFF5A623)` | PokéCoins, trainer balance, ratings |
| `pogoPokeStopBlue`| `#28AEFF` | `const Color(0xFF28AEFF)` | PokéStop blue, technical filter pills |
| `pogoTextPrimary` | `#1E2833` | `const Color(0xFF1E2833)` | High-contrast title and header text |
| `pogoTextSecondary`| `#7E8C88`| `const Color(0xFF7E8C88)` | Subtitles, stock counters, helper captions |
| `pogoBorder` | `#D7D7D7` | `const Color(0xFFD7D7D7)` | Subtle card borders and horizontal dividers |

---

## 3. Typography Specification

From Sketch metadata, the typography engine is strictly **Lato**:

* **Display / AppBar Titles:**
  - `Lato-Bold`, 22pt, tracking `-0.5`, color `#1E2833`.
* **Section / Category Chips:**
  - `Lato-Bold`, 13pt, uppercase, tracking `+0.8`, color `#1C8696`.
* **Button Titles ("POWER UP", "ADD TO BAG", "CHECKOUT"):**
  - `Lato-Bold`, 16pt, uppercase, tracking `+1.2`, color `#FFFFFF` (on gradient) or `#1C8696` (on white).
* **Body / Lore Descriptions:**
  - `Lato-Regular`, 14pt, line height `1.45`, color `#4A5568`.
* **Price / PokéDollar Readout:**
  - `Lato-Bold`, 18pt, bold numeral with currency glyph `₽` or PokéCoin icon.

---

## 4. UI Component Architecture for PokéMart

### 4.1 Header Bar (PoGO Trainer HUD)
* Clean white/frosted mint top app bar (`#FFFFFF` with soft shadow).
* Left: Circular Poké Ball emblem + `POKÉMART` title.
* Right:
  - **PokéCoin / Funds Chip:** Soft pill container with gold PokéCoin icon (`#F5A623`) + balance (`325,976`).
  - **Item Bag (`Rucksack Button`):** Concentric circular badge showing live bag item count.

### 4.2 Category Filter Tabs (PoGO Bag Pockets)
* Horizontal scrolling pill tabs with smooth rounded caps (`BorderRadius.circular(20)`).
* Unselected: White pill with subtle `#D7D7D7` border and `#7E8C88` text.
* Selected: Active `#1C8696` deep teal or gradient `#A8DD9C` -> `#23CCA9` fill with bold white text.

### 4.3 Product Cards (PoGO Item Pedestal)
* White elevated card (`BorderRadius.circular(22)`), 1.5px `#E2EAE6` border, soft drop shadow (`blur: 10`, `y: 4`, opacity `0.06`).
* Upper: Soft circular pedestal (`#F0FFF1` background with `#1C8696` inner ring) framing the high-resolution 3D asset.
* Middle: Item Name in bold `Lato-Bold` + subtle category badge.
* Bottom: Price badge (`₽ 200`) + quick "+" Add to Bag concentric circle button.

### 4.4 Primary Buttons (Evolve / Power Up Style)
* Elongated stadium capsule (`StadiumBorder`).
* Gradient fill: Linear gradient from `#A8DD9C` (left) to `#23CCA9` (right).
* Crisp white uppercase text with soft elevation shadow.

### 4.5 Floating Dismiss / Back Button
* Positioned bottom-center during modals and detail screens:
* Circular button (56×56 dp) with gradient `#AEFBA8` -> `#5FEED1`, deep teal 'X' icon, and floating drop shadow.

### 4.6 Official PokeMiners Datamined Assets Integration
* Directly sourced from `PokeMiners/pogo_assets`:
  - **HUD Icons:** `btn_shop.png` (App title mark), `btn_coins_small.png` (Trainer balance chip), `btn_items.png` (Rucksack icon).
  - **Limited-Time Event Boxes:** `greatbox.png`, `ultrabox.png`, `adventure_box.png`, `specialbox.png` displayed in the featured horizontal showcase.
  - **Social Authentication Badges:** `GoogleLogo.png`, `FacebookLogo.png`, `ui_settings_social_apple_active.png` prepared for Supabase OAuth.
  - **Asset Registry:** Centralized in [`lib/core/pogo_assets.dart`](file:///c:/Users/SHRIMP/Documents/Flutter/Flutter%20E-Commerce%20Project/lib/core/pogo_assets.dart).

---

## 5. Verification & Implementation Status
1. [x] Reverse-engineer Sketch UI kit and extract official tokens and symbols.
2. [x] Rebrand theme (`lib/theme/app_theme.dart`) with PoGO Teal, Mint gradients, and 22px cards.
3. [x] Update product cards (`lib/widgets/product_card.dart`) with PoGO concentric pedestals.
4. [x] Upgrade home screen (`lib/screens/home_screen.dart`) with Trainer HUD, PokéCoins chip, and Limited-Time Event Boxes.
5. [x] Seed and sync 48 high-resolution 3D items across 6 Bag pockets in Supabase and local data.
6. [x] Verify automated test suite (`flutter test` 6/6 passed) and static analysis (`flutter analyze` 0 issues).
