import 'package:flutter/material.dart';

/// Centralized design system and theme configuration for PokéMart.
///
/// Faithfully modeled after the Pokémon GO (PoGO / Niantic) Design System:
/// - Reverse-engineered from official PoGO UI Kit Sketch assets
/// - Signature two-stop Mint Gradient (#A8DD9C -> #23CCA9)
/// - Deep Sea Teal (#1C8696) borders and dark glyph accents
/// - Concentric circular action buttons and stadium pill cards
/// - Ultra-light frosted mint canvas (#F0FFF1) with pure white card pedestals
class AppTheme {
  // Private constructor to prevent direct instantiation.
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Core Pokémon GO Brand Color Tokens (from UI Kit Sketch Master Symbols)
  // ---------------------------------------------------------------------------
  static const Color pogoTealPrimary = Color(0xFF1C8696); // Deep Sea Teal / Niantic Teal (67 refs)
  static const Color pogoMintStart = Color(0xFFA8DD9C); // Spring Lime / Mint Gradient Start
  static const Color pogoMintEnd = Color(0xFF23CCA9); // Vibrant Emerald Mint / Gradient End
  static const Color pogoLimeStart = Color(0xFFAEFBA8); // Electric Lime (Back/Cancel Button)
  static const Color pogoCyanEnd = Color(0xFF5FEED1); // Radiant Cyan Mint (Back/Cancel Button)

  // Canvas & Surface Tints
  static const Color pogoScaffoldBg = Color(0xFFF0FFF1); // Frosted Ultra-light Mint Scaffold
  static const Color pogoCardBg = Color(0xFFFFFFFF); // Pure White Card Surface
  static const Color pogoCardMintPad = Color(0xFFE8F8EE); // Circular Asset Pedestal Pad
  static const Color pogoBorder = Color(0xFFE0EAE5); // Subtle Card Outline
  static const Color pogoBorderDarker = Color(0xFFD7D7D7); // Divider / Inactive Border

  // Text & Neutrals
  static const Color pogoTextPrimary = Color(0xFF1E2833); // High-contrast Deep Charcoal
  static const Color pogoTextSecondary = Color(0xFF7E8C88); // Muted Slate Gray
  static const Color pogoTextSubtle = Color(0xFF969696); // Helper Caption Gray

  // Accents & Semantics
  static const Color pogoValorRed = Color(0xFFFF3844); // Poké Ball top / Alert / Danger
  static const Color pogoCoinGold = Color(0xFFF5A623); // PokéCoin / Funds / Rating Star
  static const Color pogoPokeStopBlue = Color(0xFF28AEFF); // PokéStop / Tech Blue Accent
  static const Color pogoStardustPurple = Color(0xFF8A4FFF); // Stardust / Special Item Accent

  // Stadium Night Mode Palette
  static const Color darkScaffoldBg = Color(0xFF0D1E24); // Night Deep Blue-Teal
  static const Color darkCardBg = Color(0xFF152A32); // Dark Slate Card
  static const Color darkBorder = Color(0xFF1F3E4A); // Subtle Night Border
  static const Color darkTextPrimary = Color(0xFFF0FFF1); // Mint White Text
  static const Color darkTextSecondary = Color(0xFF8BA5AE); // Muted Slate Blue

  // Backward-compatibility aliases for existing references and test suites
  static const Color swordCerulean = pogoTealPrimary;
  static const Color swordPrimary = pogoTealPrimary;
  static const Color shieldCrimson = pogoValorRed;
  static const Color shieldAccent = pogoValorRed;
  static const Color bagGold = pogoCoinGold;
  static const Color bagGoldLight = Color(0xFFFDE8C5);
  static const Color rotomOrange = pogoCoinGold;
  static const Color healthGreen = pogoMintEnd;
  static const Color inStockColor = pogoMintEnd;
  static const Color ratingStar = pogoCoinGold;
  static const Color ratingStarColor = pogoCoinGold;

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------
  /// Official PoGO action capsule gradient (Button Evolve / Power Up / Checkout).
  static const LinearGradient mintActionGradient = LinearGradient(
    colors: [pogoMintStart, pogoMintEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Official PoGO floating action gradient (Back Button / Cancel Button / Floating Badge).
  static const LinearGradient floatingButtonGradient = LinearGradient(
    colors: [pogoLimeStart, pogoCyanEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Top Hero horizon banner gradient.
  static const LinearGradient horizonHeroGradient = LinearGradient(
    colors: [Color(0xFF1C8696), Color(0xFF23CCA9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Formats a number with comma as thousands separator (e.g., 325976 -> "325,976").
  static String formatPrice(num price) {
    final str = price.toStringAsFixed(0);
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Light Theme definition applied at the MaterialApp level.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: pogoTealPrimary,
      brightness: Brightness.light,
      primary: pogoTealPrimary,
      secondary: pogoMintEnd,
      tertiary: pogoCoinGold,
      surface: pogoCardBg,
      surfaceContainerLowest: pogoScaffoldBg,
      surfaceContainerHighest: pogoCardMintPad,
      outline: pogoBorder,
      onPrimary: Colors.white,
      onSecondary: pogoTextPrimary,
      onSurface: pogoTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: pogoScaffoldBg,

      // AppBar styling - Clean PoGO white header
      appBarTheme: const AppBarTheme(
        backgroundColor: pogoCardBg,
        foregroundColor: pogoTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Color(0x1A1C8696),
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: pogoTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),

      // Card styling - 22px rounded PoGO card surface with clean mint shadow
      cardTheme: CardThemeData(
        color: pogoCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: pogoBorder, width: 1.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Button styling - PoGO Stadium Capsule CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pogoTealPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pogoTealPrimary,
          side: const BorderSide(color: pogoTealPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text styling
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: pogoTextPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: pogoTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF4A5568),
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: pogoTextSecondary,
        ),
      ),
    );
  }

  /// Dark Theme definition applied at the MaterialApp level.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: pogoTealPrimary,
      brightness: Brightness.dark,
      primary: pogoMintEnd,
      secondary: pogoCyanEnd,
      tertiary: pogoCoinGold,
      surface: darkCardBg,
      surfaceContainerLowest: darkScaffoldBg,
      surfaceContainerHighest: Color(0xFF1D3742),
      outline: darkBorder,
      onPrimary: pogoTextPrimary,
      onSecondary: pogoTextPrimary,
      onSurface: darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkScaffoldBg,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Color(0x33000000),
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder, width: 1.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pogoMintEnd,
          foregroundColor: pogoTextPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pogoMintEnd,
          side: const BorderSide(color: pogoMintEnd, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFA0B5BD),
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: darkTextSecondary,
        ),
      ),
    );
  }
}
