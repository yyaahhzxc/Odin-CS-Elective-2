# CSShop Project Study & Navigation Guide

This guide is your personal handbook for navigating, editing, and confidently presenting this Flutter project for your **Prelim Exam**. It is written in plain, beginner-friendly language so you can easily trace how each file works, where things are located, and how to answer common questions during your code defense.

---

## 1. Project Structure at a Glance

All your custom application code lives inside the **`lib/`** directory. Here is how it is structured:

```text
lib/
├── main.dart                      # The starting point (Entry point & Theme state)
├── data/
│   └── product_data.dart          # The list of products (names, prices, descriptions)
├── models/
│   └── product.dart               # The blueprint/class defining what a "Product" is
├── router/
│   └── app_router.dart            # Navigation 2.0 (GoRouter setup and screen transitions)
├── screens/
│   ├── home_screen.dart           # Home page: App bar, title, category filters, and grid
│   └── product_detail_screen.dart # Details page: View selected item info, quantity, etc.
├── theme/
│   └── app_theme.dart             # Colors, dark/light theme definitions, typography
└── widgets/
    └── product_card.dart          # Reusable card widget for an individual product item
```

Other important root files:
- **`pubspec.yaml`**: The configuration file where packages (`go_router`) and assets are declared.
- **`test/widget_test.dart`**: Automated test checking if the app loads properly.
- **`README.md`**: The formal project summary for your GitHub repository.

---

## 2. The Big Picture: How the App Runs

When you type `flutter run` in your terminal, here is the chain reaction:

1. **`main.dart`** executes first. Its `main()` function calls `runApp(const CSShopApp())`.
2. **`CSShopApp`** is a `StatefulWidget` that holds the current theme (`ThemeMode.light` or `ThemeMode.dark`).
3. It passes this theme into **`MaterialApp.router`**, using the designs we defined in **`app_theme.dart`**.
4. **`app_router.dart`** determines which screen to open first. By default, `/` points to **`home_screen.dart`**.
5. When a user clicks any product card in the grid, `context.go('/product/:id')` tells `GoRouter` to slide into **`product_detail_screen.dart`**.

---

## 3. File-by-File Guide

---

### `lib/main.dart`
- **What it does:** The root of the entire Flutter application.
- **Why it is a `StatefulWidget`:** It holds the `_themeMode` variable. When you click the Sun/Moon icon in the AppBar, it calls `setState()`, which rebuilds the app with the new theme (Light $\leftrightarrow$ Dark).
- **Key Widget to Know:**
  - `MaterialApp.router`: Tells Flutter to use `GoRouter` (Navigation 2.0) instead of the old `Navigator.push`.
- **Where to edit:**
  - Change the browser tab title: edit `title: 'CSShop - CSSEC Merch'`.

---

### `lib/theme/app_theme.dart`
- **What it does:** Centralizes all colors, fonts, card styles, and button styles.
- **Why it matters for the exam:** The exam rubric strictly requires: *"Define a single ThemeData applied at the MaterialApp level — no hardcoded colors scattered through individual widgets."* This file fulfills that 100%.
- **Key Concepts:**
  - `primaryViolet`: The main CSSEC purple brand color (`0xFF6D28D9`).
  - `lightTheme`: Colors used when in light mode.
  - `darkTheme`: Colors used when in dark mode.
- **How to edit colors:**
  - If you want a different purple or accent color, simply change the hex code in `primaryViolet` or `secondaryViolet` at the top of this file. Everything in the app updates automatically!

---

### `lib/models/product.dart`
- **What it does:** Defines the "Blueprint" for merchandise items and variants.
- **Classes:**
  - **`Product`**: Base product with `id`, `name`, `price`, `imagePath`, `category`, `description`, `soldCount`, `stock`, and a `variants` list.
  - **`ProductVariant`**: Sub-blueprint for each variant:
    - `id`: Unique sub-identifier for cart & checkout (e.g. `'prod-001-v1'`).
    - `name`: Variant display name (e.g. `'Violet'`, `'Black'`).
    - `price`: Optional custom price for this specific variant.
    - `imagePath`: Path to the variant's image asset.
    - `description`: Custom description for this variant.
    - `stock`: Stock level for this specific variant.

---

### `lib/data/product_data.dart`
- **What it does:** The mock database containing your actual products and their variants.
- **How to edit or add variants:**
  - Inside any `Product`, find the `variants: [...]` list.
  - Each variant is a `ProductVariant(id: ..., name: ..., price: ..., imagePath: ..., description: ..., stock: ...)`.
  - You can change each variant's individual sub-id, price, description, and image path directly!

---

### `lib/router/app_router.dart`
- **What it does:** Configures **Navigation 2.0** using the `go_router` package.
- **Routes Defined:**
  - `'/'`: Points to `HomeScreen`.
  - `'/product/:id'`: Points to `ProductDetailScreen`. It grabs the `:id` from the URL, looks up the product in `mockProducts`, and passes it to the screen.
- **Transitions:**
  - Uses `CustomTransitionPage` and `SlideTransition` to give a smooth right-to-left mobile slide when opening the details page.

---

### `lib/screens/home_screen.dart`
- **What it does:** The main page showing the store title, category filter buttons, and the responsive product grid.
- **Why it is a `StatefulWidget`:** Because the user can click on the category chips (*All*, *Apparel*, *Accessories*). The variable `_selectedCategory` remembers which one is currently selected and calls `setState()` to filter the list.
- **Important Widgets in this Screen:**
  - `AppBar`: Contains the title and the theme toggle `IconButton`.
  - `FilterChip`: The interactive category pills.
  - `LayoutBuilder`: **Crucial for responsive grading!** It checks the screen width (`constraints.maxWidth`).
    - If width $< 600\text{px}$ (Phones) $\rightarrow$ **2 columns**.
    - If width between $600\text{px}$ and $900\text{px}$ (Tablets) $\rightarrow$ **3 columns**.
    - If width $\ge 900\text{px}$ (Desktops) $\rightarrow$ **4 columns**.
  - `GridView.builder`: Efficiently builds the product cards using the columns calculated by `LayoutBuilder`.

---

### `lib/widgets/product_card.dart`
- **What it does:** A reusable widget representing a single product card inside the grid.
- **Why it is a `StatelessWidget`:** A single product card never changes its own state once built; it just displays the data passed to it (`product.name`, `product.price`, etc.).
- **Key Widgets:**
  - `Card`: Provides rounded corners and subtle border styling from `app_theme.dart`.
  - `InkWell`: Detects when you tap the card and calls `context.go('/product/${product.id}')`.

---

### `lib/screens/product_detail_screen.dart`
- **What it does:** The destination page when you click any product.
- **Why it is a `StatefulWidget`:** Because it handles user interaction: selecting different product variants (`_selectedVariantIndex`) and changing the quantity (`_quantity`).
- **Key Features & Sections:**
  - `AppBar`: Has a back arrow (`context.pop()`) and the product name.
  - **Square Image Area:** Uses `AspectRatio(aspectRatio: 1.0)` inside a `ConstrainedBox(maxWidth: 420)` so that whether on phone, tablet, or web, the main image preview is ALWAYS a perfect square (never stretched or distorted).
  - **Thumbnail Pics Row:** A horizontal strip of thumbnail cards directly below the main image. Tapping any thumbnail switches the selected variant and highlights its border!
  - **Variation Buttons:** A row of buttons under the details section (e.g. `[Violet]`, `[Black]`, `[White]`). Tapping either a button or a thumbnail updates both and changes the variant shown in the big square image!
  - **Quantity Stepper:** `[-]` and `[+]` buttons that update the count live.
  - **Add to Cart:** Shows a SnackBar confirming the selected variant and quantity.

---

## 4. Exam Presentation / Defense Cheat Sheet

Here are direct, simple answers to questions your instructor is likely to ask based on the grading rubrics:

### Q1: "Why are some widgets StatefulWidget while others are StatelessWidget?"
> **Answer:**
> *"Anything that changes based on user interaction needs to be a `StatefulWidget`. `HomeScreen` is stateful because it tracks which category chip the user selected ('All', 'Apparel', 'Accessories'). `ProductDetailScreen` is stateful because it manages the active product variant selection and the quantity counter. In contrast, `ProductCard` is a `StatelessWidget` because it only receives static product data and displays it without needing internal state changes."*

### Q2: "How did you implement the Light and Dark mode toggle?"
> **Answer:**
> *"In `lib/main.dart`, the root widget `CSShopApp` holds a `ThemeMode` state variable. We passed a toggle callback down to the AppBar in `HomeScreen`. When the user taps the icon button, `_toggleThemeMode()` calls `setState()`, switching between `ThemeMode.light` and `ThemeMode.dark`. This immediately updates the entire app because `MaterialApp.router` uses our centralized `AppTheme.lightTheme` and `AppTheme.darkTheme`."*

### Q3: "Did you hardcode any colors in your widgets?"
> **Answer:**
> *"No, all colors are centralized in `lib/theme/app_theme.dart` using Material 3 `ColorScheme.fromSeed` with our CSSEC violet seed color. Throughout all widgets, we strictly access colors using `Theme.of(context).colorScheme`."*

### Q4: "How does your app adapt between mobile and tablet screens?"
> **Answer:**
> *"In `lib/screens/home_screen.dart`, we wrapped our `GridView.builder` in a `LayoutBuilder`. It reads `constraints.maxWidth`: if the width is under 600 pixels (like on a phone), it renders 2 columns; if it's 600 pixels or wider (like on a tablet or desktop), it dynamically increases to 3 or 4 columns."*

### Q5: "How does Navigation 2.0 work in this project?"
> **Answer:**
> *"We use the `go_router` package declared in `lib/router/app_router.dart`. We configured declarative routes for `/` (Home) and `/product/:id` (Details). Tapping a card uses `context.go('/product/${product.id}')` to push the new route with a clean `SlideTransition`."*

---

## 5. Quick "How-To" Cheatsheet for Editing

| What do you want to change? | Where to go | What line to look for |
| :--- | :--- | :--- |
| **Change product names, prices, or descriptions** | `lib/data/product_data.dart` | Inside `mockProducts` list |
| **Change the purple color theme** | `lib/theme/app_theme.dart` | `static const Color primaryViolet = ...` |
| **Change the store title on the home page** | `lib/screens/home_screen.dart` | `Text('CSSEC Merch Store')` |
| **Change the subtitle description** | `lib/screens/home_screen.dart` | `Text('Official merchandise store...')` |
| **Change category names** | `lib/screens/home_screen.dart` | `final List<String> _categories = ...` |
| **Change grid columns** | `lib/screens/home_screen.dart` | Inside `LayoutBuilder` (`if (constraints.maxWidth < 600)`) |
| **Change the Add to Cart snackbar text** | `lib/screens/product_detail_screen.dart` | Inside `ElevatedButton`'s `onPressed` |

---

## 6. Helpful Terminal Commands

- **Hot Reload (while app is running):** Press `r` in the terminal running Flutter.
- **Hot Restart:** Press `R` in the terminal.
- **Run the code analyzer (check for errors):**
  ```bash
  flutter analyze
  ```
- **Run the test:**
  ```bash
  flutter test
  ```
