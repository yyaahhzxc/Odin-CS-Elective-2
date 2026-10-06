# Starter Pokédex State Management (Gen 1–9)

## Project Overview
Starter Pokédex is a Flutter application that fetches and displays the complete roster of Grass, Fire, and Water starter Pokémon across Generations 1 through 9 from PokéAPI, utilizing Provider architecture to manage centralized application state, dynamic routing, and data refreshing.

## Tasked Instructions / Requirements
- **Data Source**: Fetch data from PokéAPI (`https://pokeapi.co/api/v2/pokemon`).
- **Dataset Limitation**: Limit results to 30 Pokémon (implemented with the 27 starter Pokémon across Gens 1–9).
- **Designated Model Class**: Create a dedicated class for each Pokémon encapsulating `name`, `image`, and `ID`.
- **State Management via Provider**: Manage discrete lifecycle states utilizing `package:provider`:
  - Success State (rendered Pokémon information).
  - Loading State.
  - Error State.
- **Scrollable Grid Presentation**: Display Pokémon in a responsive, scrollable grid layout organized by generation.
- **Provider-Encapsulated API Execution**: Network fetching operations must be encapsulated directly as a method within the Provider.
- **Refresh Functionality**: Provide user-triggered refresh capability on the main page that re-executes the API call.
- **Strict App State Consumption**: All UI values across screens must be sourced strictly from centralized App State rather than ephemeral widget state.
- **Dedicated Pokémon Detail View**: Implement an individual page for any clicked Pokémon, with its name, image, and ID derived directly from the Provider.
- **VCS & Branching**: Submit on dedicated branch `state-mgt-act`.

## Implementation & Solutions

### 1. Architectural Architecture & Folder Structure
The codebase follows a clean, modular structure:
- `lib/models/pokemon.dart`: Strongly-typed `Pokemon` data model containing `id`, `name`, `imageUrl`, and `types`, with deserializer `Pokemon.fromJson` and helper getters (`formattedId`, `displayName`, `generation`, `regionName`).
- `lib/services/poke_api_service.dart`: Encapsulates low-level HTTP communication with PokéAPI using `package:http`. Uses `Future.wait` for concurrent retrieval of starter Pokémon.
- `lib/providers/pokemon_provider.dart`: Core App State manager extending `ChangeNotifier`:
  - State fields: `List<Pokemon> _pokemons`, `Pokemon? _selectedPokemon`, `PokemonStateStatus _status`, `String _errorMessage`.
  - Methods: `fetchPokemons({bool forceRefresh = false})`, `selectPokemon(Pokemon pokemon)`, and `clearSelectedPokemon()`.
  - Encapsulates API request dispatching and state machine transitions (initial, loading, success, error).
- `lib/widgets/`: Modular UI presentation components:
  - `pokemon_card.dart`: Interactive borderless Pokémon item handling tap events to dispatch `provider.selectPokemon(pokemon)` and navigate to the detail view.
  - `type_badge.dart`: Element badge pill rendering PokémonDB authentic colors.
  - `loading_view.dart`: Centered progress indicator for in-flight requests.
  - `error_view.dart`: Error presentation view with retry trigger.
  - `empty_view.dart`: Fallback empty view.
- `lib/screens/pokedex_screen.dart`: Main screen observing `PokemonProvider`. Renders the loading, error, empty, or scrollable generation-divided grid based on provider state. Connects `RefreshIndicator` and header action to `provider.fetchPokemons(forceRefresh: true)`.
- `lib/screens/pokemon_detail_screen.dart`: Detail screen consuming `context.watch<PokemonProvider>().selectedPokemon`. Derives all UI values (name, image, ID, elemental types, generation, and region) from App State with zero ephemeral route arguments.

### 2. Provider State Management & Separation of Concerns
1. **Centralized App State**:
   Rather than maintaining local widget state (`setState` or `FutureBuilder`), the application injects `PokemonProvider` at the root via `ChangeNotifierProvider`. Both `PokedexScreen` and `PokemonDetailScreen` are stateless consumers of this centralized store.
2. **Deterministic State Transitions**:
   The lifecycle is driven by `PokemonStateStatus` (`initial`, `loading`, `success`, `error`), enabling deterministic UI updates across loading spinners, error banners with retry capabilities, and the populated grid.
3. **Decoupled Detail Navigation**:
   Clicking a card invokes `selectPokemon(pokemon)` on `PokemonProvider`. `PokemonDetailScreen` retrieves `provider.selectedPokemon`, ensuring the screen is fully decoupled from route arguments and strictly adheres to App State requirements.

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
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Running the Application
1. Clone the repository and checkout the activity branch:
   ```bash
   git checkout state-mgt-act
   ```
2. Install project dependencies:
   ```bash
   flutter pub get
   ```
3. Run static analysis:
   ```bash
   flutter analyze
   ```
4. Execute the test suite:
   ```bash
   flutter test
   ```
5. Launch the application:
   ```bash
   flutter run
   ```
