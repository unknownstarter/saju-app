import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/haptic_service.dart';
import '../theme/tokens/saju_spacing.dart';
import 'saju_enums.dart';

/// SajuInput — 사주 디자인 시스템 텍스트 입력 컴포넌트
///
/// 한지 팔레트 디자인 시스템에 맞춰 스타일링된 텍스트 입력 필드.
/// 라벨 + TextField의 Column 레이아웃으로 구성된다.
///
/// errorText가 null → non-null로 바뀔 때 필드가 좌우 흔들림(shake) +
/// 햅틱 피드백을 제공한다.
///
/// ```dart
/// SajuInput(
///   label: '이름',
///   hint: '이름을 입력해주세요',
///   controller: ctrl,
///   errorText: '필수 입력입니다',
///   onChanged: (v) {},
///   size: SajuSize.md,
/// )
/// ```
class SajuInput extends StatefulWidget {
  const SajuInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
    this.size = SajuSize.md,
  });

  /// 입력 필드 위에 표시할 라벨 텍스트
  final String label;

  /// 입력 필드 힌트 텍스트 (placeholder)
  final String? hint;

  /// 텍스트 입력 컨트롤러
  final TextEditingController? controller;

  /// 에러 메시지. non-null이면 에러 상태로 표시된다.
  final String? errorText;

  /// 텍스트 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 키보드 제출(완료/엔터) 콜백
  final ValueChanged<String>? onSubmitted;

  /// 키보드 타입 (text, number, email 등)
  final TextInputType? keyboardType;

  /// 비밀번호 등 텍스트 숨김 여부
  final bool obscureText;

  /// 최대 줄 수
  final int maxLines;

  /// 최대 입력 글자 수 (카운터는 숨김)
  final int? maxLength;

  /// 입력 포맷터 (숫자만 허용 등)
  final List<TextInputFormatter>? inputFormatters;

  /// 입력 필드 앞 아이콘 위젯
  final Widget? prefixIcon;

  /// 입력 필드 뒤 아이콘 위젯
  final Widget? suffixIcon;

  /// 활성/비활성 여부
  final bool enabled;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 컴포넌트 크기 (xs ~ xl)
  final SajuSize size;

  @override
  State<SajuInput> createState() => _SajuInputState();
}

class _SajuInputState extends State<SajuInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant SajuInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0);
      HapticService.error();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.size.fontSize * 0.9,
            fontWeight: FontWeight.w600,
          ),
        ),
        SajuSpacing.gap8,
        // 입력 필드 (shake 래핑)
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            style: TextStyle(fontSize: widget.size.fontSize),
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}
