import 'package:flutter/material.dart';

/// 앱 테마 설정
///
/// 사주 기반 데이팅 앱에 맞는 따뜻하고 신비로운 컬러 팔레트를 사용합니다.
/// - Primary: 자주색 계열 (신비로움, 운명)
/// - Secondary: 코랄/핑크 계열 (따뜻함, 로맨스)
/// - Tertiary: 골드 계열 (고급스러움, 동양적 느낌)
///
/// 한국어 가독성을 위해 시스템 폰트(Apple SD Gothic Neo / Roboto)를 기본으로 사용하되,
/// Pretendard 웹폰트를 assets에 추가하면 자동으로 적용되는 구조입니다.
abstract final class AppTheme {
  // ===========================================================================
  // 컬러 시스템
  // ===========================================================================

  // 브랜드 시드 컬러
  static const _primarySeed = Color(0xFF6B3FA0); // 자주색 (신비/운명)
  static const _secondarySeed = Color(0xFFE8617D); // 코랄 핑크 (로맨스)
  static const _tertiarySeed = Color(0xFFD4A24E); // 골드 (동양적/프리미엄)

  // 오행 컬러 (사주 UI에서 사용)
  static const woodColor = Color(0xFF4CAF50); // 목(木) - 초록
  static const fireColor = Color(0xFFEF5350); // 화(火) - 빨강
  static const earthColor = Color(0xFFFFC107); // 토(土) - 황금
  static const metalColor = Color(0xFFBDBDBD); // 금(金) - 은회색
  static const waterColor = Color(0xFF42A5F5); // 수(水) - 파랑

  // 궁합 점수 컬러
  static const compatibilityExcellent = Color(0xFFE91E63); // 90-100: 천생연분
  static const compatibilityGood = Color(0xFFFF7043); // 70-89: 좋은 인연
  static const compatibilityNormal = Color(0xFFFFA726); // 50-69: 보통
  static const compatibilityLow = Color(0xFF78909C); // 0-49: 노력 필요

  /// 궁합 점수에 따른 컬러 반환
  static Color compatibilityColor(int score) {
    if (score >= 90) return compatibilityExcellent;
    if (score >= 70) return compatibilityGood;
    if (score >= 50) return compatibilityNormal;
    return compatibilityLow;
  }

  // ===========================================================================
  // 라이트 테마
  // ===========================================================================

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // --- 컬러 스킴 ---
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.light,
      // 배경을 따뜻한 크림톤으로
      surface: const Color(0xFFFFF8F2),
    ),

    // --- 타이포그래피 ---
    // TODO: Pretendard 폰트 추가 시 fontFamily를 'Pretendard'로 변경
    textTheme: _buildTextTheme(Brightness.light),

    // --- AppBar ---
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),

    // --- Card ---
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    // --- FilledButton ---
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // --- OutlinedButton ---
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: _primarySeed.withValues(alpha: 0.3)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // --- TextButton ---
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // --- InputDecoration ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primarySeed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
      ),
    ),

    // --- Chip ---
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),

    // --- BottomNavigationBar ---
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      indicatorColor: _primarySeed.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _primarySeed,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        );
      }),
    ),

    // --- BottomSheet ---
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
    ),

    // --- Dialog ---
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // --- SnackBar ---
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // --- Divider ---
    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      space: 0,
    ),
  );

  // ===========================================================================
  // 다크 테마
  // ===========================================================================

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // --- 컬러 스킴 ---
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeed,
      secondary: _secondarySeed,
      tertiary: _tertiarySeed,
      brightness: Brightness.dark,
      surface: const Color(0xFF1A1A2E),
    ),

    // --- 타이포그래피 ---
    textTheme: _buildTextTheme(Brightness.dark),

    // --- AppBar ---
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),

    // --- Card ---
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF252540),
      surfaceTintColor: Colors.transparent,
    ),

    // --- FilledButton ---
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // --- OutlinedButton ---
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // --- InputDecoration ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A40),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _primarySeed.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 15,
      ),
    ),

    // --- Chip ---
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),

    // --- BottomNavigationBar ---
    navigationBarTheme: const NavigationBarThemeData(
      elevation: 0,
      height: 64,
    ),

    // --- BottomSheet ---
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
    ),

    // --- Dialog ---
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // --- SnackBar ---
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // --- Divider ---
    dividerTheme: const DividerThemeData(
      thickness: 0.5,
      space: 0,
    ),
  );

  // ===========================================================================
  // 타이포그래피 빌더
  // ===========================================================================

  /// 한국어 최적화 텍스트 테마
  ///
  /// 한국어는 영문 대비 시각적 밀도가 높으므로:
  /// - letterSpacing을 약간 넓힘 (-0.2 ~ 0)
  /// - 제목은 weight를 w700 대신 w600으로 (가독성)
  /// - 본문 lineHeight는 1.5 이상 확보
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? Colors.black87 : Colors.white;

    return TextTheme(
      // 대형 타이틀 (사주 결과, 매칭 점수 등)
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.2,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: baseColor,
      ),

      // 섹션 제목
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
        color: baseColor,
      ),

      // 리스트 제목, 카드 제목
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor,
      ),

      // 본문
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: baseColor.withValues(alpha: 0.7),
      ),

      // 라벨, 캡션
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor.withValues(alpha: 0.6),
      ),
    );
  }
}
