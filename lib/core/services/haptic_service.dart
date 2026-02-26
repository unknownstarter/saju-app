import 'package:flutter/services.dart';

/// 글로벌 햅틱 피드백 서비스
///
/// 모든 인터랙션에 일관된 햅틱 피드백을 제공한다.
/// iOS에서는 Taptic Engine, Android에서는 진동 피드백을 사용.
abstract final class HapticService {
  /// 칩/옵션 선택 시 — 가벼운 클릭
  static void selection() => HapticFeedback.selectionClick();

  /// 자동 진행, 버튼 활성화 시 — 가벼운 임팩트
  static void light() => HapticFeedback.lightImpact();

  /// CTA 탭, 중요 액션 시 — 중간 임팩트
  static void medium() => HapticFeedback.mediumImpact();

  /// 에러 발생 시 — 강한 임팩트
  static void error() => HapticFeedback.heavyImpact();

  /// 성공/축하 시 — 가벼운 임팩트
  static void success() => HapticFeedback.lightImpact();
}
