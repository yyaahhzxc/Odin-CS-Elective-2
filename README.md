# PokéMart - Flutter E-Commerce Project

## Project Overview
PokéMart is a responsive, multi-platform e-commerce application developed in Flutter that allows trainers to browse, filter, and purchase Pokémon items and gear. The application features a clean catalog interface, reactive cart management, and seamless PostgreSQL backend integration via Supabase.

## Tasked Instructions / Requirements
- [x] **Product Catalog & Browsing:** Browse a 48-item catalog categorized across 6 pockets (Poké Balls, Medicine, Evolution, Berries & Treats, Battle & Training, and Special Gear).
- [x] **Dual Layout Presentation:** Provide toggleable 2-column Grid and List views optimized for mobile and desktop screens.
- [x] **Dynamic Price Filtering:** Filter products via a Material 3 `RangeSlider` (₽0 to ₽5,000) backed by server-side query constraints.
- [x] **Real-Time Pagination:** Paginate catalog items at 6 items per page with exact boundary tracking, page indices, and reactive previous/next controls.
- [x] **Product Details View:** Display hero product imagery, pricing in Philippine Peso (₽), stock availability, units sold, variation selection, and interactive quantity selectors.
- [x] **Stateful Shopping Cart:** Manage cart state (`addItem`, `incrementQuantity`, `decrementQuantity`, `removeItem`, `clearCart`) with running subtotal and total calculations.
- [x] **Checkout & Order Confirmation:** Route-guarded checkout flow that snapshots order items and presents an itemized receipt with a unique Order ID.
- [x] **Light & Dark Theme:** Adaptive theme switching between Day Mode and Stadium Night Mode.
- [x] **Supabase Authentication & 3rd-Party Provider:** Integrated Google OAuth alongside email/password and username credentials with reactive session management.
- [x] **User Account & Sign-In Screen:** Clean, shadcn-inspired authentication interface offering sign in, registration with username metadata, 3rd-party Google login, guest access, and profile session controls.
- [x] **Automated Testing Suite:** 100% pass rate across unit tests and end-to-end integration widget tests with zero static analysis warnings.

## Implementation & Solutions
- **Architecture & State Management:** State is separated cleanly into `CatalogManager`, `CartManager`, and `AuthManager`, extending `ChangeNotifier` and provided down the widget tree using `InheritedNotifier` (`CatalogScope`, `CartScope`, `AuthScope`). This avoids unnecessary third-party package dependencies while maintaining predictable reactive updates.
- **Authentication & 3rd-Party OAuth (`lib/services/auth_service.dart`, `lib/state/auth_state.dart`):** Manages user sessions via Supabase Auth, supporting 3rd-party Google OAuth (`signInWithOAuth(OAuthProvider.google)`), email/password login, and user registration with username metadata. A deterministic mock mode ensures continuous testability in headless test runners and offline environments.
- **Account & Sign-In UI (`lib/screens/login_screen.dart`):** Delivers a minimalist, shadcn-inspired authentication card with mode toggling (Sign In vs. Create Account), credential validation (Username, Email, Password), an official 4-color Google OAuth action, guest navigation, and authenticated profile management.
- **Backend Query Architecture (`lib/services/supabase_service.dart`):** PostgREST range queries execute category filtering (`.eq`), price boundaries (`.gte`, `.lte`), sorting (`.order`), and offset limits (`.range(from, to)` with exact count option). An in-memory fallback ensures seamless operation in test environments and offline scenarios.
- **Product Details & Purchasing Bar (`lib/screens/product_detail_screen.dart`):** Built with an anchored bottom bar holding quantity adjusters, running total previews, and the primary "Add to Cart" action, keeping purchasing controls immediately accessible regardless of scroll offset.
- **Declarative Navigation (`lib/router/app_router.dart`):** Configured with `GoRouter` for deep linking (`/`, `/product/:id`, `/cart`, `/checkout`, `/login`), including animated transitions and navigation safety guards.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1` or higher
- Active Supabase project (PostgreSQL backend)

### Required Dependencies (`pubspec.yaml`)
- `flutter`: Flutter SDK
- `supabase_flutter`: `^2.18.3`
- `go_router`: `^17.5.0`
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
3. Run the application:
   ```bash
   flutter run
   ```
