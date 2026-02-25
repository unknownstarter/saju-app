import 'package:flutter/material.dart';

/// 애니메이션 토큰 — Duration, Curve
///
/// production-ui-system.md §7 Interaction Feedback System 매핑.
/// 사용: `SajuAnimation.fast` / `SajuAnimation.entrance`
abstract final class SajuAnimation {
  // Durations
  static const fast = Duration(milliseconds: 100);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
  static const sheet = Duration(milliseconds: 400);
  static const like = Duration(milliseconds: 500);
  static const match = Duration(milliseconds: 600);
  static const reveal = Duration(milliseconds: 1800);

  // Curves
  static const entrance = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const bounce = Curves.elasticOut;

  // Interaction feedback values
  static const pressedOpacity = 0.7;
  static const pressedScale = 0.97;
  static const disabledOpacity = 0.4;
}
