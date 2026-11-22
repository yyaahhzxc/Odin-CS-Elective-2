# PokéMart - Flutter E-Commerce Project

## Project Overview
PokéMart is a role-based, multi-platform e-commerce application developed in Flutter that allows trainers to browse, search, filter, and purchase Pokémon items and gear, while enabling store administrators to manage products, categories, and customer orders. The application is structured with a layered Riverpod architecture and backed by Supabase (Auth, PostgreSQL, Row Level Security, and Storage).

## Tasked Instructions / Requirements
- [x] **Authentication & Auth Gate:** Email or username/password, Google OAuth, and GitHub OAuth sign-in with automatic `public.profiles` provisioning (`customer` role by default) and router-level authentication gating at `/login` so signed-out users cannot view protected catalog or account data.
- [x] **Role-Based Access Control (Customer vs. Admin):** Strict separation of Customer and Admin experiences in both the Flutter UI and PostgreSQL Row Level Security (RLS) policies, with role status resolved directly from the database (`public.profiles` + `public.roles`).
- [x] **Admin Product & Category Management (CRUD):**
  - Floating Action Button (`+ Add Product`) on the catalog screen for Admins.
  - Pre-filled Edit & Delete controls on each product card (with a confirmation dialog naming the product before deletion).
  - Validated Add/Edit Product Form (`name` required, `price >= 0`, whole-number `stock >= 0`, category selector linked to `category_id`, and Supabase Storage image upload or URL support).
  - Category management dialog (`Manage Categories`) supporting adding, renaming (with product synchronization), and deleting categories.
- [x] **Admin Order Management:** Admin Order List (`/admin/orders`) displaying all customer orders with validated status updates (`pending`, `processing`, `done`, `cancelled`).
- [x] **Customer Browsing, Search & Filtering:** Catalog across Bag Pockets with keyword search, multi-select category filter, sort options, Material 3 `RangeSlider` price filter, List/Grid toggle, and 6-item server-side Supabase pagination (`range` + exact `count`).
- [x] **Stateful Shopping Cart & Stock Guards:** Add items, adjust quantities, remove items, prevent adding out-of-stock products or exceeding available stock, and automatically clear cart, order, and catalog caches upon checkout and logout.
- [x] **Database-Authoritative Atomic Checkout & Order History:**
  - Transactional `place_order(p_items jsonb)` RPC that validates live database stock and prices, deducts stock, sets order status to `done`, and snapshots `product_name` and `unit_price` onto `order_items` without allowing direct client inserts into `orders` or `order_items`.
  - Itemized Checkout Confirmation screen (`/checkout`) rendered from the database-returned `OrderRecord` (`PKM-XXXXX`) and total.
  - Customer Order History screen (`/orders`) listing only the customer's own orders (newest first) with status, date, total, and itemized snapshots.
- [x] **Layered Architecture & Riverpod Providers:** Clean separation across `screens/` -> `providers/` (`state/`) -> `services/` -> Supabase, with zero direct Supabase imports inside UI or state layers.

## Implementation & Solutions
- **Layered Architecture & Riverpod State (`lib/providers/app_providers.dart`, `lib/state/`):** Consumed across screens and widgets via `ConsumerWidget` and `ConsumerStatefulWidget` (`authProvider`, `catalogProvider`, `cartProvider`, `orderProvider`, `themeModeProvider`, and `routerProvider`), ensuring zero data-access code inside widgets.
- **Database Schema, Triggers & RLS (`supabase_schema.sql`):**
  - Relational schema comprising `roles`, `profiles` (linked to `roles`), `categories`, `products`, `orders`, and `order_items`.
  - PostgreSQL `handle_new_user()` trigger automatically creates a `customer` profile on sign-up, normalizing email and Google OAuth metadata (`given_name`, `family_name`, `full_name`), while `resolve_email_for_username(p_username)` supports case-insensitive username sign-in.
  - PostgreSQL `is_admin()`, `prevent_role_escalation()`, and `enforce_orders_status_update_only()` triggers and RLS policies enforce the exact permission matrix across signed-out, customer, and admin roles, with `orders` and `order_items` inserts restricted exclusively to the `SECURITY DEFINER` `place_order(p_items jsonb)` RPC.
- **Declarative Routing & Role Guards (`lib/router/app_router.dart`, `lib/screens/`):**
  - `GoRouter` wired with `refreshListenable: authManager` redirects unauthenticated requests to `/login` and authenticated `/login` requests to `/`, while `/profile` hosts the Account view.
  - `HomeScreen` & `ProductCard` adapt between Customer controls (`Add to Cart`, Shopping Bag, Order History) and Admin controls (`Add Product` FAB, `Manage Categories`, `Edit` & `Delete` card actions, Admin Order List).
  - Direct URL navigation across unauthorized routes (`/cart` and `/orders` for Admins, `/admin/orders` and `/admin/product/*` for Customers) renders explicit Permission Denied views.
  - `OrdersScreen`, `AdminProductFormScreen`, and `ProductDetailScreen` handle loading, empty, error, and permission-denied states explicitly without swallowing backend errors.
- **UI Theme & Animations (`lib/theme/app_theme.dart`, `lib/widgets/animated_primitives.dart`):**
  - Pokémon GO emerald-mint (`#23CCA9`) theme with unified scaffold/card backgrounds across Light and Dark modes.
  - Built-in Flutter animation primitives (`FadeSlideIn`, `PopIn`, `PressScale`, `AnimatedValueText`, `AnimatedFavoriteIcon`) and shared `Hero` transitions without external animation dependencies.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1` or higher
- Active Supabase project (run [supabase_schema.sql](supabase_schema.sql) in the Supabase SQL Editor)

### Required Dependencies (`pubspec.yaml`)
- `flutter`: Flutter SDK
- `flutter_riverpod`: `^2.6.1`
- `supabase_flutter`: `^2.18.3`
- `go_router`: `^17.5.0`
- `image_picker`: `^1.1.2`
- `cupertino_icons`: `^1.0.8`

### Execution Instructions
1. Retrieve dependencies:
   ```bash
   flutter pub get
   ```
2. Run static analysis and unit/widget tests:
   ```bash
   flutter analyze
   flutter test
   ```
3. Run the application (using port 3000 for web OAuth redirects):
   ```bash
   flutter run -d chrome --web-port 3000
   ```
