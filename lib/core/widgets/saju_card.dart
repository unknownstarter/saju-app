import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/saju_animation.dart';
import '../theme/tokens/saju_spacing.dart';
import 'saju_enums.dart';

/// SajuCard — 사주 디자인 시스템 카드 컴포넌트
///
/// HeroUI의 Header/Content/Footer 패턴을 따르며,
/// 한지 팔레트 디자인 시스템에 맞춰 스타일링된다.
///
/// ```dart
/// SajuCard(
///   header: Text('헤더'),
///   content: Text('본문'),
///   footer: Text('푸터'),
///   variant: SajuVariant.elevated,
///   onTap: () {},
///   padding: EdgeInsets.all(16),
///   borderColor: Colors.red,
/// )
/// ```
class SajuCard extends StatelessWidget {
  const SajuCard({
    super.key,
    this.header,
    required this.content,
    this.footer,
    this.variant = SajuVariant.elevated,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  /// 카드 상단 위젯 (선택)
  final Widget? header;

  /// 카드 본문 위젯 (필수)
  final Widget content;

  /// 카드 하단 위젯 (선택)
  final Widget? footer;

  /// 카드 스타일 변형 (filled, outlined, flat, elevated, ghost)
  final SajuVariant variant;

  /// 탭 콜백 (선택). null이면 탭 이벤트를 처리하지 않는다.
  final VoidCallback? onTap;

  /// 내부 여백. 기본값: `EdgeInsets.all(16)`
  final EdgeInsets padding;

  /// 외곽선 색상 (선택). 지정 시 해당 색상의 border가 추가된다.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SajuAnimation.normal,
        curve: Curves.easeInOut,
        padding: padding,
        decoration: _buildDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header!,
              SajuSpacing.gap8,
            ],
            content,
            if (footer != null) ...[
              SajuSpacing.gap8,
              footer!,
            ],
          ],
        ),
      ),
    );
  }

  /// variant와 테마에 따른 BoxDecoration 생성
  BoxDecoration _buildDecoration(BuildContext context) {
    final colors = context.sajuColors;
    final borderRadius = BorderRadius.circular(AppTheme.radiusLg);

    switch (variant) {
      case SajuVariant.filled:
        return BoxDecoration(
          color: colors.bgElevated,
          borderRadius: borderRadius,
          border: _resolveBorder(),
        );

      case SajuVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : Border.all(color: colors.borderDefault, width: 1),
        );

      case SajuVariant.elevated:
        return BoxDecoration(
          color: colors.bgElevated,
          borderRadius: borderRadius,
          border: _resolveBorder(),
          boxShadow: context.sajuElevation.mediumShadow,
        );

      case SajuVariant.flat:
      case SajuVariant.ghost:
        return BoxDecoration(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: borderRadius,
          border: _resolveBorder(),
        );
    }
  }

  /// borderColor가 지정된 경우 해당 색상의 border를 반환,
  /// 그렇지 않으면 null (outlined 제외)
  Border? _resolveBorder() {
    if (borderColor != null) {
      return Border.all(color: borderColor!, width: 1);
    }
    return null;
  }
}
