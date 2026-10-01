# Pokédex Starters (Gen 1–9)

## Project Overview
Pokédex Starters is a Flutter application that fetches and displays the complete roster of Grass, Fire, and Water starter Pokémon across Generations 1 through 9 from PokéAPI in a clean, scrollable grid inspired by PokémonDB.

## Tasked Instructions / Requirements
- **Data Source**: Fetch data from PokéAPI (`https://pokeapi.co/api/v2/pokemon`).
- **Dataset Limitation**: Limit results to 30 Pokémon (implemented with the 27 starter Pokémon across Gens 1–9).
- **Scrollable Grid**: Display Pokémon in a responsive, scrollable grid presenting name, official artwork image, and Pokédex ID.
- **Architectural Decision (Future vs. Stream)**: Determine whether data fetching should utilize a `Future` or a `Stream`, with comprehensive justification.
- **State Handling**: Implement graceful handling for loading, error, and empty states.
- **Scope Termination**: Output strictly terminates at the grid view; no detail page navigation is introduced for this assignment.
- **Directory Structure**: Implement the required modular folder structure:
  - `models/`
  - `services/`
  - `widgets/`
  - `screens/`

## Implementation & Solutions

### 1. Folder & File Structure
The codebase strictly adheres to the requested four-tier architectural pattern:
- `lib/models/pokemon.dart`: Defines the `Pokemon` entity with strongly-typed properties (`id`, `name`, `imageUrl`, `types`), helper getters (`formattedId`, `displayName`, `generation`), and a robust `Pokemon.fromJson` deserializer navigating nested sprite and typing structures.
- `lib/services/poke_api_service.dart`: Encapsulates all network communication with PokéAPI using `package:http`. Coordinates parallel requests for the 27 starter IDs via `Future.wait` to eliminate sequential network blocking.
- `lib/widgets/`: Modular UI presentation components:
  - `pokemon_card.dart`: Minimalist PokémonDB-inspired card rendering formatted ID, official artwork, capitalized name, and typing badges.
  - `type_badge.dart`: Pill badges matching authentic PokémonDB hex color codes for all 18 elemental types.
  - `loading_view.dart`: Centered progress indicator with contextual status text.
  - `error_view.dart`: Error state banner with description and a retry action button.
  - `empty_view.dart`: Clean empty placeholder view.
- `lib/screens/pokedex_screen.dart`: Primary screen managing the async lifecycle with `initState`, `FutureBuilder`, `RefreshIndicator`, and adaptive `GridView` layouts.

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

### 3. Visual Layout: PokémonDB Aesthetic
The UI is styled to mirror the clean, minimal aesthetic of PokémonDB:
- Off-white canvas (`#F9FAFB`) with crisp bordered cards (`#E5E7EB`).
- Formatted Pokédex numbers (`#0001`, `#0152`, etc.) in muted monospace typography.
- Standard high-resolution official artwork rendered with progressive loading indicators and error fallback icons.
- Exact PokémonDB color tokens for elemental type pills.
- Adaptive grid columns: 2 columns on mobile devices, dynamically expanding to 3, 4, or 6 columns on tablet and desktop widths.

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
5. Launch the application on your connected device or emulator:
   ```bash
   flutter run
   ```
