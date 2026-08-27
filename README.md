# Activity: Responsive & Adaptive Dashboard UI

## Activity Overview
This activity demonstrates building a single-screen wireframe dashboard in Flutter that seamlessly adapts its layout across mobile, tablet, and desktop viewports, while integrating platform detection to render native conventions for iOS, Android, Desktop, and Web.

## Instructions
- **Responsive Layout**:
  - Build a wireframe-like, single-screen dashboard that switches layout between mobile, tablet, and desktop devices seamlessly.
  - Mobile (< 600px): Render a 2x2 grid of metric boxes and vertical list tiles with a slide-out drawer.
  - Tablet (600px – 1100px): Render a 4-column single-row grid and vertical list tiles that expand to fill the available screen height.
  - Desktop (>= 1100px): Render a 3-column architecture featuring a persistent navigation sidebar, central grid and list tiles, and supplementary right panel cards.
- **Adaptive UI**:
  - Use platform detection to swap Material widgets for Cupertino widgets on iOS.
  - Optimize navigation components and pointer behavior across mobile, tablet, desktop, and web environments.

## Implementation & Solutions
- **Responsive System**:
  - `lib/constants/app_breakpoints.dart`: Declares screen width breakpoints (`mobileMaxWidth = 600.0`, `tabletMaxWidth = 1100.0`).
  - `lib/responsive/responsive_layout.dart`: Utilizes `LayoutBuilder` with `BoxConstraints.maxWidth` to dynamically mount `MobileBody`, `TabletBody`, or `DesktopBody`.
  - `lib/responsive/mobile_body.dart`: Custom scrollable view featuring a 2x2 `SliverGrid` and `SliverList` tiles.
  - `lib/responsive/tablet_body.dart`: 4-column single-row `GridView` paired with an `Expanded` `ListView` that fills the full vertical height on tablet displays.
  - `lib/responsive/desktop_body.dart`: Multi-column layout with a fixed `AdaptiveDrawer` sidebar, central content column (`flex: 5`), and proportional right-side wireframe panels (`flex: 2`).
- **Platform Adaptation**:
  - `lib/widgets/adaptive_app_bar.dart`: Conditionally renders `CupertinoNavigationBar` on iOS or a dark Material 3 `AppBar` on Android, Web, and Desktop.
  - `lib/widgets/adaptive_drawer.dart`: Renders native iconography (`CupertinoIcons` on iOS/macOS, `MaterialIcons` on Android/Windows/Linux/Web) with straight edges (zero corner radius) for both drawer and persistent sidebar modes.
  - `lib/widgets/wireframe_box.dart` & `lib/widgets/wireframe_tile.dart`: Modular visual placeholders adhering to the activity wireframe aesthetic.

## Setup & Execution
### Prerequisites
- Flutter SDK: `^3.10.1` or higher
- Dart SDK: `^3.10.1` or higher

### Dependencies
The activity uses standard Flutter framework capabilities with zero unnecessary third-party dependencies:
- `flutter`: Flutter SDK framework
- `cupertino_icons: ^1.0.8`: Native iOS icons
- `flutter_lints: ^6.0.0` (dev dependency): Lint rules

### Running the Activity
1. Navigate to the activity directory:
   ```bash
   cd "Flutter Activity 3"
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Run on your desired target:
   - Chrome:
     ```bash
     flutter run -d chrome
     ```
   - Windows Desktop:
     ```bash
     flutter run -d windows
     ```
4. Run automated tests:
   ```bash
   flutter test
   ```
