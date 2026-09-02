# CSShop - CSSEC Merch Store

## Project Overview
CSShop is a responsive e-commerce mobile and web catalog application developed for the Computer Studies Student Executive Council (CSSEC), providing an accessible, themed browsing experience for student council merchandise.

## Tasked Instructions / Requirements
- [x] **Milestone Deliverable (First Half):** Complete design theme, home screen catalog, and Navigation 2.0 routing to a product details page.
- [x] **Design Theming (Material 3):** Centralized `ThemeData` applied at the `MaterialApp` level using the official CSSEC violet brand palette (`#6D28D9` / `#8B5CF6`), with zero hardcoded inline colors.
- [x] **Light/Dark Mode Dynamic Toggle:** Fully functional theme mode switcher accessible via the `AppBar` on the Home screen that immediately updates the entire application.
- [x] **Responsive Product Grid:** Dynamic product catalog utilizing `LayoutBuilder` and `GridView.builder` to adaptively render a 2-column grid on mobile displays (`< 600px`), 3 columns on tablets (`600px - 900px`), and 4 columns on desktop displays (`>= 900px`).
- [x] **Zero Overflow Guarantee:** Dynamic `childAspectRatio` mathematically derived from actual column widths (`cardWidth / (cardWidth + 96)`), preventing RenderFlex overflow across all device viewports.
- [x] **Navigation 2.0 (`go_router`):** Declarative route management configuring root (`/`) and parameterized product routes (`/product/:id`) with natural mobile slide transitions.
- [x] **Interactive Product Details Screen:** Supports product variations (color, sub-id, custom pricing), multiple image angles (e.g., front and back), quantity adjustment, and Add to Cart confirmation.
- [x] **Adaptive Tablet & Desktop Details Layout:** Shopee-inspired two-column side-by-side layout for displays with width `>= 700px`, transitioning gracefully to a single-column layout on mobile.
- [x] **Stateless vs. Stateful Architecture:** Strict separation where static UI displays remain `StatelessWidget` and interactive controls (theme switching, category filters, variant selection, quantity counter) utilize `StatefulWidget` with clear technical justifications.
- [x] **Presentation-Ready Codebase:** Clear, academically sound comments and documentation prepared for code presentation and oral examination defense.

## Implementation & Solutions
- **Theming Architecture (`lib/theme/app_theme.dart`):** Implements static getters `AppTheme.lightTheme` and `AppTheme.darkTheme` with tailored `ColorScheme.fromSeed`, custom `CardThemeData`, `AppBarThemeData`, and `TextTheme`. Color references strictly flow from `Theme.of(context)`.
- **State Management & Lifecycle (`lib/main.dart`, `lib/screens/home_screen.dart`, `lib/screens/product_detail_screen.dart`):** Root `CSShopApp` manages application-wide `ThemeMode` transitions via `setState()`. `HomeScreen` manages interactive category filtering (`All`, `Apparel`, `Accessories`). `ProductDetailScreen` is a `StatefulWidget` managing active variant indexing (`_selectedVariantIndex`), multi-angle image indexing (`_selectedImageIndex`), and quantity counters.
- **Data Modeling & Inheritance (`lib/models/product.dart` & `lib/data/product_data.dart`):** Features an immutable `Product` class with a nested `ProductVariant` model. Each variant carries a unique sub-id for cart and checkout preparation, while optional fields (`price`, `description`, `stock`) automatically inherit from base product properties if omitted.
- **Responsive Layouts (`lib/screens/home_screen.dart` & `lib/screens/product_detail_screen.dart`):** `HomeScreen` uses `LayoutBuilder` with dynamic aspect ratio calculation to prevent overflow on varying screen widths. `ProductDetailScreen` applies a two-column desktop/tablet layout (`width >= 700px`) separating the square image gallery on the left and product metadata/actions on the right.
- **Routing & Transitions (`lib/router/app_router.dart`):** Configures `GoRouter` declarative routes using `CustomTransitionPage` and `SlideTransition` for a smooth right-to-left push animation.
- **Asset Fallback Protection (`lib/widgets/product_card.dart` & `lib/screens/product_detail_screen.dart`):** Checks image path presence before rendering `Image.asset()`, falling back to clean placeholder icons with `errorBuilder` to eliminate 404 network warnings for items pending asset integration.

## Setup & Dependencies
### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.1`

### Dependencies
- `flutter`: Flutter SDK
- `go_router`: `^17.5.0` (Declarative Navigation 2.0)
- `cupertino_icons`: `^1.0.8`

### Installation and Execution
1. Clone the repository and switch to the `PrelimExam` branch:
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
