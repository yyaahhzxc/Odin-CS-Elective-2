# Starter Pokédex Application (Midterm Exam)

## Project Overview
Starter Pokédex is a cross-platform Flutter application displaying the complete 81-Pokémon starter evolution roster across Generations 1 through 9 from PokéAPI, built using Riverpod state management to deliver asynchronous list handling, interactive downward-expandable 18-type filtering, retractable favorites tracking, and custom nickname editing within a PokémonDB-inspired, Shadcn-styled minimalist design system.

## Tasked Instructions / Requirements
- **State Management Migration**: Transition from Provider to Riverpod (`flutter_riverpod`), encapsulating all functionality as methods directly within state notifiers.
- **Pokémon List Management**:
  - Asynchronous network retrieval from PokéAPI covering all 81 starter evolution lines (9 generations × 3 families × 3 evolution stages).
  - Distinct UI handling for loading, error, and loaded states.
  - User-triggered list refresh on the home page re-invoking the primary `fetchPokemons()` method.
- **Pokémon Nickname Editor**:
  - Modal dialog interface for assigning, editing, or deleting custom nicknames.
  - Inline pencil edit icon directly beside the Pokémon's name on the detail view.
  - Centralized state persistence in Riverpod.
  - Visual display prioritizing the custom nickname as the primary title with the canonical species name as the subtitle.
- **Favorite Pokémon & Retractable Panel**:
  - Add or remove Pokémon from favorites globally.
  - Collapsible, animated favorites panel embedded in the home page navigation area.
  - Immediate state reflection when favorites are added, removed, or empty.
- **Pokéball Favorite Indicator**:
  - Small Pokéball icon on each card indicating favorite status (filled active state vs outlined inactive state).
  - Tap interaction with scale micro-animation that updates global state without triggering card navigation.
- **Pokémon Type Filter**:
  - Downward-expandable filter panel featuring all 18 elemental types in canonical order (Normal, Fire, Water, Electric, Grass, Ice, Fighting, Poison, Ground, Flying, Psychic, Bug, Rock, Ghost, Dragon, Dark, Steel, Fairy).
  - Smooth expansion and selection micro-animations.
  - Reactive derivation displaying only matching Pokémon.
  - Clear filter control to restore the complete roster.
- **VCS & Branching**:
  - Branch out from `state-mgt-act` to `midterm-exam`.

## Implementation & Solutions

### 1. Architecture & State Management (Riverpod)
The application architecture replaces `package:provider` with `package:flutter_riverpod` (`^2.6.1`), organized under [lib/providers/pokemon_provider.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/providers/pokemon_provider.dart):
- **`pokemonListProvider` (`AsyncNotifier<List<Pokemon>>`)**: Encapsulates async lifecycle states (loading, error, data). Exposes `fetchPokemons({bool forceRefresh})`, which is directly called by `RefreshIndicator` and the AppBar refresh action without duplicate wrapper methods.
- **`favoritesProvider` (`Notifier<Set<int>>`)**: Maintains the set of favorited Pokémon IDs, exposing `toggleFavorite` and `removeFavorite`.
- **`nicknamesProvider` (`Notifier<Map<int, String>>`)**: Stores custom Pokémon nicknames mapped by ID, exposing `setNickname` and `removeNickname`.
- **`selectedTypeFilterProvider` (`Notifier<String?>`)**: Holds the active elemental type filter.
- **`filteredPokemonsProvider` (`Provider<List<Pokemon>>`)**: Declaratively derives the filtered list by subscribing to both `pokemonListProvider` and `selectedTypeFilterProvider`.
- **`selectedPokemonProvider` (`Notifier<Pokemon?>`)**: Manages the active Pokémon for detail screen routing without ephemeral route arguments.

### 2. UI Components & Shadcn-Inspired Aesthetics
- **[lib/widgets/pokeball_icon.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/pokeball_icon.dart)**: Custom Canvas-painted Pokéball component supporting an outlined slate inactive state and an authentic two-tone red/white filled active state.
- **[lib/widgets/favorites_panel.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/favorites_panel.dart)**: Retractable top drawer utilizing `AnimatedSize` with `Curves.easeOutCubic`, horizontal cards with quick-remove buttons, and a clean empty state.
- **[lib/widgets/type_filter_bar.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/type_filter_bar.dart)**: Horizontal pill badge list with 12px (0.75rem) rounded corners, subtle shadows, and an animated clear action positioned for accessible tap targets.
- **[lib/widgets/nickname_dialog.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/nickname_dialog.dart)**: Shadcn-inspired modal dialog featuring text input, autofocus, Save, and destructive Remove actions.
- **[lib/widgets/pokemon_card.dart](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/lib/widgets/pokemon_card.dart)**: Borderless PokémonDB card layout integrating title/subtitle nickname hierarchy and animated Pokéball favorite toggle.

## Setup & Dependencies

### Prerequisites
- Flutter SDK `^3.10.1`
- Dart SDK `^3.1.0`

### Dependencies
Defined in [pubspec.yaml](file:///C:/Users/HP/Documents/GitHub/Flutter%20Midterm%20Exam/pubspec.yaml):
- `flutter`: Flutter SDK
- `cupertino_icons`: `^1.0.8`
- `http`: `^1.6.0`
- `flutter_riverpod`: `^2.6.1`
- `flutter_lints`: `^6.0.0` (dev)
- `flutter_test`: Flutter SDK (dev)

### Execution Steps
1. Fetch project dependencies:
   ```bash
   flutter pub get
   ```
2. Verify code analysis and lints:
   ```bash
   flutter analyze
   ```
3. Run the automated test suite:
   ```bash
   flutter test
   ```
4. Launch the application:
   ```bash
   flutter run
   ```
