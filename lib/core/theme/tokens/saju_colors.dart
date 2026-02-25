import 'package:flutter/material.dart';

/// 시멘틱 컬러 토큰 — 라이트/다크 자동 전환
///
/// production-ui-system.md §4 Color Token System 1:1 매핑.
/// 사용: `context.sajuColors.bgPrimary`
class SajuColors extends ThemeExtension<SajuColors> {
  const SajuColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.borderDefault,
    required this.borderFocus,
    required this.fillBrand,
    required this.fillAccent,
    required this.fillDisabled,
  });

  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color borderDefault;
  final Color borderFocus;
  final Color fillBrand;
  final Color fillAccent;
  final Color fillDisabled;

  /// 라이트 모드 (한지 톤)
  static const light = SajuColors(
    bgPrimary: Color(0xFFF7F3EE),
    bgSecondary: Color(0xFFF0EDE8),
    bgElevated: Color(0xFFFEFCF9),
    textPrimary: Color(0xFF2D2D2D),
    textSecondary: Color(0xFF6B6B6B),
    textTertiary: Color(0xFFA0A0A0),
    textInverse: Color(0xFFFEFCF9),
    borderDefault: Color(0xFFE8E4DF),
    borderFocus: Color(0xFFA8C8E8),
    fillBrand: Color(0xFFA8C8E8),
    fillAccent: Color(0xFFF2D0D5),
    fillDisabled: Color(0xFFE8E4DF),
  );

  /// 다크 모드 (먹색 톤)
  static const dark = SajuColors(
    bgPrimary: Color(0xFF1D1E23),
    bgSecondary: Color(0xFF2A2B32),
    bgElevated: Color(0xFF35363F),
    textPrimary: Color(0xFFE8E4DF),
    textSecondary: Color(0xFFA09B94),
    textTertiary: Color(0xFF6B6B6B),
    textInverse: Color(0xFF2D2D2D),
    borderDefault: Color(0xFF35363F),
    borderFocus: Color(0x99A8C8E8),
    fillBrand: Color(0xFFA8C8E8),
    fillAccent: Color(0xFFF2D0D5),
    fillDisabled: Color(0xFF35363F),
  );

  @override
  SajuColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInverse,
    Color? borderDefault,
    Color? borderFocus,
    Color? fillBrand,
    Color? fillAccent,
    Color? fillDisabled,
  }) {
    return SajuColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgElevated: bgElevated ?? this.bgElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocus: borderFocus ?? this.borderFocus,
      fillBrand: fillBrand ?? this.fillBrand,
      fillAccent: fillAccent ?? this.fillAccent,
      fillDisabled: fillDisabled ?? this.fillDisabled,
    );
  }

  @override
  SajuColors lerp(SajuColors? other, double t) {
    if (other is! SajuColors) return this;
    return SajuColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      fillBrand: Color.lerp(fillBrand, other.fillBrand, t)!,
      fillAccent: Color.lerp(fillAccent, other.fillAccent, t)!,
      fillDisabled: Color.lerp(fillDisabled, other.fillDisabled, t)!,
    );
  }
}
