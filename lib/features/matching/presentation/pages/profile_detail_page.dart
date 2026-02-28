import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/tokens/saju_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/match_profile.dart';
import 'compatibility_preview_page.dart';

/// ProfileDetailPage — 추천 이성 프로필 상세 (다크 모드)
///
/// ## 핵심 UX
/// - 프로필 사진은 **blur(sigma 25)** 처리
/// - 캐릭터 아바타(80x80)가 블러 위에 오버레이
/// - 매칭 성사(쌍방 좋아요) 시에만 사진 공개
/// - 이 호기심 갭이 좋아요 & 결제 전환의 핵심 동력
///
/// ## Layout
/// ```
/// ┌─────────────────────────────────┐
/// │  ← (back)                       │
/// │                                 │
/// │     ┌───────────────────┐       │
/// │     │  BLURRED PHOTO    │       │
/// │     │    (sigma 25)     │       │
/// │     │                   │       │
/// │     │   [Character]     │       │  ← 80x80 캐릭터 center
/// │     │     80x80         │       │
/// │     │                   │       │
/// │     │  🔒 좋아요하면    │       │
/// │     │  사진이 공개돼요  │       │
/// │     └───────────────────┘       │
/// │                                 │
/// │  Name, Age        [Element]     │
/// │  Bio text ...                   │
/// │                                 │
/// │  ── 궁합 점수 ──                │
/// │    [CompatibilityGauge]          │
/// │                                 │
/// │  [💖 좋아요 보내기]    (filled)  │
/// │  [📊 상세 궁합 보기]   (ghost)   │
/// └─────────────────────────────────┘
/// ```
class ProfileDetailPage extends ConsumerWidget {
  const ProfileDetailPage({
    super.key,
    required this.profile,
  });

  final MatchProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementColor = AppTheme.fiveElementColor(profile.elementType);
    final elementPastel = AppTheme.fiveElementPastel(profile.elementType);
    final scoreColor = AppTheme.compatibilityColor(profile.compatibilityScore);

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          final textTheme = Theme.of(context).textTheme;
          final colors = context.sajuColors;

          return Scaffold(
            backgroundColor: colors.bgPrimary,
            body: CustomScrollView(
              slivers: [
                // 앱바
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: colors.textPrimary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        // TODO(PROD): 신고/차단 기능
                      },
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SajuSpacing.space24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // ---- 블러 사진 + 캐릭터 오버레이 ----
                        _BlurredPhotoSection(
                          profile: profile,
                          elementColor: elementColor,
                          elementPastel: elementPastel,
                        ),

                        const SizedBox(height: 24),

                        // ---- 이름 + 나이 + 오행 뱃지 ----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${profile.name}, ${profile.age}',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SajuBadge(
                              label: _elementLabel(profile.elementType),
                              color: _toSajuColor(profile.elementType),
                              size: SajuSize.sm,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ---- 자기소개 ----
                        Text(
                          profile.bio,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // ---- 궁합 점수 섹션 ----
                        Text(
                          '궁합 점수',
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CompatibilityGauge(
                          score: profile.compatibilityScore,
                          size: 120,
                          strokeWidth: 8,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _scoreComment(profile.compatibilityScore),
                          style: textTheme.bodySmall?.copyWith(
                            color: scoreColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ---- 액션 버튼 ----
                        SajuButton(
                          label: '좋아요 보내기',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${profile.name}님에게 좋아요를 보냈어요',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          variant: SajuVariant.filled,
                          color: SajuColor.primary,
                          size: SajuSize.lg,
                          leadingIcon: Icons.favorite_rounded,
                        ),

                        const SizedBox(height: 12),

                        SajuButton(
                          label: '상세 궁합 보기',
                          onPressed: () =>
                              showCompatibilityPreview(context, ref, profile),
                          variant: SajuVariant.ghost,
                          color: SajuColor.primary,
                          size: SajuSize.md,
                          leadingIcon: Icons.auto_awesome,
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _elementLabel(String type) {
    return switch (type) {
      'wood' => '목(木)',
      'fire' => '화(火)',
      'earth' => '토(土)',
      'metal' => '금(金)',
      'water' => '수(水)',
      _ => type,
    };
  }

  static SajuColor _toSajuColor(String type) {
    return switch (type) {
      'wood' => SajuColor.wood,
      'fire' => SajuColor.fire,
      'earth' => SajuColor.earth,
      'metal' => SajuColor.metal,
      'water' => SajuColor.water,
      _ => SajuColor.primary,
    };
  }

  static String _scoreComment(int score) {
    return switch (score) {
      >= 90 => '천생연분! 운명적인 인연이에요',
      >= 75 => '아주 좋은 궁합이에요',
      >= 60 => '함께하면 좋은 케미가 있어요',
      >= 40 => '노력하면 좋은 관계가 될 수 있어요',
      _ => '서로 다른 매력을 발견할 수 있어요',
    };
  }
}

// =============================================================================
// 블러 사진 + 캐릭터 오버레이
// =============================================================================

class _BlurredPhotoSection extends StatelessWidget {
  const _BlurredPhotoSection({
    required this.profile,
    required this.elementColor,
    required this.elementPastel,
  });

  final MatchProfile profile;
  final Color elementColor;
  final Color elementPastel;

  @override
  Widget build(BuildContext context) {
    final colors = context.sajuColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 320,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: colors.borderDefault,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경: 블러 사진 or 그라데이션 플레이스홀더
          if (profile.photoUrl != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Image.network(
                profile.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _gradientPlaceholder(),
              ),
            )
          else
            _gradientPlaceholder(),

          // 어둡게 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          // 캐릭터 아바타 (센터)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 캐릭터 원형
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: elementPastel.withValues(alpha: 0.3),
                    border: Border.all(
                      color: elementColor.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: profile.characterAssetPath != null
                        ? Image.asset(
                            profile.characterAssetPath!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _characterFallback(),
                          )
                        : _characterFallback(),
                  ),
                ),
                const SizedBox(height: 8),
                // 캐릭터 이름
                Text(
                  profile.characterName,
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 하단 잠금 안내
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  '좋아요하면 사진이 공개돼요',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // 궁합 점수 뱃지 (우상단)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.compatibilityColor(profile.compatibilityScore)
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '${profile.compatibilityScore}%',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementPastel.withValues(alpha: 0.4),
            elementPastel.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }

  Widget _characterFallback() {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 36,
        color: elementColor.withValues(alpha: 0.3),
      ),
    );
  }
}
