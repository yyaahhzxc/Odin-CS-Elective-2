# PokéMart - Flutter E-Commerce Project

## Project Overview
PokéMart is a role-based, multi-platform e-commerce application developed in Flutter that allows trainers to browse, search, filter, and purchase Pokémon items and gear, while enabling store administrators to manage products, categories, and customer orders. The application is built with a layered Riverpod provider architecture and backed by Supabase (Auth, PostgreSQL, Row Level Security, and Storage).

## Tasked Instructions / Requirements
- [x] **Authentication & Profile Creation:** Email/password, Google OAuth, and GitHub OAuth sign-in with automatic profile creation (`public.profiles` linked to `public.roles`) where every new account defaults to the `customer` role.
- [x] **Role-Based Access Control (Customer vs. Admin):** Strict separation of Customer and Admin experiences in both the Flutter UI and PostgreSQL Row Level Security (RLS) policies.
- [x] **Admin Product & Category Management (CRUD):**
  - Floating Action Button (`+ Add Product`) on the catalog screen for Admins.
  - Pre-filled Edit & Delete controls on each product card (with a confirmation dialog naming the product before deletion).
  - Validated Add/Edit Product Form (`name` required, `price >= 0`, whole-number `stock >= 0`, category selector with category creation, and Supabase Storage image upload / URL support).
- [x] **Admin Order Management:** Admin Order List displaying all customer orders with real-time order status updates (`pending`, `processing`, `done`, `cancelled`).
- [x] **Customer Browsing, Search & Filtering:** 48-item catalog across 6 Bag Pockets with keyword search, category filter, sort options, Material 3 `RangeSlider` price filter (₽0 to ₽5,000), Dual Grid/List toggle, and 6-item pagination.
- [x] **Stateful Shopping Cart & Stock Guards:** Add items, adjust quantities, remove items, prevent adding out-of-stock products or exceeding available stock, and automatically empty the cart upon checkout and logout.
- [x] **Database-Authoritative Atomic Checkout & Order History:**
  - Transactional checkout (`place_order` RPC / service) that verifies live database stock and prices, deducts ordered quantities from stock, sets order status to `done`, and snapshots `product_name` and `unit_price` on each `order_items` record.
  - Itemized Checkout Confirmation receipt with unique Order ID (`PKM-XXXXX`) and total.
  - Customer Order History screen listing only the customer's own orders (newest first) with status, date, total, and itemized snapshots.
- [x] **Layered Architecture & Riverpod Providers:** Clean separation across `screens/` -> `providers/` (`state/`) -> `services/` -> Supabase, with zero data-access code inside UI widgets.

## Implementation & Solutions
- **Layered Architecture & State Management (`lib/providers/app_providers.dart`, `lib/state/`):** Structured with `flutter_riverpod` (`ProviderScope`, `ChangeNotifierProvider`, `Provider`) alongside scoped inherited notifiers (`AuthScope`, `CatalogScope`, `CartScope`, `OrderScope`) so screens remain free of direct Supabase queries.
- **Database Schema, Triggers & RLS (`supabase_schema.sql`):**
  - Relational schema comprising `roles`, `profiles`, `categories`, `products`, `orders`, and `order_items`.
  - PostgreSQL `handle_new_user()` trigger automatically creates a `customer` profile on sign-up using `firstname` and `lastname` metadata.
  - PostgreSQL `is_admin()` security-definer function and `prevent_role_escalation()` trigger enforce strict role authorization across all RLS policies.
  - Transactional `place_order(p_items jsonb)` RPC function guarantees atomic order creation, database-side price calculation, and stock deduction.
- **Role-Based Screens (`lib/screens/`):**
  - `HomeScreen` & `ProductCard`: Dynamically adapts between Customer view (`Add to Cart`, Shopping Bag, Order History) and Admin view (`Add Product` FAB, `Edit` & `Delete` buttons on cards, Admin Order List).
  - `AdminProductFormScreen`: Handles product creation, pre-filled editing, input validation, and binary image uploads to the `product-images` Supabase Storage bucket.
  - `OrdersScreen`: Renders either the customer's personal Order History (`/orders`) or the store-wide Admin Order List (`/admin/orders`) with status management.
  - `LoginScreen`: Provides Sign In, Sign Up (First Name, Last Name, Username, Email, Password + Confirmation), Google & GitHub OAuth, and an Account Profile view with an interactive Customer/Admin role switcher for live demonstration.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1` or higher
- Active Supabase project (run [supabase_schema.sql](file:///c:/Users/HP/Documents/GitHub/Flutter%20E-Commerce%20Project/supabase_schema.sql) in the Supabase SQL Editor)

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
2. Run test verification and static analysis:
   ```bash
   flutter test
   flutter analyze
   ```
3. Run the application (using port 3000 for web OAuth redirects):
   ```bash
   flutter run -d chrome --web-port 3000
   ```
