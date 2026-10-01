# Pokédex Starters (Gen 1–9)

## Project Overview
Pokédex Starters is a Flutter application that fetches and displays the complete roster of Grass, Fire, and Water starter Pokémon across Generations 1 through 9 from PokéAPI in a clean, scrollable layout inspired by PokémonDB.

## Tasked Instructions / Requirements
- **Data Source**: Fetch data from PokéAPI (`https://pokeapi.co/api/v2/pokemon`).
- **Dataset Limitation**: Limit results to 30 Pokémon (implemented with the 27 starter Pokémon across Gens 1–9).
- **Scrollable Grid / Generation Rows**: Display Pokémon in a responsive, scrollable layout presenting name, official artwork image, and Pokédex ID, organized with 3 starters per generation row.
- **Architectural Decision (Future vs. Stream)**: Determine whether data fetching should utilize a `Future` or a `Stream`, with comprehensive justification.
- **State Handling**: Implement graceful handling for loading, error, and empty states.
- **Scope Termination**: Output strictly terminates at the grid/list view; no detail page navigation is introduced for this assignment.
- **Directory Structure**: Implement the required modular folder structure:
  - `models/`
  - `services/`
  - `widgets/`
  - `screens/`

## Implementation & Solutions

### 1. Folder & File Structure
The codebase strictly adheres to the requested four-tier architectural pattern:
- `lib/models/pokemon.dart`: Defines the `Pokemon` entity with strongly-typed properties (`id`, `name`, `imageUrl`, `types`), helper getters (`formattedId`, `displayName`, `generation`, `regionName`), and a robust `Pokemon.fromJson` deserializer navigating nested sprite and typing structures.
- `lib/services/poke_api_service.dart`: Encapsulates all network communication with PokéAPI using `package:http`. Coordinates parallel requests for the 27 starter IDs via `Future.wait` to eliminate sequential network blocking.
- `lib/widgets/`: Modular UI presentation components:
  - `pokemon_card.dart`: Minimalist borderless Pokémon item rendering centered official artwork, muted `#0001` ID, capitalized name, and authentic PokémonDB type pills.
  - `type_badge.dart`: Pill badges matching authentic PokémonDB hex color codes for all 18 elemental types.
  - `loading_view.dart`: Centered progress indicator with contextual status text.
  - `error_view.dart`: Error state banner with description and a retry action button.
  - `empty_view.dart`: Clean empty placeholder view.
- `lib/screens/pokedex_screen.dart`: Primary screen managing the async lifecycle with `initState`, `FutureBuilder`, `RefreshIndicator`, generation section headers, and 3-starter generation rows.

### 2. Architectural Analysis: Future vs. Stream Decision
For this assignment, **`Future` (`Future<List<Pokemon>>`) was selected over `Stream`** based on the following principles:

1. **Stateless Request-Response Semantics**:
   The application interacts with a standard RESTful HTTP endpoint (`https://pokeapi.co/api/v2/pokemon/{id}`). REST over HTTP represents discrete, single-shot request-response operations. A `Future` naturally models a computation that produces a single eventual value or throws an error.

2. **Resource Lifecycle & Memory Safety**:
   `Stream` is intended for continuous, multi-event asynchronous sequences (such as WebSockets, sensor feeds, or real-time event buses). Using a `Stream` for a fixed, bounded dataset introduces unnecessary overhead, requiring persistent subscription management, `StreamController` lifecycle handling, and risk of memory leaks if not properly canceled.

3. **Performance via Parallelism (`Future.wait`)**:
   Instead of sequentially streaming items one after another over 27 round-trips (~15+ seconds), `Future.wait` executes all 27 HTTP GET calls concurrently. Total network wait time is reduced to the single slowest request (~1 to 2 seconds).

4. **Integration with `FutureBuilder`**:
   `FutureBuilder` cleanly evaluates the discrete states of an asynchronous request (`ConnectionState.waiting`, `snapshot.hasError`, and `snapshot.hasData`), making state transitions deterministic and straightforward.

### 3. Visual Layout: PokémonDB Aesthetic & Generation Grouping
The UI is styled to mirror the clean, minimal aesthetic of PokémonDB:
- **Refined Header Bar**: Sleek white app bar featuring a Pokéball red accent indicator, clear typography, total starter count badge (`27 Starters`), and refresh action.
- **Generation Section Headers**: Each generation block is introduced with an uppercase generation label, region tag pill (e.g., `KANTO`, `JOHTO`, `HOENN`), and a hairline divider line.
- **3 Starters Per Generation Row**: The 3 starter Pokémon (Grass, Fire, Water) are aligned side-by-side in a responsive 3-column row per generation.
- **Extra Inter-Generation Spacing**: Generous vertical spacing separates each generation block to enhance visual clarity.
- **Borderless Presentation**: Elimination of enclosing card boxes, borders, and shadows, allowing the artwork and typography to integrate seamlessly on the neutral canvas.

## Setup & Dependencies

### Prerequisites
- Flutter SDK (v3.10.1 or higher)
- Dart SDK (v3.10.1 or higher)

### Dependencies
The following packages are declared in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Running the Application
1. Clone or navigate to the project directory:
   ```bash
   cd "Flutter Activity 4"
   ```
2. Install project dependencies:
   ```bash
   flutter pub get
   ```
3. Run static code analysis to verify clean code adherence:
   ```bash
   flutter analyze
   ```
4. Execute unit and widget tests:
   ```bash
   flutter test
   ```
5. Launch the application in Google Chrome:
   ```bash
   flutter run -d chrome
   ```
