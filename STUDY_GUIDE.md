# CSShop Project Study & Navigation Guide

This guide is your personal handbook for navigating, editing, and confidently presenting this Flutter project for your **Prelim Exam**. It is written in plain, beginner-friendly language so you can easily trace how each file works, where things are located, and how to answer common questions during your code defense.

---

## 1. Project Structure at a Glance

All your custom application code lives inside the **`lib/`** directory:

```text
lib/
├── main.dart                      # The starting point (Entry point & Theme state)
├── data/
│   └── product_data.dart          # Catalog data (mock products, variants, images)
├── models/
│   └── product.dart               # Data models for Product and ProductVariant
├── router/
│   └── app_router.dart            # Navigation 2.0 (GoRouter routes & slide transitions)
├── screens/
│   ├── home_screen.dart           # Home page: App bar, filter chips, and responsive grid
│   └── product_detail_screen.dart # Details page: Responsive Shopee layout, gallery, variants
├── theme/
│   └── app_theme.dart             # Centralized Material 3 colors, light/dark themes
└── widgets/
    └── product_card.dart          # Reusable card widget for individual product items
```

Other important root files:
- **`pubspec.yaml`**: Package dependencies (`go_router`) and registered asset directories (`assets/images/`, `assets/images/003-jersey/`).
- **`test/widget_test.dart`**: Automated widget smoke tests verifying clean app rendering.
- **`README.md`**: Academic project summary for your GitHub repository.

---

## 2. The Big Picture: How the App Runs

When you run the project:

1. **`main.dart`** executes first. Its `main()` function calls `runApp(const CSShopApp())`.
2. **`CSShopApp`** is a `StatefulWidget` managing the current theme (`ThemeMode.light` or `ThemeMode.dark`).
3. It passes this theme into **`MaterialApp.router`**, using the designs we defined in **`app_theme.dart`**.
4. **`app_router.dart`** determines which screen to open first. The root route `/` displays **`home_screen.dart`**.
5. When a user taps any product card, `context.go('/product/:id')` tells `GoRouter` to transition to **`product_detail_screen.dart`**.

---

## 3. File-by-File Guide

---

### `lib/main.dart`
- **What it does:** The root of the entire Flutter application.
- **Why it is a `StatefulWidget`:** It holds the `_themeMode` state variable. When the user taps the theme toggle button in the AppBar, it calls `setState()`, switching between Light and Dark mode across the whole app.
- **Key Widget to Know:**
  - `MaterialApp.router`: Connects the app to `GoRouter` for Navigation 2.0.

---

### `lib/theme/app_theme.dart`
- **What it does:** Centralizes all colors, fonts, card styles, and button styles.
- **Why it matters for the exam:** The rubric requires: *"Define a single ThemeData applied at the MaterialApp level — no hardcoded colors scattered through individual widgets."* This file satisfies that requirement completely.
- **Key Concepts:**
  - `primaryViolet`: The main CSSEC purple brand color (`0xFF6D28D9`).
  - `lightTheme` and `darkTheme`: Generated using `ColorScheme.fromSeed()` with Material 3 design standards.

---

### `lib/models/product.dart`
- **What it does:** Defines the blueprints for merchandise items and variants.
- **Classes:**
  - **`Product`**: Base product with `id`, `name`, `price`, `imagePath`, `category`, `description`, `soldCount`, `stock`, and `variants`.
  - **`ProductVariant`**: Sub-blueprint for specific variations (e.g. Sleeved Purple vs. Sleeved White):
    - `id`: Unique sub-identifier ready for cart and checkout in part 2 (e.g. `'prod-003-v1'`).
    - `name`: Display title of the variant.
    - `price`: Optional custom price (automatically inherits base product price if omitted).
    - `images`: List of image paths (e.g., front and back photos).
    - `description` & `stock`: Optional variant-specific overrides.

---

### `lib/data/product_data.dart`
- **What it does:** The catalog database containing your items.
- **How it works:**
  - If a product does not have real images yet, its image fields are left empty, and the app cleanly renders the placeholder icon with zero 404 network warnings.
  - For products with multiple photos (like the Palarong Atenista CS Jersey), each variant lists its front and back images under `images: [...]`.

---

### `lib/router/app_router.dart`
- **What it does:** Configures **Navigation 2.0** using `GoRouter`.
- **Routes Defined:**
  - `'/'`: Home screen.
  - `'/product/:id'`: Details screen for the clicked product.
- **Transitions:**
  - Uses `CustomTransitionPage` and `SlideTransition` to give a natural, native horizontal push animation.

---

### `lib/screens/home_screen.dart`
- **What it does:** The main browsing page with category filters and the responsive product grid.
- **Why it is a `StatefulWidget`:** It tracks which category chip the user selected (`_selectedCategory`) and calls `setState()` to filter the catalog.
- **Responsive Grid Logic:**
  - Uses `LayoutBuilder` to inspect `constraints.maxWidth`:
    - Phone (`< 600px`) $\rightarrow$ **2 columns**.
    - Tablet (`600px - 900px`) $\rightarrow$ **3 columns**.
    - Desktop (`>= 900px`) $\rightarrow$ **4 columns**.
  - **Dynamic Aspect Ratio:** Computes `childAspectRatio = cardWidth / (cardWidth + 96)` dynamically, ensuring the 1:1 square image and product details never overflow on any mobile or tablet screen (such as iPad Pro or iPhone XR).

---

### `lib/widgets/product_card.dart`
- **What it does:** Reusable card widget for a single product item.
- **Why it is a `StatelessWidget`:** The card only displays the data passed into it and does not need internal state changes.
- **Square Image Guarantee:** Wraps the image area in `AspectRatio(aspectRatio: 1.0)`. If a real image asset is present, it displays it; otherwise, it renders a clean shopping bag icon without throwing network errors.

---

### `lib/screens/product_detail_screen.dart`
- **What it does:** The product details page.
- **Why it is a `StatefulWidget`:** Manages user interaction: switching variants (`_selectedVariantIndex`), switching photo angles (`_selectedImageIndex`), and adjusting quantity (`_quantity`).
- **Responsive Layout (`LayoutBuilder`):**
  - **Tablet / Desktop ($\ge 700\text{px}$):** Implements a **Shopee-style two-column layout** where the square highlight image and thumbnail gallery are on the left, and product title, rating, price, variations, and Add to Cart button are on the right.
  - **Mobile ($< 700\text{px}$):** Renders a clean, single-column vertical layout.
- **Multi-Angle Gallery:** Under the main square image, a thumbnail strip lets users tap between `[Front]` and `[Back]` views.

---

## 4. Exam Presentation / Defense Cheat Sheet

Direct, clear answers to common questions your instructor may ask based on the grading rubrics:

### Q1: "Why are some widgets StatefulWidget while others are StatelessWidget?"
> **Answer:**
> *"Anything that updates based on user interaction is a `StatefulWidget`. `CSShopApp` is stateful to toggle the app-wide theme. `HomeScreen` is stateful to manage category filter selection. `ProductDetailScreen` is stateful to manage variant switching, image angle selection, and quantity counts. In contrast, `ProductCard` is a `StatelessWidget` because it only receives static product data and displays it without needing internal state."*

### Q2: "How did you implement the Light and Dark mode toggle?"
> **Answer:**
> *"In `lib/main.dart`, the root widget `CSShopApp` holds a `ThemeMode` state variable. We pass a callback to the AppBar in `HomeScreen`. Tapping the theme icon calls `setState()`, switching between `ThemeMode.light` and `ThemeMode.dark`, which immediately updates the `MaterialApp.router` using our centralized `AppTheme` definitions."*

### Q3: "Did you hardcode any colors in your widgets?"
> **Answer:**
> *"No. All colors are centralized in `lib/theme/app_theme.dart` using Material 3 `ColorScheme.fromSeed` with our CSSEC violet brand seed color. Across all widgets, we strictly reference colors using `Theme.of(context).colorScheme`."*

### Q4: "How does your app adapt between mobile and tablet screens?"
> **Answer:**
> *"On the home screen, `HomeScreen` uses a `LayoutBuilder` to calculate column counts: 2 columns on phones (<600px), 3 columns on tablets (600px–900px), and 4 columns on desktops (>=900px). On the product details page, `ProductDetailScreen` detects screen width >= 700px to switch to a side-by-side 2-column layout (gallery on the left, product details on the right), and collapses to a single vertical column on mobile."*

### Q5: "How did you prevent card bottom overflow across different screen sizes?"
> **Answer:**
> *"Because card images have a 1:1 square aspect ratio that scales with column width, fixing a single childAspectRatio causes overflows on wider screens like the iPad Pro. We solved this by dynamically calculating `childAspectRatio = cardWidth / (cardWidth + 96)` inside `LayoutBuilder`, mathematically guaranteeing that the card height always provides enough room for the image plus details on any device."*

### Q6: "How does Navigation 2.0 work in this project?"
> **Answer:**
> *"We use the `go_router` package declared in `lib/router/app_router.dart`. We configured declarative routes for `/` (Home) and `/product/:id` (Details). Tapping a product card calls `context.go('/product/${product.id}')` which pushes the route with a custom `SlideTransition`."*

---

## 5. Quick "How-To" Cheatsheet for Editing

| What do you want to change? | Where to go | What to look for |
| :--- | :--- | :--- |
| **Change product names, prices, or descriptions** | `lib/data/product_data.dart` | Inside `mockProducts` list |
| **Add a new product image** | `assets/images/` and `product_data.dart` | Add image path to `imagePath` or `images` |
| **Change the purple color theme** | `lib/theme/app_theme.dart` | `static const Color primaryViolet = ...` |
| **Change store title** | `lib/screens/home_screen.dart` | `Text('CSShop - The CSSEC Merch Store')` |
| **Change category names** | `lib/screens/home_screen.dart` | `final List<String> _categories = ...` |
| **Adjust tablet layout breakpoint** | `lib/screens/product_detail_screen.dart` | `constraints.maxWidth >= 700` |
| **Change the Add to Cart snackbar text** | `lib/screens/product_detail_screen.dart` | Inside `ElevatedButton`'s `onPressed` |

---

## 6. Helpful Terminal Commands

- **Hot Reload (while app is running):** Press `r` in the terminal.
- **Hot Restart:** Press `R` in the terminal.
- **Quit Running Session:** Press `q` in the terminal.
- **Run the code analyzer (check for errors):**
  ```bash
  flutter analyze
  ```
- **Run the automated widget test:**
  ```bash
  flutter test
  ```
