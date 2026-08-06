# Flutter Activity 1 - Mobile UI Replica

## Activity Instructions

> Apply your knowledge of Container, Row, Column, Text, Icon, and other Basic widgets to recreate a static layout of a popular mobile application screen based on the number you were assigned. The image/s may not be the exact same, but the layout and palette should be.

---

## Overview

This project is a recreation of the **Spotify "Now Playing" Screen** based on the assigned mockup ([2.png](2.png)). The application replicates the precise layout, warm dark brown color palette, typography, control icons, edge alignments, and bottom lyrics sheet.

---

## Assigned Screen & Palette

- **Assigned Image**: `2.png` (Spotify Now Playing UI)
- **Album Artwork Asset**: `artwork-1.jpg`
- **Color Palette**:
  - Top Gradient: `#8F6335` (Warm amber brown)
  - Bottom Gradient: `#1E140C` (Dark brown/black)
  - Spotify Green Accent: `#1DB954`
  - Lyrics Card Background: `#C49A6C` (Warm tan)

---

## Widgets Used

- **`Container` & `BoxDecoration`**: Linear gradient background, shadows, circular button decorations, and rounded cards.
- **`Row` & `Column`**: Main layout alignment, track info header, control bar, and timestamp displays.
- **`Text` & `TextStyle`**: Typography for song title ("Akasaka Sad"), artist ("Rina Sawayama"), queue title ("SAWAYAMA"), device status ("Airpods Max"), and timestamps.
- **`Icon` & `IconButton`**: Action controls (Shuffle, Previous, Play/Pause, Next, Repeat, Heart, Add, Bluetooth, Queue, Sleep Timer, Share).
- **`ClipRRect`**: Rounded corner container for album artwork (`artwork-1.jpg`).
- **`Slider` & `SliderTheme`**: Interactive playback progress bar with custom `FullWidthTrackShape` for flush edge-to-edge alignment.
- **`AnimatedContainer`**: Expandable bottom Lyrics card.

---

## Features & Interactivity

1. **Strict Edge Alignment**:
   - Left and right margins (`24.0px`) align the Album Artwork, Track Title, Artist Name, Progress Slider, Control Icons, Device Status, and Lyrics Card along two unified vertical lines.
2. **Interactive Controls**:
   - **Play/Pause**: Toggles between play and pause states.
   - **Add (`+`) & Heart (`♡`)**: Toggles filled/outlined icon states and green highlights.
   - **Shuffle & Repeat**: Toggles active shuffle and repeat modes.
   - **Interactive Progress Bar**: Dragging the slider dynamically updates elapsed (`0:39`) and remaining (`-2:19`) timestamps in real-time.
3. **Lyrics Card**:
   - Overlaps flush to the bottom edge of the screen with rounded top corners (`20px`).
   - Tapping the expand icon expands/collapses the lyrics preview section.

---

## How to Run

1. Ensure Flutter SDK is installed.
2. Clone the repository:
   ```bash
   git clone https://github.com/yyaahhzxc/flutter-activity-1.git
   cd flutter-activity-1
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```
