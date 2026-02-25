import 'package:flutter/material.dart';

/// 시멘틱 타이포그래피 토큰 — Pretendard 기반
///
/// production-ui-system.md §3 Typography Scale 1:1 매핑.
/// 사용: `context.sajuTypo.heading1`
class SajuTypography extends ThemeExtension<SajuTypography> {
  const SajuTypography({
    required this.hero,
    required this.display1,
    required this.display2,
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.body1,
    required this.body2,
    required this.caption1,
    required this.caption2,
    required this.overline,
  });

  final TextStyle hero;
  final TextStyle display1;
  final TextStyle display2;
  final TextStyle heading1;
  final TextStyle heading2;
  final TextStyle heading3;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle caption1;
  final TextStyle caption2;
  final TextStyle overline;

  static const _font = 'Pretendard';

  static const light = SajuTypography(
    hero: TextStyle(fontFamily: _font, fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1.5, color: Color(0xFF2D2D2D)),
    display1: TextStyle(fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.8, color: Color(0xFF2D2D2D)),
    display2: TextStyle(fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.4, color: Color(0xFF2D2D2D)),
    heading1: TextStyle(fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, letterSpacing: -0.3, color: Color(0xFF2D2D2D)),
    heading2: TextStyle(fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: -0.2, color: Color(0xFF2D2D2D)),
    heading3: TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: -0.1, color: Color(0xFF2D2D2D)),
    body1: TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0, color: Color(0xFF2D2D2D)),
    body2: TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0, color: Color(0xFF2D2D2D)),
    caption1: TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, letterSpacing: 0, color: Color(0xFF6B6B6B)),
    caption2: TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: 0, color: Color(0xFF6B6B6B)),
    overline: TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.2, color: Color(0xFF6B6B6B)),
  );

  static const dark = SajuTypography(
    hero: TextStyle(fontFamily: _font, fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1.5, color: Color(0xFFE8E4DF)),
    display1: TextStyle(fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.8, color: Color(0xFFE8E4DF)),
    display2: TextStyle(fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -0.4, color: Color(0xFFE8E4DF)),
    heading1: TextStyle(fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, letterSpacing: -0.3, color: Color(0xFFE8E4DF)),
    heading2: TextStyle(fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: -0.2, color: Color(0xFFE8E4DF)),
    heading3: TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: -0.1, color: Color(0xFFE8E4DF)),
    body1: TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0, color: Color(0xFFE8E4DF)),
    body2: TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0, color: Color(0xFFE8E4DF)),
    caption1: TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, letterSpacing: 0, color: Color(0xFFA09B94)),
    caption2: TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: 0, color: Color(0xFFA09B94)),
    overline: TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.2, color: Color(0xFFA09B94)),
  );

  @override
  SajuTypography copyWith({
    TextStyle? hero,
    TextStyle? display1,
    TextStyle? display2,
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? caption1,
    TextStyle? caption2,
    TextStyle? overline,
  }) {
    return SajuTypography(
      hero: hero ?? this.hero,
      display1: display1 ?? this.display1,
      display2: display2 ?? this.display2,
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      body1: body1 ?? this.body1,
      body2: body2 ?? this.body2,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
      overline: overline ?? this.overline,
    );
  }

  @override
  SajuTypography lerp(SajuTypography? other, double t) {
    if (other is! SajuTypography) return this;
    return SajuTypography(
      hero: TextStyle.lerp(hero, other.hero, t)!,
      display1: TextStyle.lerp(display1, other.display1, t)!,
      display2: TextStyle.lerp(display2, other.display2, t)!,
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      body1: TextStyle.lerp(body1, other.body1, t)!,
      body2: TextStyle.lerp(body2, other.body2, t)!,
      caption1: TextStyle.lerp(caption1, other.caption1, t)!,
      caption2: TextStyle.lerp(caption2, other.caption2, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
    );
  }
}
