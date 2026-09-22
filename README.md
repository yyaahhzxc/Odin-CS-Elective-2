# Async Profile Screen

## Project Overview
The Async Profile Screen application demonstrates core asynchronous programming paradigms in Dart and Flutter, integrating single-completion `Future` operations, multi-event continuous `Stream` data feeds, and defensive state hardening within a clean, reactive user interface.

## Tasked Instructions / Requirements
- **Fetch**: Implement an asynchronous `fetchProfile()` function returning `Future<Profile>` with a simulated 2-second delay.
- **Display**: Wire the asynchronous operation into a `FutureBuilder` handling three core states: a progress spinner during resolution, an error message upon failure, and the profile card upon successful completion.
- **Stream in**: Implement a `StreamBuilder` that displays a live 'last seen X seconds ago' counter utilizing `Stream.periodic()`.
- **Harden**: Implement structured `try/catch` error handling, prevent invalid state updates using `mounted` checks, and properly close and dispose of any created `StreamController` instances to prevent memory leaks.

## Implementation & Solutions
- **Domain & Service Layer**:
  - `Profile` model (`lib/models/profile.dart`): Immutable representation of user information, encapsulating name, role, email, location, and bio fields.
  - `ProfileService` (`lib/services/profile_service.dart`): Simulates remote network latency using `Future.delayed` and provides structured error generation for verifying UI failure states.
- **Presentation & Concurrency**:
  - `ProfileScreen` (`lib/screens/profile_screen.dart`): Stateful widget managing the lifecycle of both `Future` and `Stream` sources.
  - Rebuild Prevention: The `_profileFuture` is instantiated within `initState()` and retained in state rather than constructed inline inside `build()`, preventing unwanted duplicate network requests during widget rebuilds.
  - Stream Management: A `StreamController<int>` acts as an event pipeline receiving periodic ticks from `Stream.periodic()`. The controller is explicitly closed in `dispose()`, and any ongoing stream subscription is cancelled.
  - Defensive State Checks: All asynchronous callbacks that invoke `setState()` are guarded by `if (!mounted) return;` checks to prevent memory leaks or crashes from disposed state objects.
  - `FutureBuilder` & `StreamBuilder`: The `FutureBuilder` cleanly branches into waiting, error, and completed states. The `StreamBuilder` consumes the live tick feed to display an active status badge showing the elapsed time.
  - `ProfileCard` (`lib/widgets/profile_card.dart`): Modular, const-optimized widget styled with a minimalist neutral slate palette.

## Setup & Dependencies
### Prerequisites
- Flutter SDK: `^3.12.2` or later
- Dart SDK: `^3.12.2` or later

### Required Packages
The application relies solely on built-in Flutter and Dart SDK packages:
- `flutter` (SDK)
- `dart:async` (Dart core)
- `cupertino_icons: ^1.0.8`

### Running the Application
1. Ensure dependencies are resolved:
   ```bash
   flutter pub get
   ```
2. Run the test suite:
   ```bash
   flutter test
   ```
3. Execute static analysis:
   ```bash
   flutter analyze
   ```
4. Launch the application on a connected device or emulator:
   ```bash
   flutter run
   ```
