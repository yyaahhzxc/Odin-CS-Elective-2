# PokéMart - Flutter E-Commerce Project (Pokémon GO Design System)

## Project Overview
**PokéMart** is a high-fidelity, responsive multi-platform Pokémon-themed e-commerce application faithfully designed with the official **Pokémon GO (PoGO / Niantic)** design system and datamined 3D game assets sourced from **PokeMiners**. This project delivers a production-ready shopping experience with an interactive Trainer Bag, Supabase PostgreSQL backend integration, live price filtering, and paginated catalog browsing.

Each feature milestone and course activity is checkpointed onto dedicated repository branches (`backend-filter-pagination`, `backend-auth`, etc.), demonstrating state management, declarative routing, and Supabase PostgreSQL backend integration.

## Key Features & Theming (Pokémon GO / PokeMiners)
- [x] **Authentic PoGO Design System:** Reverse-engineered from official design symbols (`branding inspo/PokemonGoUIKIT_v05_carasusan_Vallve.sketch`), featuring the signature Soft Lime-to-Emerald Mint action gradient (`#A8DD9C` ➔ `#23CCA9`), Deep Sea Teal (`#1C8696`), pure white cards (`22px` corner radius), and concentric circular action pads.
- [x] **PokeMiners Datamined 3D Asset Integration:** High-resolution 3D asset renders extracted directly from the official `PokeMiners/pogo_assets` repository, including in-game HUD icons (`btn_shop.png`, `btn_coins_small.png`, `btn_items.png`), Event Boxes (`greatbox.png`, `ultrabox.png`, `adventure_box.png`, `specialbox.png`), and official 3D item models.
- [x] **48-Item Comprehensive Catalog:** 48 authentic Pokémon GO items organized across 6 official Bag pockets:
  - **Poké Balls (6):** Poké Ball, Great Ball, Ultra Ball, Master Ball, Premier Ball, Beast Ball.
  - **Medicine (6):** Potion, Super Potion, Hyper Potion, Max Potion, Revive, Max Revive.
  - **Evolution Items (8):** Sun Stone, King's Rock, Metal Coat, Dragon Scale, Up-Grade, Sinnoh Stone, Unova Stone, Glacial Lure Module.
  - **Berries & Treats (8):** Razz Berry, Nanab Berry, Pinap Berry, Golden Razz Berry, Silver Pinap Berry, Poffin, Rare Candy, Rare Candy XL.
  - **Battle & Training (8):** Fast TM, Charged TM, Elite Fast TM, Elite Charged TM, Star Piece, Lucky Egg, Super Rocket Radar, Team Medallion.
  - **Special Gear (12):** Incubator, Super Incubator, Remote Raid Pass, Premium Battle Pass, Incense, Daily Adventure Incense, Mystery Box, Coin Bag, Postcard Book, Zygarde Cube, Sun Flute, Moon Flute.
- [x] **PokéDollar Currency & Trainer HUD:** Live PokéCoin gold readout chip (`₽` / PokéCoins) and Trainer Bag counter badge.
- [x] **Price Range Filter (Range Slider):** Customers can filter items using a Material 3 range slider (₽0 to ₽5,000) that interacts with backend PostgREST query constraints (`.gte('price', min).lte('price', max)`).
- [x] **Offset Pagination:** Real-time 6 items/page pagination via Supabase range queries (`.range(from, to)` with exact matching count retrieval).
- [x] **State Management:** Clean `ChangeNotifier` and `InheritedNotifier` architecture (`CatalogScope`, `CartScope`) without external boilerplate.
- [x] **Navigation 2.0:** Declarative routing using `GoRouter` with route guards and animated slide transitions.
- [x] **Automated Testing Suite:** Comprehensive unit and widget tests covering catalog state management, page boundary clamping, price filtering, and end-to-end checkout flow with 100% pass rate.

## Implementation & Solutions
- **Supabase Backend Configuration (`lib/core/supabase_config.dart` & `supabase_schema.sql`):** Centralizes project API endpoint and public anonymous key. Database schema defines `public.products` with RLS enabled and grants read access.
- **Backend Query Architecture (`lib/services/supabase_service.dart`):** Implements chained PostgREST queries:
  ```dart
  final response = await _client
      .from('products')
      .select('*')
      .eq('category', category)
      .gte('price', minPrice)
      .lte('price', maxPrice)
      .order('id', ascending: true)
      .range(from, to)
      .count(CountOption.exact);
  ```
  Includes an automated in-memory fallback to `mockProducts` when running offline or in unit-test harnesses.
- **Catalog State Management (`lib/state/catalog_state.dart`):** `CatalogManager` extends `ChangeNotifier` to coordinate asynchronous catalog requests, store current page index, total count, computed total pages (`ceil(totalCount / pageSize)`), and active filter values. `CatalogScope` provides scope access via `InheritedNotifier` without external state management overhead.
- **Price Slider & Pagination UI (`lib/screens/home_screen.dart`):** Features a Material 3 `RangeSlider` with localized touch-drag tracking that executes backend queries upon drag completion (`onChangeEnd`), coupled with pagination controls supporting previous/next page traversal.
- **Model Deserialization (`lib/models/product.dart`):** Supports `Product.fromJson` and `toJson` for PostgreSQL record mapping alongside original variant and formatted price getters.
- **Cart State Management (`lib/state/cart_state.dart` & `lib/models/cart_item.dart`):** Unifies cart operations (`addItem`, `incrementQuantity`, `decrementQuantity`, `removeItem`, `clearCart`) via `CartScope`.
- **Navigation 2.0 (`lib/router/app_router.dart`):** Declarative routing via `GoRouter` for catalog, product details, cart, and route-guarded checkout.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1`
- Supabase Project (PostgreSQL backend)

### Dependencies (`pubspec.yaml`)
- `flutter`: Flutter SDK
- `supabase_flutter`: `^2.18.3` (Supabase backend client)
- `go_router`: `^17.5.0` (Declarative Navigation 2.0)
- `cupertino_icons`: `^1.0.8`

### Database Setup
1. Open the Supabase dashboard and navigate to the **SQL Editor**.
2. Run the migration script located at `supabase_schema.sql`.
3. Verify that the `products` table has Row Level Security enabled with 18 seeded products.

### Installation and Execution
1. Ensure you are on the `backend-filter-pagination` branch:
   ```bash
   git checkout backend-filter-pagination
   ```
2. Retrieve package dependencies:
   ```bash
   flutter pub get
   ```
3. Run automated tests and static analysis:
   ```bash
   flutter test
   ```
   ```bash
   flutter analyze
   ```
4. Launch the application on your target device or emulator:
   ```bash
   flutter run
   ```
