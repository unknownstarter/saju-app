import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../matching/data/models/match_profile_model.dart';
import '../../../matching/presentation/pages/compatibility_preview_page.dart';
import '../../../matching/presentation/providers/matching_provider.dart';

/// HomePage -- 홈 탭 메인 화면
///
/// 라이트(캐주얼) 모드로 표시되며, 오늘의 추천 매칭, 받은 좋아요,
/// 캐릭터 인사말과 오늘의 사주 한마디를 보여준다.
/// AppBar 없이 클린한 레이아웃을 사용한다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(dailyRecommendationsProvider);
    final receivedLikes = ref.watch(receivedLikesProvider);

    return Theme(
      data: AppTheme.light,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.light.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacingSm),

                    // ---- 1. 캐릭터 인사 섹션 ----
                    const SajuCharacterBubble(
                      characterName: '나무리',
                      message: '안녕! 오늘의 운명적 인연을 찾아봐~',
                      elementColor: SajuColor.wood,
                      characterAssetPath:
                          'assets/images/characters/wood_happy.png',
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // ---- 2. 오늘의 추천 매칭 섹션 ----
                    _SectionTitle(
                      title: '오늘의 추천',
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    recommendations.when(
                      loading: () => const SizedBox(
                        height: 280,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, _) => SizedBox(
                        height: 280,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                '추천을 불러오지 못했어요',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (profiles) => _RecommendationList(
                        profiles: profiles,
                        ref: ref,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // ---- 3. 나를 좋아한 사람 섹션 ----
                    _SectionTitle(
                      title: '나를 좋아한 사람',
                      icon: Icons.favorite_rounded,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    receivedLikes.when(
                      loading: () => const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (likes) => _ReceivedLikesCard(count: likes.length),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // ---- 4. 오늘의 사주 한마디 ----
                    _SectionTitle(
                      title: '오늘의 사주 한마디',
                      icon: Icons.stars_rounded,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    const SajuCharacterBubble(
                      characterName: '물결이',
                      message: '오늘은 새로운 인연이 다가올 기운이 느껴져요.\n'
                          '마음을 열고 자연스럽게 대화해보세요.',
                      elementColor: SajuColor.water,
                      characterAssetPath:
                          'assets/images/characters/water_happy.png',
                    ),

                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 섹션 타이틀
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.mysticGlow,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

// =============================================================================
// 추천 매칭 가로 스크롤 리스트
// =============================================================================

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({
    required this.profiles,
    required this.ref,
  });

  final List<MatchProfile> profiles;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            '아직 추천이 준비되지 않았어요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppTheme.spacingSm),
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return SajuMatchCard(
            name: profile.name,
            age: profile.age,
            bio: profile.bio,
            photoUrl: profile.photoUrl,
            characterName: profile.characterName,
            characterAssetPath: profile.characterAssetPath,
            elementType: profile.elementType,
            compatibilityScore: profile.compatibilityScore,
            width: 200,
            height: 280,
            onTap: () => showCompatibilityPreview(context, ref, profile),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 받은 좋아요 카드 (블러 처리된 아이콘 그리드)
// =============================================================================

class _ReceivedLikesCard extends StatelessWidget {
  const _ReceivedLikesCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SajuCard(
      variant: SajuVariant.elevated,
      content: Row(
        children: [
          // 블러 처리된 아이콘들
          Expanded(
            child: Row(
              children: List.generate(
                count.clamp(0, 4),
                (index) => Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingXs),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.firePastel,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 20,
                      color: AppTheme.fireColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 카운트 텍스트
          Text(
            '$count명이 나를 좋아해요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.fireColor,
                ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.fireColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
