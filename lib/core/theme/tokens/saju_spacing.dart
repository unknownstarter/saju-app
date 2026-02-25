import 'package:flutter/material.dart';

/// 스페이싱 토큰 — 4px 그리드, 테마 불변
///
/// production-ui-system.md §2 Spacing System 매핑.
/// 사용: `SajuSpacing.space16` 또는 `SajuSpacing.page`
abstract final class SajuSpacing {
  // 4px grid
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

  // EdgeInsets presets
  static const page = EdgeInsets.symmetric(horizontal: 20);
  static const cardInner = EdgeInsets.all(16);
  static const cardInnerCompact = EdgeInsets.all(12);

  // SizedBox presets for common vertical gaps
  static const gap2 = SizedBox(height: 2);
  static const gap4 = SizedBox(height: 4);
  static const gap8 = SizedBox(height: 8);
  static const gap12 = SizedBox(height: 12);
  static const gap16 = SizedBox(height: 16);
  static const gap24 = SizedBox(height: 24);
  static const gap32 = SizedBox(height: 32);

  // SizedBox presets for common horizontal gaps
  static const hGap4 = SizedBox(width: 4);
  static const hGap8 = SizedBox(width: 8);
  static const hGap12 = SizedBox(width: 12);
  static const hGap16 = SizedBox(width: 16);
}
