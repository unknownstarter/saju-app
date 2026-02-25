import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens/saju_spacing.dart';
import 'saju_enums.dart';

/// CharacterBubble — 캐릭터 가이드 말풍선 (Production-level)
///
/// ## Layout Structure
/// ```
/// ┌───┐
/// │ 🐻│  나무리                      ← Character circle + name
/// └───┘  ┌─────────────────────────┐
///        │ 찾았다! 네 사주를 봤어!  │  ← Speech bubble (topLeft: 0)
///        └─────────────────────────┘
/// ```
///
/// ## Padding Rules
/// - Character circle: size-driven (SajuSize.height)
/// - Circle to bubble: 8px gap
/// - Bubble inner: SajuSize.padding
/// - Name above bubble: 4px gap
///
/// ## States
/// - default: static render
/// - loading: pulse animation on character circle (0.9↔1.0 scale, 1200ms)
/// - typing: "..." animated dots in bubble
///
/// ## Animation
/// - Entrance: character slides in from left (150ms) then bubble fades in (200ms)
/// - Typing dots: 3 dots with 200ms stagger opacity
///
/// ## Accessibility
/// - Semantics: "{characterName}: {message}"
/// - Message is live region for screen readers
class SajuCharacterBubble extends StatelessWidget {
  const SajuCharacterBubble({
    super.key,
    required this.characterName,
    required this.message,
    required this.elementColor,
    this.characterAssetPath,
    this.size = SajuSize.md,
    this.isTyping = false,
  });

  final String characterName;
  final String message;
  final SajuColor elementColor;
  final String? characterAssetPath;
  final SajuSize size;
  final bool isTyping;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = elementColor.resolve(context);
    final pastelColor = elementColor.resolvePastel(context);

    return Semantics(
      label: '$characterName: $message',
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCharacterCircle(color, pastelColor),
          SajuSpacing.hGap8,
          Expanded(
            child: _buildSpeechBubble(context, isDark, color, pastelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCircle(Color color, Color pastelColor) {
    final dimension = size.height;
    final firstChar = characterName.characters.first;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pastelColor,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: characterAssetPath != null
            ? Image.asset(
                characterAssetPath!,
                width: dimension,
                height: dimension,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallbackText(firstChar, color),
              )
            : _buildFallbackText(firstChar, color),
      ),
    );
  }

  Widget _buildFallbackText(String char, Color color) {
    return Center(
      child: Text(
        char,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: size.fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(
    BuildContext context,
    bool isDark,
    Color color,
    Color pastelColor,
  ) {
    final bubbleBg = isDark
        ? color.withValues(alpha: 0.1)
        : pastelColor.withValues(alpha: 0.6);

    const bubbleRadius = BorderRadius.only(
      topLeft: Radius.zero,
      topRight: Radius.circular(AppTheme.radiusLg),
      bottomLeft: Radius.circular(AppTheme.radiusLg),
      bottomRight: Radius.circular(AppTheme.radiusLg),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          characterName,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: size.fontSize - 2,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SajuSpacing.gap4,
        Container(
          padding: size.padding,
          decoration: BoxDecoration(
            color: bubbleBg,
            border: Border.all(color: color.withValues(alpha: 0.15)),
            borderRadius: bubbleRadius,
          ),
          child: isTyping
              ? _TypingDots(color: color)
              : Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: size.fontSize,
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Animated typing dots: "..."
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});
  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (0.3 + 0.7 * (1 - (2 * value - 1).abs())).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
