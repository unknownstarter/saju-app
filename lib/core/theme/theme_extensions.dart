import 'package:flutter/material.dart';

import 'tokens/saju_colors.dart';
import 'tokens/saju_typography.dart';
import 'tokens/saju_elevation.dart';

/// BuildContext에서 Saju 토큰에 편리하게 접근하기 위한 extension.
///
/// ```dart
/// final colors = context.sajuColors;
/// final typo = context.sajuTypo;
/// final elevation = context.sajuElevation;
/// ```
extension SajuThemeX on BuildContext {
  SajuColors get sajuColors => Theme.of(this).extension<SajuColors>()!;
  SajuTypography get sajuTypo => Theme.of(this).extension<SajuTypography>()!;
  SajuElevation get sajuElevation => Theme.of(this).extension<SajuElevation>()!;

  /// 현재 다크 모드인지 여부
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
