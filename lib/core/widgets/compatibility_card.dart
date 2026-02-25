import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// CompatibilityCard — 궁합 결과 카드 (Production-level)
///
/// ## Layout Structure
/// ```
/// ┌─────────────────────────────────────┐
/// │  [Score Circle]  Name₁ × Name₂     │  ← Row: gauge(56px) + names
/// │       87%        궁합 점수          │
/// ├─────────────────────────────────────┤
/// │  ▸ 이런 점이 잘 맞아요              │  ← Strength chip list
/// │    [오행 상생] [일주 조화]           │
/// ├─────────────────────────────────────┤
/// │         [상세 궁합 보기 →]           │  ← CTA (monetization)
/// └─────────────────────────────────────┘
/// ```
///
/// ## Padding Rules
/// - Card outer: 0 (parent controls margin)
/// - Card inner: 16px all sides
/// - Score circle to names: 12px gap
/// - Sections: 12px gap, 8px divider padding
///
/// ## States
/// - default: normal render
/// - pressed: scale(0.98), 150ms
/// - loading: skeleton (score circle shimmer + text placeholders)
/// - revealed: score counts up 0→N (1200ms easeOutCubic)
///
/// ## Monetization
/// - "상세 궁합 보기" CTA → 500P 유료 리포트 진입점
/// - Score tease: shows % but hides detailed breakdown → upsell
///
/// ## Animation
/// - Score reveal: countUp 0→score (1200ms) + circle fill
/// - Card entrance: fadeIn + slideUp(12px), 300ms
///
/// ## Accessibility
/// - Semantics: "{name1}님과 {name2}님의 궁합 {score}점"
/// - Grade announced: "천생연분" / "좋은 인연" etc.
class CompatibilityCard extends StatefulWidget {
  const CompatibilityCard({
    super.key,
    required this.score,
    required this.name1,
    required this.name2,
    this.strengths = const [],
    this.grade,
    this.onDetailTap,
    this.isLoading = false,
    this.animateOnAppear = true,
  });

  final int score;
  final String name1;
  final String name2;
  final List<String> strengths;
  final String? grade;
  final VoidCallback? onDetailTap;
  final bool isLoading;
  final bool animateOnAppear;

  @override
  State<CompatibilityCard> createState() => _CompatibilityCardState();
}

class _CompatibilityCardState extends State<CompatibilityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animateOnAppear && !widget.isLoading) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    } else if (!widget.animateOnAppear) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _grade {
    if (widget.grade != null) return widget.grade!;
    if (widget.score >= 90) return '천생연분';
    if (widget.score >= 70) return '좋은 인연';
    if (widget.score >= 50) return '보통 인연';
    return '노력이 필요한 인연';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildSkeleton(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor = AppTheme.compatibilityColor(widget.score);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '${widget.name1}님과 ${widget.name2}님의 궁합 ${widget.score}점, $_grade',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onDetailTap?.call();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.inkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: AppTheme.cardBorder(Theme.of(context).brightness),
              boxShadow: AppTheme.elevationMedium(Theme.of(context).brightness),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score + Names row
                Row(
                  children: [
                    // Mini gauge
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, _) {
                        return _MiniGauge(
                          score: _scoreAnimation.value,
                          color: scoreColor,
                          size: 56,
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.name1} × ${widget.name2}',
                            style: textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _grade,
                            style: textTheme.bodySmall?.copyWith(color: scoreColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Strengths
                if (widget.strengths.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.space12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.strengths.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: scoreColor,
                        ),
                      ),
                    )).toList(),
                  ),
                ],

                // Detail CTA (monetization)
                if (widget.onDetailTap != null) ...[
                  const SizedBox(height: AppTheme.space12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Text(
                      '상세 궁합 보기 →',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmer = isDark ? AppTheme.inkCard : AppTheme.hanjiElevated;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.inkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, color: shimmer)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 80, height: 12, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini circular gauge for inline score display
class _MiniGauge extends StatelessWidget {
  const _MiniGauge({required this.score, required this.color, required this.size});

  final double score;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 3,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${score.round()}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
