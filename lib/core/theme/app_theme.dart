import 'package:flutter/material.dart';

/// Production UI System — "사주인연"
///
/// Senior Product Designer perspective (Tinder × Toss).
/// - Font: Pretendard (Korean-optimized, SF-like neutrality)
/// - Palette: 한지(韓紙) — muted, warm, never vivid
/// - Dual mood: Light(casual) ↔ Dark(mystic)
/// - Elevation: Surface layering + subtle border (no Material shadow stacking)
abstract final class AppTheme {
  // ===========================================================================
  // Font Family
  // ===========================================================================

  static const fontFamily = 'Pretendard';

  // ===========================================================================
  // Color Tokens — Fixed (same in both modes)
  // ===========================================================================

  // Brand seeds
  static const _primarySeed = Color(0xFFA8C8E8); // 한지 하늘색
  static const _secondarySeed = Color(0xFFF2D0D5); // 한지 연분홍
  static const _tertiarySeed = Color(0xFF4A4F54); // 먹회색

  // Five elements (오행) — never vivid
  static const woodColor = Color(0xFF8FB89A); // 목(木) 수묵 초록
  static const fireColor = Color(0xFFD4918E); // 화(火) 연지 핑크
  static const earthColor = Color(0xFFC8B68E); // 토(土) 황토 한지
  static const metalColor = Color(0xFFB8BCC0); // 금(金) 먹탄 은회
  static const waterColor = Color(0xFF89B0CB); // 수(水) 쪽빛 하늘

  // Five elements — pastel variants
  static const woodPastel = Color(0xFFD4E4D7);
  static const firePastel = Color(0xFFF0D4D2);
  static const earthPastel = Color(0xFFE8DFC8);
  static const metalPastel = Color(0xFFE0E2E4);
  static const waterPastel = Color(0xFFC8DBEA);

  // Compatibility score colors
  static const compatibilityExcellent = Color(0xFFC27A88); // 90-100
  static const compatibilityGood = Color(0xFFC49A7C); // 70-89
  static const compatibilityNormal = Color(0xFFA8B0A0); // 50-69
  static const compatibilityLow = Color(0xFF959EA2); // 0-49

  // Mystic mode accents (dark-only glow)
  static const mysticGlow = Color(0xFFC8B68E); // 은은한 골드
  static const mysticAccent = Color(0xFFD4C9A8); // 밝은 황토

  // Status
  static const statusSuccess = Color(0xFF8FB89A);
  static const statusError = Color(0xFFD4918E);
  static const statusWarning = Color(0xFFC8B68E);

  // ===========================================================================
  // Color Tokens — Semantic (theme-aware)
  // ===========================================================================

  // Light backgrounds
  static const hanjiBg = Color(0xFFF7F3EE); // bg.primary
  static const hanjiSurface = Color(0xFFFEFCF9); // bg.elevated
  static const hanjiElevated = Color(0xFFF0EDE8); // bg.secondary

  // Dark backgrounds
  static const inkBlack = Color(0xFF1D1E23); // bg.primary
  static const inkSurface = Color(0xFF2A2B32); // bg.secondary
  static const inkCard = Color(0xFF35363F); // bg.elevated

  // Text
  static const textDark = Color(0xFF2D2D2D);
  static const textLight = Color(0xFFE8E4DF);
  static const textSecondaryDark = Color(0xFF6B6B6B);
  static const textSecondaryLight = Color(0xFFA09B94);
  static const textHint = Color(0xFFA0A0A0);

  // Borders & dividers
  static const dividerLight = Color(0xFFE8E4DF);
  static const dividerDark = Color(0xFF35363F);

  /// Compatibility score → color
  static Color compatibilityColor(int score) {
    if (score >= 90) return compatibilityExcellent;
    if (score >= 70) return compatibilityGood;
    if (score >= 50) return compatibilityNormal;
    return compatibilityLow;
  }

  /// Five element string → main color
  static Color fiveElementColor(String element) {
    return switch (element) {
      '목' || '木' || 'wood' => woodColor,
      '화' || '火' || 'fire' => fireColor,
      '토' || '土' || 'earth' => earthColor,
      '금' || '金' || 'metal' => metalColor,
      '수' || '水' || 'water' => waterColor,
      _ => metalColor,
    };
  }

  /// Five element string → pastel color
  static Color fiveElementPastel(String element) {
    return switch (element) {
      '목' || '木' || 'wood' => woodPastel,
      '화' || '火' || 'fire' => firePastel,
      '토' || '土' || 'earth' => earthPastel,
      '금' || '金' || 'metal' => metalPastel,
      '수' || '水' || 'water' => waterPastel,
      _ => metalPastel,
    };
  }

  // ===========================================================================
  // Spacing System (4px grid)
  // ===========================================================================

  static const space2 = 2.0;
  static const space4 = 4.0;
  static const space6 = 6.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space40 = 40.0;
  static const space48 = 48.0;
  static const space64 = 64.0;

  // Legacy aliases (deprecated — use space* tokens)
  static const spacingXs = space4;
  static const spacingSm = space8;
  static const spacingMd = space16;
  static const spacingLg = space24;
  static const spacingXl = space32;
  static const spacingXxl = space48;

  // ===========================================================================
  // Border Radius
  // ===========================================================================

  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 20.0;
  static const radiusFull = 999.0;

  // ===========================================================================
  // Elevation (surface layering, not Material shadows)
  // ===========================================================================

  /// Light mode: subtle shadow. Dark mode: border only.
  static List<BoxShadow> elevationLow(Brightness brightness) {
    if (brightness == Brightness.dark) return [];
    return const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    ];
  }

  static List<BoxShadow> elevationMedium(Brightness brightness) {
    if (brightness == Brightness.dark) return [];
    return const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    ];
  }

  static List<BoxShadow> elevationHigh(Brightness brightness) {
    if (brightness == Brightness.dark) return [];
    return const [
      BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    ];
  }

  /// Mystic glow — compatibility/saju reveal (dark mode only)
  static List<BoxShadow> elevationMystic() {
    return const [
      BoxShadow(color: Color(0x26C8B68E), blurRadius: 20, spreadRadius: 2),
    ];
  }

  /// Dark mode card border
  static Border? cardBorder(Brightness brightness) {
    if (brightness == Brightness.light) return null;
    return const Border.fromBorderSide(
      BorderSide(color: Color(0xFF35363F), width: 1),
    );
  }

  // ===========================================================================
  // Light Theme
  // ===========================================================================

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.light,
      surface: hanjiSurface,
    ),

    scaffoldBackgroundColor: hanjiBg,

    textTheme: _buildTextTheme(Brightness.light),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textDark,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: BorderSide(color: _primarySeed.withValues(alpha: 0.4)),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: hanjiElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: _primarySeed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: fireColor.withValues(alpha: 0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: fireColor.withValues(alpha: 0.8), width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: textHint,
        fontSize: 15,
      ),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      indicatorColor: _primarySeed.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _tertiarySeed,
          );
        }
        return const TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textHint,
        );
      }),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      backgroundColor: hanjiSurface,
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),

    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      space: 0,
      color: dividerLight,
    ),
  );

  // ===========================================================================
  // Dark Theme (Mystic Mode)
  // ===========================================================================

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.dark,
      surface: inkSurface,
    ),

    scaffoldBackgroundColor: inkBlack,

    textTheme: _buildTextTheme(Brightness.dark),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: textLight,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      color: inkCard,
      surfaceTintColor: Colors.transparent,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: _primarySeed.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Color(0xFF6B6B6B),
        fontSize: 15,
      ),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      elevation: 0,
      height: 64,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      backgroundColor: inkSurface,
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),

    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      space: 0,
      color: dividerDark,
    ),
  );

  // ===========================================================================
  // Typography Builder (Pretendard)
  // ===========================================================================

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light ? textDark : textLight;
    final secondary = brightness == Brightness.light
        ? textSecondaryDark
        : textSecondaryLight;

    return TextTheme(
      // Hero / Display — bold numbers, score reveals
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
        color: base,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
        color: base,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: base,
      ),

      // Headings — section titles
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.35,
        color: base,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: base,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: base,
      ),

      // Titles — card titles, list items
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: base,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: base,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: base,
      ),

      // Body — readable content
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.55,
        color: base,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: base,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: secondary,
      ),

      // Labels — buttons, tags, captions
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: base,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.35,
        color: base,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: secondary,
      ),
    );
  }
}
