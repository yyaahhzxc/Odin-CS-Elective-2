import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  final service = PokeApiService();
  ref.onDispose(() => service.dispose());
  return service;
});

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    return _fetch();
  }

  Future<List<Pokemon>> _fetch() async {
    final apiService = ref.read(pokeApiServiceProvider);
    return await apiService.fetchStarterPokemons();
  }

  Future<void> fetchPokemons({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (state.hasValue && !forceRefresh) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(() {
  return PokemonListNotifier();
});

class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  void toggleFavorite(int id) {
    if (state.contains(id)) {
      state = Set<int>.from(state)..remove(id);
    } else {
      state = Set<int>.from(state)..add(id);
    }
  }

  void removeFavorite(int id) {
    if (state.contains(id)) {
      state = Set<int>.from(state)..remove(id);
    }
  }

  bool isFavorite(int id) => state.contains(id);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(() {
  return FavoritesNotifier();
});

class NicknamesNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => <int, String>{};

  void setNickname(int id, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(id);
      return;
    }
    state = Map<int, String>.from(state)..[id] = trimmed;
  }

  void removeNickname(int id) {
    if (state.containsKey(id)) {
      state = Map<int, String>.from(state)..remove(id);
    }
  }

  String? getNickname(int id) => state[id];
}

final nicknamesProvider =
    NotifierProvider<NicknamesNotifier, Map<int, String>>(() {
  return NicknamesNotifier();
});

class TypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectType(String? type) {
    if (state == type) {
      state = null;
    } else {
      state = type;
    }
  }

  void clearFilter() {
    state = null;
  }
}

final selectedTypeFilterProvider =
    NotifierProvider<TypeFilterNotifier, String?>(() {
  return TypeFilterNotifier();
});

final filteredPokemonsProvider = Provider<List<Pokemon>>((ref) {
  final asyncPokemons = ref.watch(pokemonListProvider);
  final selectedType = ref.watch(selectedTypeFilterProvider);

  final pokemons = asyncPokemons.value ?? [];
  if (selectedType == null) {
    return pokemons;
  }

  return pokemons
      .where((p) => p.types.any((t) => t.toLowerCase() == selectedType.toLowerCase()))
      .toList();
});

class SelectedPokemonNotifier extends Notifier<Pokemon?> {
  @override
  Pokemon? build() => null;

  void selectPokemon(Pokemon pokemon) {
    state = pokemon;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedPokemonProvider =
    NotifierProvider<SelectedPokemonNotifier, Pokemon?>(() {
  return SelectedPokemonNotifier();
});
