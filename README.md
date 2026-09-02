# CSShop - CSSEC Merch Store

## Project Overview
CSShop is a responsive e-commerce mobile catalog application developed for the Computer Studies Student Executive Council (CSSEC) at Ateneo de Davao University, providing a clean and accessible browsing experience for student council merchandise.

## Tasked Instructions / Requirements
- [x] **Milestone Deliverable (First Half):** Complete design theme, home screen catalog, and Navigation 2.0 routing to an empty details page.
- [x] **Design Theming (Material 3):** Centralized `ThemeData` applied at the `MaterialApp` level using the official Ateneo CSSEC violet brand palette (`#6D28D9` / `#8B5CF6`), with zero hardcoded inline colors.
- [x] **Light/Dark Mode Dynamic Toggle:** Fully functional theme mode switcher accessible via the `AppBar` on the Home screen that immediately updates the entire application.
- [x] **Simplified Store Header:** Clean typography displaying the CSSEC Merch Store title and council description.
- [x] **Responsive Product Grid:** Dynamic product catalog utilizing `LayoutBuilder` and `GridView.builder` to adaptively render a 2-column grid on mobile displays (`< 600px`) and 3+ columns on tablet/desktop displays (`>= 600px`).
- [x] **Navigation 2.0 (`go_router`):** Declarative route management configuring root (`/`) and dynamic parameterized product routes (`/product/:id`) with natural mobile slide transitions.
- [x] **Product Details Page:** A dedicated destination page with an `AppBar`, product image placeholder, item description, quantity selector, and Add to Cart button.
- [x] **Stateless vs. Stateful Architecture:** Strict separation where immutable UI cards remain `StatelessWidget` and interactive controls (theme switching, category filters) utilize `StatefulWidget`.
- [x] **Presentation-Ready Codebase:** Surgical, clear comments explaining widget hierarchy, state choices, and layout builders for oral exam defense.

## Implementation & Solutions
- **Theming Architecture (`lib/theme/app_theme.dart`):** Implements static getters `AppTheme.lightTheme` and `AppTheme.darkTheme` with tailored `ColorScheme.fromSeed`, custom `CardThemeData`, `AppBarThemeData`, and `TextTheme`. Color references strictly flow from `Theme.of(context)`.
- **State Management & Lifecycle (`lib/main.dart` & `lib/screens/home_screen.dart`):** Root `CSShopApp` manages application-wide `ThemeMode` transitions via `setState()`, passed into `MaterialApp.router`. `HomeScreen` manages interactive category filter state (`All`, `Apparel`, `Accessories`) to filter mock products dynamically.
- **Responsive Layout (`lib/screens/home_screen.dart`):** Employs `LayoutBuilder` to measure screen constraints dynamically, selecting 2 columns on phone screens, 3 columns on tablet screens, and 4 columns on desktop displays, maintaining a stable child aspect ratio.
- **Routing & Slide Transitions (`lib/router/app_router.dart`):** Configures `GoRouter` declarative routes using `CustomTransitionPage` and `SlideTransition` for a smooth, natural right-to-left push animation. On selecting a `ProductCard`, `context.go('/product/${product.id}')` navigates to `ProductDetailScreen`.
- **Component Modularity (`lib/widgets/product_card.dart` & `lib/screens/product_detail_screen.dart`):** Reusable `ProductCard` with placeholder icon container, and a clean `ProductDetailScreen` laying out the product header, price, description, quantity selector, and action buttons.

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
