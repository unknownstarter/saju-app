import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../saju/domain/entities/saju_entity.dart';
import '../../data/models/match_profile_model.dart';
import '../providers/matching_provider.dart';

/// CompatibilityPreviewPage -- 궁합 프리뷰 모달 바텀시트
///
/// 다크(신비) 모드로 표시되며, 두 캐릭터의 궁합 게이지, 강점/도전,
/// 좋아요 보내기 버튼을 보여준다.
/// [showCompatibilityPreview]로 모달 바텀시트 형태로 호출한다.
class CompatibilityPreviewPage extends ConsumerWidget {
  const CompatibilityPreviewPage({
    super.key,
    required this.partnerId,
    required this.partnerProfile,
    required this.scrollController,
  });

  /// 상대방 사용자 ID
  final String partnerId;

  /// 상대방 프로필 정보
  final MatchProfile partnerProfile;

  /// DraggableScrollableSheet의 스크롤 컨트롤러
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compatibilityAsync = ref.watch(compatibilityPreviewProvider);

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1D1E23), // 먹색 배경
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spacingSm),

                  // ---- 1. 드래그 핸들 바 ----
                  _buildDragHandle(),

                  const SizedBox(height: AppTheme.spacingLg),

                  // ---- 2. 두 캐릭터 나란히 ----
                  _buildCharacterRow(context),

                  const SizedBox(height: AppTheme.spacingLg),

                  // ---- 3. 궁합 게이지 + 분석 결과 ----
                  compatibilityAsync.when(
                    loading: () => const SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.mysticGlow,
                            ),
                            SizedBox(height: AppTheme.spacingMd),
                            Text(
                              '궁합을 분석하고 있어요...',
                              style: TextStyle(
                                color: Color(0xFFA09B94),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (_, _) => SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Color(0xFF6B6B6B),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              '궁합 분석에 실패했어요',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (compatibility) {
                      if (compatibility == null) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.mysticGlow,
                            ),
                          ),
                        );
                      }
                      return _buildCompatibilityResult(
                        context,
                        compatibility,
                      );
                    },
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  // ---- 4. 액션 버튼들 ----
                  _buildActionButtons(context),

                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 드래그 핸들 바
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 두 캐릭터 나란히 배치 (내 캐릭터 + 하트 + 상대 캐릭터)
  Widget _buildCharacterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 내 캐릭터
        _buildCharacterCircle(
          context,
          label: '나',
          characterName: '나무리',
          assetPath: 'assets/images/characters/wood_happy.png',
          elementColor: AppTheme.woodColor,
          pastelColor: AppTheme.woodPastel,
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // 하트 아이콘
        Column(
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 28,
              color: AppTheme.mysticGlow.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 4),
            Text(
              'VS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // 상대 캐릭터
        _buildCharacterCircle(
          context,
          label: partnerProfile.name,
          characterName: partnerProfile.characterName,
          assetPath: partnerProfile.characterAssetPath,
          elementColor: AppTheme.fiveElementColor(partnerProfile.elementType),
          pastelColor: AppTheme.fiveElementPastel(partnerProfile.elementType),
        ),
      ],
    );
  }

  /// 캐릭터 원형 아바타 + 이름 라벨
  Widget _buildCharacterCircle(
    BuildContext context, {
    required String label,
    required String characterName,
    String? assetPath,
    required Color elementColor,
    required Color pastelColor,
  }) {
    const dimension = 72.0;
    final firstChar = characterName.characters.first;

    return Column(
      children: [
        Container(
          width: dimension,
          height: dimension,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pastelColor.withValues(alpha: 0.3),
            border: Border.all(
              color: elementColor.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: assetPath != null
                ? Image.asset(
                    assetPath,
                    width: dimension,
                    height: dimension,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        firstChar,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: elementColor,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      firstChar,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: elementColor,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// 궁합 결과: 게이지 + 강점 + 도전
  Widget _buildCompatibilityResult(
    BuildContext context,
    Compatibility compatibility,
  ) {
    return Column(
      children: [
        // 궁합 게이지
        CompatibilityGauge(
          score: compatibility.score,
          grade: compatibility.grade,
          size: 140,
          strokeWidth: 10,
        ),

        const SizedBox(height: AppTheme.spacingSm),

        // 등급 설명
        Text(
          compatibility.grade.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // 강점 리스트
        if (compatibility.strengths.isNotEmpty) ...[
          _buildListSection(
            context,
            title: '잘 맞는 점',
            items: compatibility.strengths,
            icon: Icons.check_circle_rounded,
            iconColor: AppTheme.woodColor,
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],

        // 도전 리스트
        if (compatibility.challenges.isNotEmpty)
          _buildListSection(
            context,
            title: '노력이 필요한 점',
            items: compatibility.challenges,
            icon: Icons.info_rounded,
            iconColor: AppTheme.earthColor,
          ),
      ],
    );
  }

  /// 강점/도전 리스트 섹션
  Widget _buildListSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        ...items.take(3).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: iconColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  /// 좋아요 + 상세 보기 버튼들
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 좋아요 보내기 버튼
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 좋아요 보내기 로직 연결
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${partnerProfile.name}님에게 좋아요를 보냈어요!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.favorite_rounded),
            label: const Text('좋아요 보내기'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.fireColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd + 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        // 상세 보기 텍스트 버튼
        TextButton(
          onPressed: () {
            // TODO: 상세 궁합 결제 플로우 연결
          },
          child: Text(
            '500P로 상세 궁합 보기',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.mysticGlow.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 궁합 프리뷰 바텀시트 헬퍼 함수
// =============================================================================

/// 궁합 프리뷰 모달 바텀시트를 표시한다.
///
/// [context]: BuildContext
/// [ref]: WidgetRef (provider 접근용)
/// [profile]: 상대방 MatchProfile
void showCompatibilityPreview(
  BuildContext context,
  WidgetRef ref,
  MatchProfile profile,
) {
  ref.read(compatibilityPreviewProvider.notifier).loadPreview(profile.userId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => CompatibilityPreviewPage(
        partnerId: profile.userId,
        partnerProfile: profile,
        scrollController: scrollController,
      ),
    ),
  );
}
