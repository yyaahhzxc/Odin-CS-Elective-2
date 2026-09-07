# CSShop - CSSEC Merch Store

## Project Overview
CSShop is a responsive e-commerce mobile and web application developed for the Computer Studies Student Executive Council (CSSEC), providing an accessible, themed browsing and shopping experience for student council merchandise with an end-to-end cart and checkout workflow.

## Tasked Instructions / Requirements
- [x] **Milestone Deliverable (First Half):** Complete design theme, home screen catalog, and Navigation 2.0 routing to a product details page.
- [x] **Design Theming (Material 3):** Centralized `ThemeData` applied at the `MaterialApp` level using the official CSSEC violet brand palette (`#6D28D9` / `#8B5CF6`), with zero hardcoded inline colors.
- [x] **Light/Dark Mode Dynamic Toggle:** Fully functional theme mode switcher accessible via the `AppBar` on the Home screen that immediately updates the entire application.
- [x] **Responsive Product Grid:** Dynamic product catalog utilizing `LayoutBuilder` and `GridView.builder` to adaptively render a 2-column grid on mobile displays (`< 600px`), 3 columns on tablets (`600px - 900px`), and 4 columns on desktop displays (`>= 900px`).
- [x] **Zero Overflow Guarantee:** Dynamic `childAspectRatio` mathematically derived from actual column widths (`cardWidth / (cardWidth + 96)`), preventing RenderFlex overflow across all device viewports.
- [x] **Navigation 2.0 (`go_router`):** Declarative route management configuring root (`/`), parameterized product routes (`/product/:id`), cart (`/cart`), and guarded checkout routes (`/checkout`) with natural slide transitions.
- [x] **Interactive Product Details Screen:** Supports product variations (color, sub-id, custom pricing), multiple image angles (front/back), quantity adjustment, and Add to Cart action.
- [x] **Adaptive Tablet & Desktop Details Layout:** Shopee-inspired two-column side-by-side layout for displays with width `>= 700px`, transitioning gracefully to a single-column layout on mobile.
- [x] **Shopping Cart Screen (`/cart`):** Displays all added items with variant tags, thumbnail imagery, unit prices, and per-item subtotals.
- [x] **Live Running Total & Stateful Quantity Control:** Interactive `+` and `-` quantity controls that dynamically recalculate subtotals and the overall running total in real time.
- [x] **Checkout Confirmation Screen (`/checkout`):** Final post-checkout screen rendering an itemized receipt summary (items, subtotal per item, gross total, confirmation message, order ID, and pickup details).
- [x] **Route Guard Protection:** Navigation 2.0 redirect guard guaranteeing that the Checkout Confirmation screen is reachable only after at least one item is present in the cart.
- [x] **Stateless vs. Stateful Architecture:** Strict separation where static UI displays (cards, receipt summary) remain `StatelessWidget` and interactive controls (theme switching, category filters, variant selection, quantity steppers, cart mutations) utilize `StatefulWidget` with clear technical justifications.
- [x] **Presentation-Ready Codebase:** Clear, academically sound comments and documentation prepared for code presentation and oral examination defense.

## Implementation & Solutions
- **Theming Architecture (`lib/theme/app_theme.dart`):** Implements static getters `AppTheme.lightTheme` and `AppTheme.darkTheme` with tailored `ColorScheme.fromSeed`, custom `CardThemeData`, `AppBarThemeData`, and `TextTheme`. Color references strictly flow from `Theme.of(context)`.
- **Cart State Management (`lib/state/cart_state.dart` & `lib/models/cart_item.dart`):** Employs standard Flutter SDK primitives (`ChangeNotifier` and `InheritedNotifier`) through `CartManager` and `CartScope`. Manages atomic item mutations (`addItem`, `incrementQuantity`, `decrementQuantity`, `removeItem`, `clearCart`) with zero external package bloat.
- **State Management & Lifecycle (`lib/main.dart`, `lib/screens/home_screen.dart`, `lib/screens/product_detail_screen.dart`, `lib/screens/cart_screen.dart`):** Root `CSShopApp` coordinates application-wide `ThemeMode` transitions and wraps the tree with `CartScope`. `HomeScreen` manages category filtering. `ProductDetailScreen` manages variant switching and gallery angles. `CartScreen` manages live quantity steppers and recalculates totals instantly.
- **Data Modeling & Inheritance (`lib/models/product.dart`, `lib/models/cart_item.dart` & `lib/data/product_data.dart`):** Features immutable `Product` and `ProductVariant` models with fallback property inheritance, alongside `CartItem` representing line items with dynamic unit pricing and computed subtotals.
- **Responsive Layouts (`lib/screens/home_screen.dart`, `lib/screens/product_detail_screen.dart`, `lib/screens/cart_screen.dart`):** `HomeScreen` adapts grid column counts dynamically via `LayoutBuilder`. `ProductDetailScreen` adapts between a side-by-side gallery/info layout (`>= 700px`) and a stacked mobile view. `CartScreen` shifts between a two-column desktop layout (items left, summary right) and a mobile view with a sticky bottom checkout bar.
- **Routing & Route Guards (`lib/router/app_router.dart`):** Configures declarative `GoRouter` routes with custom right-to-left `SlideTransition` animations and an automated redirect guard on `/checkout` to block invalid empty-cart checkouts.
- **Asset Fallback Protection (`lib/widgets/product_card.dart`, `lib/screens/product_detail_screen.dart`, `lib/screens/cart_screen.dart`):** Validates asset availability before rendering `Image.asset()`, falling back to clean shopping bag icons with `errorBuilder` to eliminate 404 network warnings.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1`

### Dependencies
- `flutter`: Flutter SDK
- `go_router`: `^17.5.0` (Declarative Navigation 2.0)
- `cupertino_icons`: `^1.0.8`

### Installation and Execution
1. Switch to the `PrelimExam` branch:
   ```bash
   git checkout PrelimExam
   ```
2. Retrieve package dependencies:
   ```bash
   flutter pub get
   ```
3. Run automated tests and static analysis:
   ```bash
   flutter test
   flutter analyze
   ```
4. Launch the application on an emulator, connected device, or web browser:
   ```bash
   flutter run
   ```
