import 'package:flutter/material.dart';

/// 엘리베이션 토큰 — 라이트는 섀도, 다크는 보더+글로우
///
/// production-ui-system.md §5 Elevation System 매핑.
/// 사용: `context.sajuElevation.mediumShadow`
class SajuElevation extends ThemeExtension<SajuElevation> {
  const SajuElevation({
    required this.lowShadow,
    required this.mediumShadow,
    required this.highShadow,
    required this.mysticShadow,
    required this.cardBorder,
  });

  final List<BoxShadow> lowShadow;
  final List<BoxShadow> mediumShadow;
  final List<BoxShadow> highShadow;
  final List<BoxShadow> mysticShadow;
  final BorderSide? cardBorder;

  static const light = SajuElevation(
    lowShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))],
    mediumShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
    highShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4))],
    mysticShadow: [],
    cardBorder: null,
  );

  static const dark = SajuElevation(
    lowShadow: [],
    mediumShadow: [],
    highShadow: [],
    mysticShadow: [BoxShadow(color: Color(0x26C8B68E), blurRadius: 20, spreadRadius: 2)],
    cardBorder: BorderSide(color: Color(0xFF35363F), width: 1),
  );

  @override
  SajuElevation copyWith({
    List<BoxShadow>? lowShadow,
    List<BoxShadow>? mediumShadow,
    List<BoxShadow>? highShadow,
    List<BoxShadow>? mysticShadow,
    BorderSide? cardBorder,
  }) {
    return SajuElevation(
      lowShadow: lowShadow ?? this.lowShadow,
      mediumShadow: mediumShadow ?? this.mediumShadow,
      highShadow: highShadow ?? this.highShadow,
      mysticShadow: mysticShadow ?? this.mysticShadow,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  SajuElevation lerp(SajuElevation? other, double t) {
    if (other is! SajuElevation) return this;
    return t < 0.5 ? this : other;
  }
}
