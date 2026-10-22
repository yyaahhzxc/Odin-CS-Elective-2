# 🎙️ Starter Pokédex — Midterm Exam Video Presentation Script
**Course:** CS Elective 2: Mobile Development with Flutter  
**Target Duration:** ~7 to 8 minutes (Well below the 10-minute limit)  
**Style:** Natural, conversational reporting — speaking directly to the camera/mic while switching between Chrome and VS Code  
**Setup:** Split screen or quick `Alt + Tab` between **Google Chrome** and **VS Code**

---

## 🕒 Outline at a Glance
| Section | Focus | View | Est. Time |
| :--- | :--- | :--- | :--- |
| **1. Intro** | Welcome, project overview, core objectives | Chrome | 0:00 – 0:45 |
| **2. Feed & Refresh** | Gens 1–9 starters, in-place refresh | Chrome | 0:45 – 1:20 |
| **3. Type Filter** | Filter by Fire, Dragon empty state, clear filter | Chrome | 1:20 – 2:05 |
| **4. Favorites System** | Pokeball toggle, count badge, favorites panel | Chrome | 2:05 – 2:55 |
| **5. Nickname & Details**| Detail screen, edit nickname, naming hierarchy | Chrome | 2:55 – 3:45 |
| **6. Question 1: Code** | **The 5 Folders Explained with Exact Line Numbers & Dev Reflections** | VS Code | 3:45 – 5:25 |
| **7. Question 2: State** | Significance of state management (General & App) | VS Code | 5:25 – 6:20 |
| **8. Question 3: Riverpod**| Why Riverpod over BLoC and Provider? | VS Code | 6:20 – 7:15 |
| **9. Wrap Up** | Test suite results (10/10 passed), sign-off | VS Code | 7:15 – 7:45 |

---

## 🎬 PART 1: Live Chrome Demo (0:00 – 3:45)

### 1. Introduction (0:00 – 0:45)
**[SCREEN: Google Chrome — Starter Pokédex Home Screen]**

> *"Hey everyone! Welcome to my presentation for the Midterm Exam in Mobile Development with Flutter.
>
> *For this exam, we were tasked with migrating our Pokédex application from traditional Provider to a new state management solution — choosing between Riverpod and BLoC. I chose **Riverpod**.
>
> *Our goal was to implement five core features: asynchronous list management, a custom nickname editor, a retractable favorites panel, favorite indicators, and elemental type filtering.
>
> *First, I’m going to demo each of these five features live in Google Chrome. Then, we’ll switch over to VS Code where I’ll walk through the five folders in our codebase, show you the exact lines of code, and answer the exam questions. Let’s get started!"*

---

### 2. Feature 1: Main Feed & In-Place Refresh (0:45 – 1:20)
**[SCREEN: Google Chrome — Scroll down the home screen]**

> *"Here on the home page, the app displays all 27 starters across Generations 1 through 9 fetched from PokéAPI. Each card shows the Pokémon's image, Pokédex number, name, and type badges, organized cleanly by generation.

**[ACTION: Click the Refresh icon in the AppBar, or pull down to refresh]**

> *For list management, if I click the refresh button in the AppBar — or pull down on the list — it triggers an in-place refresh. It re-calls our existing `fetchPokemons()` method directly on our state notifier, keeping the user on the screen while updating data in the background."*

---

### 3. Feature 5: Type Filter (1:20 – 2:05)
**[SCREEN: Google Chrome — Point to Filter by Type bar]**

> *"Next is the **Type Filter**. Both the filter bar and the favorites panel start collapsed by default so the screen stays clean.

**[ACTION: Click 'Expand' on the Filter by Type card]**

> *When I click 'Expand', we see all 18 elemental types.

**[ACTION: Click 'FIRE']**

> *If I select 'FIRE', the grid instantly updates to show only Fire-type starters like Charmander and Cyndaquil.

**[ACTION: Click 'DRAGON']**

> *If I select a type with no starters, like 'DRAGON', the header tells us `0 filtered Dragon-type Pokémon found`, and below we get an empty message: `No Pokémon found matching type "Dragon".`

**[ACTION: Click 'ALL']**

> *To clear the filter, we just tap 'ALL', and the full roster comes right back."*

---

### 4. Features 3 & 4: Favorites & Retractable Panel (2:05 – 2:55)
**[SCREEN: Google Chrome — Point to cards]**

> *"Now for **Favorites** and the **Favorites Panel**.

**[ACTION: Tap the Pokéball icon on Bulbasaur and Charmander]**

> *On each card, there is a Pokéball indicator. Tapping it marks the Pokémon as a favorite and fills the icon with red and white. Notice that tapping this icon only toggles favorite status — it doesn't open the card.

**[ACTION: Point to the 'Favorites' card count badge, then click 'Expand']**

> *Look at the 'Favorites' panel above: the badge immediately shows '2'. Expanding it reveals our favorited Pokémon in horizontal cards.

**[ACTION: Click the remove button on one card inside the favorites panel]**

> *If I click remove on one of these cards, it disappears from the panel, the badge updates, and the card's indicator returns to an outline. If all are removed, an empty state message is shown."*

---

### 5. Feature 2: Nickname Editor & Detail View (2:55 – 3:45)
**[SCREEN: Google Chrome — Click on Charmander card to open Detail Screen]**

> *"Finally, let’s look at the **Nickname Editor** and the Detail Screen.
>
> *Clicking on Charmander opens its details page, displaying its artwork, stats, and types.

**[ACTION: Click the edit pencil icon beside Charmander's name]**

> *Clicking the pencil icon opens the modal Nickname Dialog.

**[ACTION: Type 'Blaze' and click 'Save']**

> *Let’s type in 'Blaze' and click Save. Notice that 'Blaze' is now the primary title in bold, while the canonical name 'Charmander' stays visible as the subtitle.

**[ACTION: Click back arrow to return to Home Screen]**

> *When we go back to the main grid, Charmander's card also shows 'Blaze' as the primary title and 'Charmander' underneath, fulfilling the required nickname hierarchy."*

---

## 🎬 PART 2: Code Walkthrough & Exam Questions (3:45 – 7:45)

### 6. Question 1: Code Structure & The 5 Folders Explained (3:45 – 5:25)
**[SCREEN: SWITCH TO VS CODE]**  
**[ACTION: Open File Explorer on the left showing `lib/` and its 5 folders]**

> *"Now let's switch to VS Code to address **Question 1: Explain your code and how you did the application.**
>
> *Inside our `lib/` directory, the code is organized into five clean folders: `models`, `services`, `providers`, `screens`, and `widgets`. I'll walk through each folder and show you the exact lines of code.*

---

#### Folder 1: `lib/models/`
**[ACTION: Open `lib/models/pokemon.dart` — Highlight Lines 1–12 and Lines 14–51]**

> *1. First is **`models/`**, containing `pokemon.dart`.*  
> - *On **Lines 1 to 12**, we define our `Pokemon` data class with immutable properties for `id`, `name`, `imageUrl`, and elemental `types`.*  
> - *On **Lines 14 to 51**, the `Pokemon.fromJson` factory parses PokéAPI's raw response.*  
>
> *(Side comment)*: *To be honest, this part was a little weird when I first started reading the raw PokéAPI JSON — the official artwork is buried four layers deep under `sprites['other']['official-artwork']['front_default']`. It felt strange drilling that far down just for an image, but writing that safe null-check on **Line 28** makes it super intuitive and guarantees the app never crashes even if an image URL is missing.*  
> - *On **Lines 53 to 70**, we have clean getters like `formattedId` for the `#0001` format and `generation` to group starters into Regions.*

---

#### Folder 2: `lib/services/`
**[ACTION: Open `lib/services/poke_api_service.dart` — Highlight Lines 5–31 and Lines 52–64]**

> *2. Next is **`services/`**, containing `poke_api_service.dart`.*  
> - *On **Lines 5 to 31**, `PokeApiService` holds a static list of the 27 starter Pokémon IDs across Generations 1 through 9.*  
> - *On **Lines 52 to 64**, `fetchStarterPokemons()` fetches all 27 Pokémon concurrently.*  
>
> *(Side comment)*: *When I was first building this, I tried fetching the starters one-by-one with a simple loop, and it felt super slow. Switching to `Future.wait` on **Line 57** felt like a huge lightbulb moment — it fires all 27 HTTP requests in parallel so the entire Pokédex loads in under a second. It looked a bit advanced at first glance, but in Dart it's just a clean one-liner that makes complete sense.*

---

#### Folder 3: `lib/providers/`
**[ACTION: Open `lib/providers/pokemon_provider.dart` — Highlight Lines 11–30, Lines 36–59, and Lines 110–122]**

> *3. Third is **`providers/`**, which houses all of our Riverpod state management in `pokemon_provider.dart`.*  
> - *On **Lines 11 to 30**, `PokemonListNotifier` extends `AsyncNotifier` to handle loading, error, and data states.*  
>
> *(Side comment)*: *Coming from `setState` or basic ChangeNotifier, using `AsyncNotifier` felt a bit weird at first because you don't keep manual `bool isLoading` flags anymore. But setting `state = const AsyncValue.loading()` on **Line 23** is so intuitive — it automatically tells the UI to show a loader without needing to manually toggle flags back and forth.*  
> - *On **Lines 36 to 59**, `FavoritesNotifier` manages favorited IDs using an immutable `Set<int>` with `toggleFavorite()` on **Line 44**.*  
> - *On **Lines 61 to 81**, `NicknamesNotifier` stores custom nicknames mapped by Pokémon ID.*  
> - *On **Lines 110 to 122**, `filteredPokemonsProvider` is our derived provider that watches both the list and the active type filter, automatically recomputing the filtered output whenever either changes.*

---

#### Folder 4: `lib/screens/`
**[ACTION: Open `lib/screens/pokedex_screen.dart` — Highlight Line 128 and Lines 142–149]**

> *4. Fourth is **`screens/`**, containing our top-level views:*  
> - *In `pokedex_screen.dart`, on **Line 128**, we wrap the list in a `RefreshIndicator` calling `fetchPokemons(forceRefresh: true)`.*  
>
> *(Side comment)*: *What's really neat here is that both the pull-to-refresh on line 128 and the AppBar refresh button call the exact same `fetchPokemons()` method on our notifier. We didn't have to write any duplicate logic or separate handlers.*  
> - *On **Lines 142 to 149**, we embed `TypeFilterBar` and `FavoritesPanel` right at the top of the scroll view.*  
> - *In `pokemon_detail_screen.dart`, on **Lines 167 to 195**, we display the nickname hierarchy and the pencil edit button that triggers `NicknameDialog.show()` on **Line 187**.*

---

#### Folder 5: `lib/widgets/`
**[ACTION: Open `lib/widgets/nickname_dialog.dart` — Highlight Lines 42–45, then `pokemon_card.dart` Lines 114–137]**

> *5. Finally, **`widgets/`** contains our reusable components:*  
> - *In `nickname_dialog.dart`, on **Lines 42 to 45**, our `TextEditingController` is properly disposed in `dispose()`.*  
>
> *(Side comment)*: *Disposing the controller here on line 43 is a small detail, but super important in Flutter. It's really easy to forget in dialogs, but cleaning it up prevents memory leaks every time a user edits a nickname.*  
> - *In `pokemon_card.dart`, on **Lines 114 to 137**, the card checks Riverpod state: if a nickname exists, it displays the nickname as the title and the species name as the subtitle.*  
> - *Other widgets include `FavoritesPanel`, `TypeFilterBar`, and `PokeballIcon`.*

---

### 7. Question 2: Significance of State Management (5:25 – 6:20)
**[SCREEN: VS CODE — Keep `pokemon_provider.dart` open]**

> *"Now let's address **Question 2: What is the significance of using state management in general, and in the context of this app?***
>
> *In general, state management separates business logic from UI layout. It creates a single source of truth, prevents spaghetti code, and ensures predictable data flow.
>
> *In the context of **our app specifically**, local widget `setState` simply cannot handle multi-widget and multi-screen synchronization:*
> 1. *When a user favorites a Pokémon on the detail screen or on a card, that update must reflect across three places at once: the card’s Pokéball icon, the favorites panel count badge, and the panel’s item list.*
> 2. *When a user edits a nickname in a dialog, both the detail view and the home grid card must update simultaneously.*
>
> *If we only used `setState`, we’d have to pass data and callbacks up and down dozens of widgets — which is called prop drilling. That quickly leads to bugs and stale data. Riverpod solves this by letting any widget subscribe directly to the exact state it needs."*

---

### 8. Question 3: Why Choose Riverpod Over BLoC and Provider? (6:20 – 7:15)
**[SCREEN: VS CODE — Point to `filteredPokemonsProvider` on Line 110 of `pokemon_provider.dart`]**

> *"The third question asks: **Why did we choose Riverpod over BLoC and traditional Provider?***
>
> *First, **why Riverpod over traditional Provider?***
> - *Riverpod is completely **compile-safe**. Classic Provider depends on `BuildContext` to find state at runtime. If a provider is accessed outside of scope, the app crashes with a runtime `ProviderNotFoundException`. Riverpod providers are declared at top-level, making those crashes impossible.*
> - *Riverpod handles **derived state** natively. As you can see on **Line 110**, `filteredPokemonsProvider` simply watches the list provider and the filter provider. Whenever either changes, Riverpod automatically recalculates the filtered list without any manual listeners. It almost felt weirdly too simple when writing it, but it just works.*
>
> *Second, **why Riverpod over BLoC?***
> - *BLoC requires extensive boilerplate: separate event classes, state classes, event handlers, and stream subscriptions for every small action.*
> - *Riverpod gives us the exact same architectural benefits — unidirectional data flow, immutability, and testability — but using clean, readable classes like `Notifier` and `AsyncNotifier` without the boilerplate overload."*

---

### 9. Verification & Conclusion (7:15 – 7:45)
**[SCREEN: VS CODE — Integrated Terminal showing `flutter test`]**

> *"To wrap up, we verified code quality through automated checks:*
> - *Running `flutter analyze` reports zero issues and zero warnings.*
> - *Running `flutter test` executes our full test suite — testing Riverpod state, filtering, favorites, and nickname hierarchy — with all 10 unit and widget tests passing 100%.*
> - *All work has been committed and pushed to the designated `midterm-exam` branch on GitHub.*
>
> *That concludes my presentation of the Starter Pokédex midterm exam. Thank you for listening!"*
