import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// PremiumLikeButton — 슈퍼 좋아요 (Production-level, Monetization Core)
///
/// ## Layout Structure
/// ```
/// ┌─────────────────────────────────┐
/// │  ⭐  슈퍼 좋아요     300P      │  ← Icon(20) + Text + Price badge
/// │      상대에게 바로 전달돼요      │  ← Subtitle (11px, 60% opacity)
/// └─────────────────────────────────┘
///           height: 56px
/// ```
///
/// ## Padding Rules
/// - Height: 56px (xl CTA)
/// - Horizontal: 20px
/// - Icon to text: 8px
/// - Price badge: right-aligned, 8px horizontal padding
/// - Subtitle: 2px below main text
///
/// ## States
/// - default: mystic gold gradient bg, dark text
/// - pressed: scale(0.95) + haptic(medium), 100ms
/// - disabled: opacity(0.4), "포인트 부족" subtitle
/// - loading: gold spinner + "전송 중..." text
/// - success: star burst animation + "전달 완료!" text, 500ms
///
/// ## Monetization (PRIMARY)
/// - This IS the monetization widget. 300P per use.
/// - Price badge always visible → cost awareness
/// - "상대에게 바로 전달돼요" → value proposition (skip queue)
/// - Insufficient points → "포인트 충전하기" CTA variant
///
/// ## Animation
/// - Press: 100ms scale(0.95)
/// - Idle: subtle gold shimmer on border (2s loop, very subtle)
/// - Success: star icon rotates 360° + scale bounce, 500ms
///
/// ## Accessibility
/// - Semantics: "슈퍼 좋아요, 300 포인트 필요"
/// - Disabled hint: "포인트가 부족합니다"
class PremiumLikeButton extends StatefulWidget {
  const PremiumLikeButton({
    super.key,
    required this.onPressed,
    this.cost = 300,
    this.userPoints = 0,
    this.onInsufficientPoints,
    this.label = '슈퍼 좋아요',
    this.subtitle = '상대에게 바로 전달돼요',
  });

  final Future<bool> Function() onPressed;
  final int cost;
  final int userPoints;
  final VoidCallback? onInsufficientPoints;
  final String label;
  final String subtitle;

  @override
  State<PremiumLikeButton> createState() => _PremiumLikeButtonState();
}

class _PremiumLikeButtonState extends State<PremiumLikeButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  late AnimationController _starController;

  bool get _hasEnoughPoints => widget.userPoints >= widget.cost;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading || _isSuccess) return;

    if (!_hasEnoughPoints) {
      HapticFeedback.heavyImpact();
      widget.onInsufficientPoints?.call();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final success = await widget.onPressed();
      if (success && mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        HapticFeedback.heavyImpact();
        _starController.forward();
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.label}, ${widget.cost} 포인트 필요',
      hint: _hasEnoughPoints ? null : '포인트가 부족합니다',
      child: GestureDetector(
        onTapDown: (_) {
          if (!_isLoading && !_isSuccess) setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSuccess
                    ? [AppTheme.mysticGlow, AppTheme.earthColor]
                    : [AppTheme.mysticGlow.withValues(alpha: 0.9), AppTheme.mysticAccent],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.mysticGlow.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Star icon
                  if (_isLoading)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppTheme.inkBlack),
                      ),
                    )
                  else
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: _starController, curve: Curves.easeOutBack),
                      ),
                      child: Icon(
                        _isSuccess ? Icons.check_circle : Icons.star_rounded,
                        size: 22,
                        color: AppTheme.inkBlack,
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Text column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isSuccess
                                ? '전달 완료!'
                                : (_isLoading ? '전송 중...' : widget.label),
                            key: ValueKey('$_isSuccess$_isLoading'),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.inkBlack,
                            ),
                          ),
                        ),
                        if (!_isSuccess && !_isLoading)
                          Text(
                            _hasEnoughPoints
                                ? widget.subtitle
                                : '포인트가 부족해요',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppTheme.inkBlack.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price badge
                  if (!_isSuccess)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.inkBlack.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '${widget.cost}P',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.inkBlack,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
