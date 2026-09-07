# CSShop Project Study & Navigation Guide

This guide is your personal handbook for navigating, editing, and confidently presenting this Flutter project for your **Prelim Exam**. It is written in plain, beginner-friendly language so you can easily trace how each file works, where things are located, and how to answer common questions during your code defense.

---

## 1. Project Structure at a Glance

All your custom application code lives inside the **`lib/`** directory:

```text
lib/
├── main.dart                      # The starting point (Entry point, CartScope, Theme state)
├── data/
│   └── product_data.dart          # Catalog data (mock products, variants, images)
├── models/
│   ├── cart_item.dart             # Cart line item model (dynamic pricing & subtotals)
│   └── product.dart               # Data models for Product and ProductVariant
├── router/
│   └── app_router.dart            # Navigation 2.0 (GoRouter routes, slide transitions, guards)
├── screens/
│   ├── cart_screen.dart           # Shopping Cart: Stateful quantity controls & live running total
│   ├── checkout_confirmation_screen.dart # Confirmation: Final itemized receipt summary
│   ├── home_screen.dart           # Home page: App bar, filter chips, cart badge, responsive grid
│   └── product_detail_screen.dart # Details page: Responsive Shopee layout, gallery, Add to Cart
├── state/
│   └── cart_state.dart            # Native CartManager (ChangeNotifier) & CartScope (InheritedNotifier)
├── theme/
│   └── app_theme.dart             # Centralized Material 3 colors, light/dark themes
└── widgets/
    └── product_card.dart          # Reusable card widget for individual product items
```

Other important root files:
- **`pubspec.yaml`**: Package dependencies (`go_router`) and registered asset directories.
- **`test/widget_test.dart`**: Automated end-to-end smoke and user flow widget tests.
- **`README.md`**: Academic project summary for your GitHub repository.

---

## 2. The Big Picture: How the App Runs

When you run the project:

1. **`main.dart`** executes first. Its `main()` function calls `runApp(const CSShopApp())`.
2. **`CSShopApp`** is a `StatefulWidget` managing the current theme (`ThemeMode.light` or `ThemeMode.dark`) and instantiating the `CartManager`.
3. It wraps the entire application with **`CartScope`** (`InheritedNotifier<CartManager>`), allowing any screen or widget to listen to and update cart state reactively.
4. **`app_router.dart`** manages declarative routes via `GoRouter`:
   - Root `/`: **`home_screen.dart`** (product grid with category filters and cart icon badge).
   - Product Details `/product/:id`: **`product_detail_screen.dart`** (interactive variants, quantity counter, Add to Cart button).
   - Cart `/cart`: **`cart_screen.dart`** (itemized line items, stateful `+` / `-` quantity steppers, live running total).
   - Checkout Confirmation `/checkout`: **`checkout_confirmation_screen.dart`** (guarded route showing order receipt summary).

---

## 3. File-by-File Guide

---

### `lib/main.dart`
- **What it does:** The root of the entire Flutter application.
- **Why it is a `StatefulWidget`:** It holds the `_themeMode` state variable. When the user taps the theme toggle button in the AppBar, it calls `setState()`, switching between Light and Dark mode across the whole app.
- **Key Concepts:**
  - `CartScope`: Wraps `MaterialApp.router` so that cart updates automatically rebuild any listening UI components.
  - `MaterialApp.router`: Connects the app to `GoRouter` for Navigation 2.0.

---

### `lib/state/cart_state.dart`
- **What it does:** Centralized reactive state management for the shopping cart.
- **Why it matters for the exam:** It demonstrates how to achieve reactive state management using **pure, built-in Flutter SDK classes** (`ChangeNotifier` and `InheritedNotifier`) with zero external package dependencies.
- **Key Classes:**
  - **`CartManager`**: Extends `ChangeNotifier`. Manages `_items` and provides methods like `addItem()`, `incrementQuantity()`, `decrementQuantity()`, `removeItem()`, and `clearCart()`.
  - **`CartScope`**: An `InheritedNotifier<CartManager>` that makes `CartScope.of(context)` accessible anywhere in the widget tree.

---

### `lib/models/cart_item.dart`
- **What it does:** Encapsulates an item in the cart.
- **Properties:**
  - `id`: Composite identifier (`${product.id}_${variant.id}`).
  - `product`: Base product reference.
  - `variant`: Selected variant (if any).
  - `quantity`: Number of units.
  - `unitPrice`, `subtotal`, `displayName`, `imagePath`: Computed properties ensuring accurate pricing and display formatting.

---

### `lib/screens/cart_screen.dart`
- **What it does:** The shopping cart page.
- **Why it is a `StatefulWidget`:** It directly handles user interactions—incrementing/decrementing item quantities and removing items—triggering live rebuilds of running totals.
- **Key Features:**
  - **Live Running Total:** Displays subtotal per item and overall order total that immediately recalculates when `+` or `-` is tapped.
  - **Responsive Layout:** On mobile (`< 700px`), displays a scrollable item list with a sticky bottom checkout bar. On tablet/desktop (`>= 700px`), presents a side-by-side layout with a sticky order summary card.
  - **Empty State:** Shows a clean empty cart notice with a quick navigation button back to the catalog.

---

### `lib/screens/checkout_confirmation_screen.dart`
- **What it does:** The final confirmation screen after checkout.
- **Why it is protected:** A Navigation 2.0 redirect guard in `app_router.dart` ensures this screen is **reachable only when at least one item is in the cart**, satisfying the exam rubric.
- **Key Features:**
  - Captures a snapshot of the purchased items, per-item subtotals, and overall total.
  - Clears the active cart lifecycle safely.
  - Displays a clean, itemized receipt card (`StatelessWidget`) with Order ID, pickup location, and total paid.
  - Includes a "Continue Shopping" button returning to `/`.

---

### `lib/theme/app_theme.dart`
- **What it does:** Centralizes all colors, fonts, card styles, and button styles.
- **Why it matters for the exam:** The rubric requires: *"Define a single ThemeData applied at the MaterialApp level — no hardcoded colors scattered through individual widgets."*
- **Key Concepts:**
  - `primaryViolet`: The official CSSEC purple brand color (`0xFF6D28D9`).
  - `lightTheme` and `darkTheme`: Generated using `ColorScheme.fromSeed()` adhering to Material 3 design standards.

---

### `lib/router/app_router.dart`
- **What it does:** Configures **Navigation 2.0** using `GoRouter`.
- **Routes Defined:**
  - `'/'`: Home screen (Product Catalog).
  - `'/product/:id'`: Details screen with parameter extraction.
  - `'/cart'`: Shopping cart screen.
  - `'/checkout'`: Guarded checkout confirmation screen.
- **Transitions:**
  - Uses `CustomTransitionPage` and `SlideTransition` to give a natural, native horizontal push animation.

---

## 4. Exam Presentation / Defense Cheat Sheet

Direct, clear answers to common questions your instructor may ask based on the grading rubrics:

### Q1: "Why are some widgets StatefulWidget while others are StatelessWidget?"
> **Answer:**
> *"Anything that updates based on user interaction is a `StatefulWidget`. `CSShopApp` is stateful to toggle the app-wide theme. `HomeScreen` is stateful to manage category filter selection. `ProductDetailScreen` is stateful to manage variant switching, photo angle selection, and quantity counter. `CartScreen` is stateful to handle interactive quantity modification and item removal. In contrast, `ProductCard` and `_OrderReceiptCard` are `StatelessWidget`s because they only display immutable data passed down to them without internal state mutations."*

### Q2: "How did you manage the Shopping Cart state without third-party packages?"
> **Answer:**
> *"We implemented a `CartManager` class extending Flutter's native `ChangeNotifier`, providing atomic methods for adding, incrementing, decrementing, and clearing items. We then wrapped the root application in a custom `CartScope` extending `InheritedNotifier<CartManager>`. This allows any widget to access cart state via `CartScope.of(context)` and automatically re-render when the cart changes, adhering strictly to course package policies."*

### Q3: "How does the running total update live in the Cart?"
> **Answer:**
> *"Whenever the user taps the `+` or `-` buttons on a cart item, `CartManager.incrementQuantity()` or `decrementQuantity()` mutates the quantity and invokes `notifyListeners()`. Because `CartScreen` depends on `CartScope`, the widget rebuilds immediately, dynamically computing `totalAmount = sum(unitPrice * quantity)` in real time."*

### Q4: "How did you ensure the Checkout Confirmation screen is reachable only when the cart is not empty?"
> **Answer:**
> *"We enforced a route guard inside our declarative `GoRouter` configuration in `lib/router/app_router.dart`. The `/checkout` route definition specifies a `redirect` handler that checks `if (cartManager.isEmpty) return '/cart';`. If a user attempts to navigate directly to `/checkout` with zero items, GoRouter instantly redirects them back to the cart."*

### Q5: "How did you prevent card bottom overflow across different screen sizes?"
> **Answer:**
> *"Because card images have a 1:1 square aspect ratio that scales with column width, fixing a single childAspectRatio causes overflows on wider screens like the iPad Pro. We solved this by dynamically calculating `childAspectRatio = cardWidth / (cardWidth + 96)` inside `LayoutBuilder`, mathematically guaranteeing that the card height always provides enough room for the image plus details on any device."*

### Q6: "How does your app adapt between mobile and tablet screens?"
> **Answer:**
> *"On the home screen, `HomeScreen` uses `LayoutBuilder` to calculate column counts: 2 columns on phones (<600px), 3 columns on tablets (600px–900px), and 4 columns on desktops (>=900px). On the product details page, width >= 700px switches to a side-by-side 2-column layout (gallery on the left, product details on the right). On the shopping cart screen, width >= 700px displays items on the left and a sticky order summary on the right, while mobile uses a single-column list with a bottom checkout bar."*

---

## 5. Helpful Terminal Commands

- **Run the code analyzer (check for lint issues):**
  ```bash
  flutter analyze
  ```
- **Run the automated widget test suite:**
  ```bash
  flutter test
  ```
- **Launch application locally:**
  ```bash
  flutter run
  ```
