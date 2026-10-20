# Pokédex Midterm Exam — Implementation Plan

This implementation plan outlines the architecture, data modeling, UI components, refactoring roadmap, and testing strategies required for extending the Pokédex project for the **CS Elective 2 Midterm Examination**, adhering strictly to the guidelines in [.agents/rules/flutter-pre-instructions.md](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/.agents/rules/flutter-pre-instructions.md) and the exam specifications in [Pokédex Application _ Midterm Exam.pdf](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/Pok%C3%A9dex%20Application%20_%20Midterm%20Exam.pdf).

---

## 1. Project Overview & Branching Context

- **Source Code Base:** Sourced from the previous repository branch [`state-mgt-act`](https://github.com/yyaahhzxc/Odin-CS-Elective-2/tree/state-mgt-act).
- **Target Git Branch:** `midterm-exam` (already created and checked out in this workspace).
- **Core Objective:** Upgrade the Pokédex app from `Provider` to **Riverpod** (`flutter_riverpod`), implementing five required features:
  1. Pokémon List Management with Async Loading/Error/Success & in-place list refresh.
  2. Pokémon Nickname Editor (add, edit, remove nicknames in app state and reflect in UI).
  3. Retractable / Collapsible Favorites Panel with immediate reactive updates and empty state.
  4. Animated Favorite Heart Indicator on cards with immediate status reflection.
  5. Pokémon Type Filter with chip/dropdown selector, data filtering, and clear filter capability.

---

## 2. Technology & Architecture Decisions

### 2.1 State Management: Riverpod (`flutter_riverpod: ^2.6.1`)
- **Rationale:** 
  - Direct evolution of `Provider` written by the same maintainer (Remi Rousselet) to eliminate `BuildContext` coupling, provider-not-found exceptions, and boilerplate.
  - Compile-safe declarative dependency injection.
  - Effortless derived states via `ref.watch()`—especially ideal for computing `filteredPokemonsProvider` from the base list and active type filter.
  - Fulfills the exam requirement to handle all operations as methods on the state management class without creating redundant refresh methods (recalls existing `fetchPokemons(forceRefresh: true)`).

### 2.2 Design System: PokémonDB Clean Canvas + Active Shadcn Aesthetics
- **Base Canvas:** Neutral, content-focused PokémonDB layout with pure white cards/backgrounds (`#FFFFFF` / `#F8FAFC`), 1px borders (`#E2E8F0`), official high-resolution sprites, and canonical type badges.
- **Corner Radius:** Uniform `12px` (`0.75rem` / `BorderRadius.circular(12)`) across cards, dialogs, filter buttons, and panels.
- **Micro-Animations & Transitions:**
  - **Expand/Collapse Panel:** Smooth height animation (`AnimatedSize` with `Curves.easeOutCubic`, 250ms).
  - **Favorite Heart:** Interactive scale bounce (`AnimatedScale`, 200ms) with distinct active (vibrant red `#EF4444`) and inactive (slate outline `#94A3B8`) states.
  - **Shadcn Dialog Modal:** Clean, centered modal with subtle drop shadow, labeled inputs, and distinct primary/ghost/destructive button variants.
  - **Type Filter Badges:** Active pill transition with smooth background and text contrast changes.

---

## 3. State Architecture & Provider Specifications

All state management classes and providers reside in [`lib/providers/pokemon_provider.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/providers/pokemon_provider.dart):

```
                       ┌──────────────────────────┐
                       │      PokeApiService      │
                       └─────────────┬────────────┘
                                     │ (Async HTTP)
                                     ▼
                       ┌──────────────────────────┐
                       │   pokemonListProvider    │ (AsyncNotifier<List<Pokemon>>)
                       └──────┬────────────┬──────┘
                              │            │
            ┌─────────────────┘            └─────────────────┐
            ▼                                                ▼
┌──────────────────────────┐                      ┌──────────────────────────┐
│selectedTypeFilterProvider│                      │    favoritesProvider     │
│   (Notifier<String?>)    │                      │  (Notifier<Set<int>>)    │
└───────────┬──────────────┘                      └──────────┬───────────────┘
            │                                                │
            ▼                                                ▼
┌──────────────────────────┐                      ┌──────────────────────────┐
│ filteredPokemonsProvider │                      │    nicknamesProvider     │
│    (Derived Provider)    │                      │(Notifier<Map<int,String>>)
└──────────────────────────┘                      └──────────────────────────┘
```

### Provider Details
1. **`pokemonListProvider` (`AsyncNotifier<List<Pokemon>>`):**
   - Holds the 27 starter Pokémon fetched from PokéAPI.
   - Exposes `Future<void> fetchPokemons({bool forceRefresh = false})`.
   - Re-executed directly on pull-to-refresh or button refresh (no redundant wrapper methods).
2. **`favoritesProvider` (`Notifier<Set<int>>`):**
   - Stores set of favorited Pokémon IDs (`Set<int>`).
   - Exposes `void toggleFavorite(int pokemonId)` and `bool isFavorite(int pokemonId)`.
3. **`nicknamesProvider` (`Notifier<Map<int, String>>`):**
   - Stores mapping of Pokémon ID to custom nickname (`Map<int, String>`).
   - Exposes `void setNickname(int pokemonId, String nickname)` and `void removeNickname(int pokemonId)`.
4. **`selectedTypeFilterProvider` (`Notifier<String?>`):**
   - Stores current active elemental type (e.g. `'fire'`, `'water'`, `'grass'`, or `null` for all).
   - Exposes `void selectType(String? type)` and `void clearFilter()`.
5. **`filteredPokemonsProvider` (Derived):**
   - Listens to `pokemonListProvider` and `selectedTypeFilterProvider`.
   - Emits filtered list of Pokémon matching the selected type, or the complete list if no filter is active.
6. **`selectedPokemonProvider` (`Notifier<Pokemon?>`):**
   - Stores the active Pokémon selected for the detail screen.

---

## 4. UI Component Architecture

### 4.1 Retractable Favorites Panel ([`lib/widgets/favorites_panel.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/favorites_panel.dart))
- **Placement:** Placed directly beneath the AppBar on the Home Page, with an accordion toggle button in the AppBar showing an active favorite count badge.
- **Behavior:**
  - Collapsed by default (height: 0).
  - Toggling expands the panel with an `AnimatedSize` spring curve.
  - When favorites exist: Displays a horizontally scrollable list of compact cards (thumbnail, custom nickname/name, ID badge, and a remove heart button).
  - When favorites empty: Displays a minimalist Shadcn empty container: *"No favorites added yet. Tap the heart icon on any Pokémon card to favorite."*
- **Reactivity:** Updates immediately upon toggling any favorite without page reload.

### 4.2 Type Filter Bar ([`lib/widgets/type_filter_bar.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/type_filter_bar.dart))
- **Placement:** Positioned above the Pokémon list on the main screen.
- **Controls:**
  - Horizontal scroll of filter chips with 12px corner radius.
  - Includes: `All`, `Grass`, `Fire`, `Water`, `Poison`, `Flying`, etc.
  - Active pill highlighted with dark neutral background and smooth fade.
  - "Clear Filter" action button visible when a type filter is active.

### 4.3 Pokémon Card Updates ([`lib/widgets/pokemon_card.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/pokemon_card.dart))
- **Favorite Heart Indicator:**
  - Top-right corner icon button with scale bounce animation.
  - Tapping toggles favorite in `favoritesProvider` without triggering card tap navigation (`onTap` propagation handled).
- **Nickname Display:**
  - Checks `nicknamesProvider` for a custom nickname.
  - If set: Displays custom nickname in bold with the canonical species name beneath in parentheses (e.g., **Blaze** *(Charmander)*), retaining original name as required.
- **Nickname Quick-Trigger:**
  - Long-pressing the card or clicking a small edit pencil opens the Shadcn Nickname Dialog.

### 4.4 Shadcn Nickname Modal Dialog ([`lib/widgets/nickname_dialog.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/nickname_dialog.dart))
- **Features:**
  - Clean floating card with `12px` rounded corners and subtle border.
  - Labeled `TextField` with auto-focus and controller cleanup.
  - "Save Nickname" primary button (saves to `nicknamesProvider`).
  - "Remove Nickname" destructive ghost button (enabled only if a nickname already exists).
  - "Cancel" button.

### 4.5 Detail Screen Updates ([`lib/screens/pokemon_detail_screen.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/screens/pokemon_detail_screen.dart))
- Sourced exclusively from Riverpod state (`selectedPokemonProvider`, `favoritesProvider`, `nicknamesProvider`).
- Prominently displays favorite heart toggle in the AppBar.
- Displays an interactive Nickname management card where users can view, assign, edit, or remove nicknames.

---

## 5. Step-by-Step Execution Roadmap

| Step | Action | Files Affected |
| :--- | :--- | :--- |
| **Step 1** | Replace `provider` with `flutter_riverpod: ^2.6.1` in dependencies | [`pubspec.yaml`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/pubspec.yaml) |
| **Step 2** | Initialize `ProviderScope` at the application root and convert app entry to Riverpod | [`lib/main.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/main.dart) |
| **Step 3** | Implement complete Riverpod state architecture (List, Favorites, Nicknames, Filters) | [`lib/providers/pokemon_provider.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/providers/pokemon_provider.dart) |
| **Step 4** | Build Shadcn Nickname Dialog component | [`lib/widgets/nickname_dialog.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/nickname_dialog.dart) |
| **Step 5** | Build Shadcn Type Filter Bar with active pill animation and clear option | [`lib/widgets/type_filter_bar.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/type_filter_bar.dart) |
| **Step 6** | Build Retractable Favorites Panel with animated expansion and empty state | [`lib/widgets/favorites_panel.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/favorites_panel.dart) |
| **Step 7** | Refactor Pokémon Card with heart bounce animation, nickname display, and tap isolation | [`lib/widgets/pokemon_card.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/pokemon_card.dart) |
| **Step 8** | Refactor Pokédex Screen to integrate favorites panel, type filter, and pull-to-refresh | [`lib/screens/pokedex_screen.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/screens/pokedex_screen.dart) |
| **Step 9** | Refactor Pokémon Detail Screen with full favorite and nickname integration | [`lib/screens/pokemon_detail_screen.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/screens/pokemon_detail_screen.dart) |
| **Step 10** | Update unit and widget test suites for Riverpod integration and new features | [`test/widget_test.dart`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/test/widget_test.dart) |
| **Step 11** | Update README with academic structure per `flutter-pre-instructions.md` | [`README.md`](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/README.md) |
| **Step 12** | Git commit and push to remote `midterm-exam` branch | Git VCS |

---

## 6. Video Presentation Guide (Max 15 Minutes)

As required by the submission guidelines, this breakdown prepares you for your recorded walkthrough:

1. **Introduction & Application Overview (~2 mins):**
   - Introduce the app: Starter Pokédex covering Gens 1–9 with PokéAPI integration.
   - Showcase the UI: PokémonDB aesthetic combined with Shadcn 0.75rem rounded components and micro-animations.
2. **State Management Significance (~4 mins):**
   - Explain why local `setState` breaks down across nested widgets and multi-screen architectures.
   - Discuss App State synchronization: How modifying a favorite or nickname in one place updates the card, the retractable panel, and the detail screen simultaneously.
3. **Why Riverpod Over Provider / BLoC (~4 mins):**
   - Riverpod eliminates `BuildContext` lookup limitations and runtime `ProviderNotFoundException`.
   - Native support for derived state (`filteredPokemonsProvider` combining base list + active type filter).
   - Clean, testable, and compile-safe architecture.
4. **Code & Feature Walkthrough (~5 mins):**
   - **Pokémon List:** Demonstrate initial async load, error handling, and in-place refresh re-calling `fetchPokemons()`.
   - **Nickname Editor:** Assigning, editing, and removing nicknames, showing both nickname and original species name.
   - **Favorites & Indicator:** Tapping the animated heart, seeing the immediate update in the retractable panel.
   - **Type Filter:** Filtering by Fire/Water/Grass and clearing the filter back to the full list.
