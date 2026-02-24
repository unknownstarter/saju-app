import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// 온보딩 인트로 페이지 — 3장의 슬라이드로 앱을 소개
///
/// 신비 모드(다크 배경)를 사용하며, 한지 팔레트의 은은한 컬러로
/// "운명적 만남"이라는 앱의 핵심 가치를 전달한다.
///
/// 슬라이드:
/// 1. 운명이 이끈 만남 — 캐릭터 비주얼
/// 2. AI가 읽어주는 궁합 — 궁합 게이지 비주얼
/// 3. 대화로 확인하는 운명 — CTA "시작하기" 버튼
class OnboardingIntroPage extends StatefulWidget {
  const OnboardingIntroPage({
    super.key,
    this.onComplete,
  });

  /// 인트로 완료 시 호출되는 콜백.
  /// null이면 기본적으로 [RoutePaths.login]으로 이동한다.
  final VoidCallback? onComplete;

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  int _currentPage = 0;

  static const _totalPages = 3;
  static const _pageTransitionDuration = Duration(milliseconds: 400);
  static const _pageCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: _pageTransitionDuration,
        curve: _pageCurve,
      );
    }
  }

  void _onSkip() {
    _handleComplete();
  }

  void _onStart() {
    _handleComplete();
  }

  void _handleComplete() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    // 상단 건너뛰기 버튼
                    _buildSkipButton(context),

                    // 페이지뷰 (슬라이드)
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _SlideDestiny(onNext: _goToNextPage),
                          _SlideCompatibility(onNext: _goToNextPage),
                          _SlideConversation(onStart: _onStart),
                        ],
                      ),
                    ),

                    // 하단 페이지 인디케이터 + 네비게이션
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 상단 우측 "건너뛰기" 버튼
  Widget _buildSkipButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppTheme.spacingSm,
          right: AppTheme.spacingMd,
        ),
        child: AnimatedOpacity(
          opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: TextButton(
            onPressed: _currentPage < _totalPages - 1 ? _onSkip : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA09B94),
            ),
            child: const Text(
              '건너뛰기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 인디케이터 + 다음/시작 버튼 영역
  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingLg,
        right: AppTheme.spacingLg,
        bottom: AppTheme.spacingXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 페이지 인디케이터 점(dot)
          _PageIndicator(
            totalPages: _totalPages,
            currentPage: _currentPage,
          ),
          const SizedBox(height: AppTheme.spacingXl),

          // 마지막 페이지: 시작하기 버튼 / 그 외: 다음 버튼
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _currentPage == _totalPages - 1
                ? SajuButton(
                    key: const ValueKey('start'),
                    label: '시작하기',
                    onPressed: _onStart,
                    variant: SajuVariant.filled,
                    color: SajuColor.primary,
                    size: SajuSize.xl,
                  )
                : SajuButton(
                    key: const ValueKey('next'),
                    label: '다음',
                    onPressed: _goToNextPage,
                    variant: SajuVariant.outlined,
                    color: SajuColor.primary,
                    size: SajuSize.lg,
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 슬라이드 1: 운명이 이끈 만남
// =============================================================================

class _SlideDestiny extends StatelessWidget {
  const _SlideDestiny({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _SlideLayout(
      visual: _CharacterPlaceholder(),
      headline: '너의 운명적 인연,\n사주가 알고 있어',
      subtext: '4,000년 동양 지혜 × AI가 찾아주는 진짜 인연',
    );
  }
}

// =============================================================================
// 슬라이드 2: AI가 읽어주는 궁합
// =============================================================================

class _SlideCompatibility extends StatelessWidget {
  const _SlideCompatibility({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _SlideLayout(
      visual: _CompatibilityGaugePlaceholder(),
      headline: '사주로 보는\n우리의 궁합',
      subtext: '오행의 상생상극, AI가 스토리로 풀어줘',
    );
  }
}

// =============================================================================
// 슬라이드 3: 대화로 확인하는 운명
// =============================================================================

class _SlideConversation extends StatelessWidget {
  const _SlideConversation({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _SlideLayout(
      visual: _ConversationPlaceholder(),
      headline: '운명이 이어준 대화,\n시작해볼까?',
      subtext: '스와이프 말고, 진짜 인연을 만나봐',
    );
  }
}

// =============================================================================
// 공통 슬라이드 레이아웃
// =============================================================================

class _SlideLayout extends StatefulWidget {
  const _SlideLayout({
    required this.visual,
    required this.headline,
    required this.subtext,
  });

  final Widget visual;
  final String headline;
  final String subtext;

  @override
  State<_SlideLayout> createState() => _SlideLayoutState();
}

class _SlideLayoutState extends State<_SlideLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 비주얼 영역 (상위 40%)
            Expanded(
              flex: 4,
              child: Center(child: widget.visual),
            ),

            // 텍스트 영역
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingMd),

                  // 헤드라인
                  Text(
                    widget.headline,
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      color: const Color(0xFFE8E4DF),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // 서브텍스트
                  Text(
                    widget.subtext,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFA09B94),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 비주얼 플레이스홀더들
// =============================================================================

/// 슬라이드 1: 캐릭터 플레이스홀더
///
/// 나중에 오행이 캐릭터 에셋으로 교체할 자리.
/// 현재는 은은한 글로우 원 안에 별 아이콘으로 표현.
class _CharacterPlaceholder extends StatefulWidget {
  @override
  State<_CharacterPlaceholder> createState() => _CharacterPlaceholderState();
}

class _CharacterPlaceholderState extends State<_CharacterPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.mysticGlow.withValues(
                  alpha: 0.15 * _pulseAnimation.value,
                ),
                AppTheme.mysticGlow.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: AppTheme.mysticGlow.withValues(
                alpha: 0.2 * _pulseAnimation.value,
              ),
              width: 1.5,
            ),
          ),
          child: child,
        );
      },
      child: const Icon(
        Icons.auto_awesome,
        size: 56,
        color: AppTheme.mysticGlow,
      ),
    );
  }
}

/// 슬라이드 2: 궁합 게이지 플레이스홀더
///
/// 오행 5개 요소의 상생상극 관계를 시각적으로 암시하는 UI.
/// 나중에 실제 궁합 게이지로 교체할 자리.
class _CompatibilityGaugePlaceholder extends StatefulWidget {
  @override
  State<_CompatibilityGaugePlaceholder> createState() =>
      _CompatibilityGaugePlaceholderState();
}

class _CompatibilityGaugePlaceholderState
    extends State<_CompatibilityGaugePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elements = [
      (AppTheme.woodColor, '木'),
      (AppTheme.fireColor, '火'),
      (AppTheme.earthColor, '土'),
      (AppTheme.metalColor, '金'),
      (AppTheme.waterColor, '水'),
    ];

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 궁합 점수 원
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final progress = CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutCubic,
              ).value;
              return Opacity(
                opacity: progress,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.mysticGlow.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.mysticGlow.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '92',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mysticGlow.withValues(
                          alpha: progress,
                        ),
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 오행 원형 배치
          for (var i = 0; i < elements.length; i++)
            _buildElementOrb(i, elements[i]),
        ],
      ),
    );
  }

  Widget _buildElementOrb(int index, (Color, String) element) {
    final (color, label) = element;

    // 원형으로 배치 (72도 간격, 상단 시작)
    const radius = 85.0;
    final angle = (index * 72 - 90) * math.pi / 180;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = index * 0.12;
        final progress = Interval(delay, delay + 0.5, curve: Curves.easeOut)
            .transform(_animController.value);

        final dx = radius * math.cos(angle) * progress;
        final dy = radius * math.sin(angle) * progress;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// 슬라이드 3: 대화 플레이스홀더
///
/// 채팅 버블 형태로 "운명적 대화"를 암시하는 UI.
class _ConversationPlaceholder extends StatefulWidget {
  @override
  State<_ConversationPlaceholder> createState() =>
      _ConversationPlaceholderState();
}

class _ConversationPlaceholderState extends State<_ConversationPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbles = [
      (0.0, Alignment.centerLeft, '오늘 운세가 좋대요'),
      (0.25, Alignment.centerRight, '우리 궁합 92점이래!'),
      (0.5, Alignment.centerLeft, '운명인가봐요'),
    ];

    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (delay, alignment, text) in bubbles)
            _buildBubble(delay, alignment, text),
        ],
      ),
    );
  }

  Widget _buildBubble(double delay, Alignment alignment, String text) {
    final isLeft = alignment == Alignment.centerLeft;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = Interval(delay, delay + 0.4, curve: Curves.easeOut)
            .transform(_animController.value);

        return Transform.translate(
          offset: Offset(0, 20 * (1 - progress)),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm + 2,
          ),
          decoration: BoxDecoration(
            color: isLeft
                ? const Color(0xFF35363F)
                : AppTheme.mysticGlow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppTheme.radiusLg),
              topRight: const Radius.circular(AppTheme.radiusLg),
              bottomLeft: Radius.circular(isLeft ? 4 : AppTheme.radiusLg),
              bottomRight: Radius.circular(isLeft ? AppTheme.radiusLg : 4),
            ),
            border: isLeft
                ? null
                : Border.all(
                    color: AppTheme.mysticGlow.withValues(alpha: 0.2),
                    width: 1,
                  ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLeft
                  ? const Color(0xFFE8E4DF)
                  : AppTheme.mysticAccent,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 페이지 인디케이터 (AnimatedContainer 기반)
// =============================================================================

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.totalPages,
    required this.currentPage,
  });

  final int totalPages;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            color: isActive
                ? AppTheme.mysticGlow
                : AppTheme.mysticGlow.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
