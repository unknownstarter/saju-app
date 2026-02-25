import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// LikeButton — 좋아요 보내기 (Production-level)
///
/// ## Layout Structure
/// ```
/// ┌───────────────────────────────┐
/// │  ♡  좋아요 보내기              │  ← Icon(20) + gap(8) + Text(15/w600)
/// └───────────────────────────────┘
///         height: 52px
/// ```
///
/// ## Padding Rules
/// - Height: 52px (main CTA size)
/// - Horizontal: 24px
/// - Icon to text: 8px
/// - Corner radius: 12px (radiusMd)
///
/// ## States
/// - default: filled rose/pink bg, white text
/// - pressed: scale(0.95) + haptic(medium), 100ms
/// - disabled: opacity(0.4)
/// - loading: spinner replaces icon, text stays
/// - success: heart fills + scale bounce (1.0→1.2→1.0), 400ms
///   then "좋아요를 보냈어요 ♥" text swap, 200ms crossfade
///
/// ## Monetization
/// - Free likes: 3/day → counter shown as "2/3 남음" subtitle
/// - After limit: transforms to "좋아요 추가 구매 (100P)" variant
///
/// ## Animation
/// - Press: 100ms scale(0.95) + haptic medium
/// - Success: heart icon scale 1.0→1.3→1.0 (elasticOut, 400ms)
/// - Text swap: 200ms crossFade to "보냈어요 ♥"
///
/// ## Accessibility
/// - Semantics button: "좋아요 보내기"
/// - Success announced: "좋아요를 보냈어요"
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.onPressed,
    this.isDisabled = false,
    this.remainingFree,
    this.label = '좋아요 보내기',
  });

  final Future<bool> Function() onPressed;
  final bool isDisabled;
  final int? remainingFree;
  final String label;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isDisabled || _isLoading || _isSuccess) return;

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
        _heartController.forward();
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || _isLoading;

    return Semantics(
      button: true,
      label: _isSuccess ? '좋아요를 보냈어요' : widget.label,
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled && !_isSuccess) setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: widget.isDisabled ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _isSuccess
                    ? AppTheme.fireColor
                    : AppTheme.compatibilityExcellent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _heartScale,
                          builder: (context, child) => Transform.scale(
                            scale: _heartScale.value,
                            child: child,
                          ),
                          child: Icon(
                            _isSuccess ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _isSuccess ? '보냈어요 ♥' : widget.label,
                          key: ValueKey(_isSuccess),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Remaining free likes counter
                  if (widget.remainingFree != null && !_isSuccess)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '오늘 ${widget.remainingFree}회 남음',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
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
