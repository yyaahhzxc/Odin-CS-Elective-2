# CSShop - CSSEC Merch Store

## Project Overview
CSShop is a responsive e-commerce mobile and web application developed for the Computer Studies Student Executive Council (CSSEC), providing an accessible, themed browsing and shopping experience for student council merchandise with an end-to-end cart, Supabase PostgreSQL backend integration, live price filtering, and paginated catalog browsing.

## Tasked Instructions / Requirements
- [x] **Branching & Submission:** Work executed and submitted on dedicated branch `backend-filter-pagination`.
- [x] **Supabase Backend Integration:** Connect Flutter frontend to Supabase PostgreSQL database using `supabase_flutter`.
- [x] **Database Schema & RLS:** Create `products` table in Supabase with primary key, column typing, row-level security (RLS), and public SELECT access policy.
- [x] **Expanded Catalog Data:** Seed catalog with 18 products across Apparel and Accessories (including asset-backed merchandise and placeholder items) to enable multi-page pagination.
- [x] **Price Filtering (Range Slider):** Customers can specify a price range via an interactive `RangeSlider` (₱0 to ₱1,500) that filters products through backend PostgREST query constraints (`.gte('price', min).lte('price', max)`).
- [x] **Offset Pagination:** Catalog displays a maximum of 6 products per page (satisfying the 6–8 items per page requirement) using Supabase range queries (`.range(from, to)` with exact matching count retrieval).
- [x] **Frontend State Management:** Manage catalog loading, price boundaries, category filtering, and page navigation via `CatalogManager` (`ChangeNotifier`) and `CatalogScope` (`InheritedNotifier`).
- [x] **Responsive Pagination Controls:** Bottom navigation bar featuring `Previous` and `Next` action buttons and dynamic `Page X of Y` indicator with boundary protection.
- [x] **Defensive Asset Fallback:** Placeholder merchandise without local asset graphics seamlessly render with a fallback shopping bag icon to eliminate broken image links.
- [x] **Automated Testing Suite:** Comprehensive unit and widget tests covering catalog state management, page boundary clamping, price filtering, and pagination UI interactions.

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
