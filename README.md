# Flutter Activity 3 - Nested Routing

## Instructions

- Demonstrate a nested route scenario using `go_router`.
- First page should be a list of fruits, at url `'/'`.
- And when one redirects to another page, the url should now be `'/fruit/:name'` showing an illustration of the corresponding fruit.

---

## Overview

This Flutter project demonstrates nested routing with `go_router`:

1. **Home Screen (`/`)**: Displays a list of fruits (Apple, Banana, Strawberry, Orange, Mango, Watermelon).
2. **Fruit Detail Screen (`/fruit/:name`)**: Clicking any fruit redirects to its nested route URL (`/fruit/:name`), showing:
   - An illustration of the fruit
   - Fruit name and category
   - A simple description
   - A back button to return to the fruit list

---

## Routes

- `/` &rarr; `FruitListScreen`
- `/fruit/:name` &rarr; `FruitDetailScreen` (e.g. `/fruit/apple`, `/fruit/banana`)

---

## How to Run

1. Get dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

3. Run automated tests:
   ```bash
   flutter test
   ```
