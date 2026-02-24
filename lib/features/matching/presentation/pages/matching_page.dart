import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/match_profile_model.dart';
import '../providers/matching_provider.dart';
import 'compatibility_preview_page.dart';

/// MatchingPage -- 매칭 탭 메인 화면
///
/// 오행 필터 칩과 프로필 그리드를 보여주는 매칭 탐색 화면.
/// 필터링으로 특정 오행 타입의 프로필만 볼 수 있다.
class MatchingPage extends ConsumerStatefulWidget {
  const MatchingPage({super.key});

  @override
  ConsumerState<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends ConsumerState<MatchingPage> {
  /// 선택된 오행 필터 (null = 전체)
  String? _selectedFilter;

  /// 필터 옵션 목록
  static const _filterOptions = [
    _FilterOption(label: '전체', value: null),
    _FilterOption(label: '목(木)', value: 'wood', color: SajuColor.wood),
    _FilterOption(label: '화(火)', value: 'fire', color: SajuColor.fire),
    _FilterOption(label: '토(土)', value: 'earth', color: SajuColor.earth),
    _FilterOption(label: '금(金)', value: 'metal', color: SajuColor.metal),
    _FilterOption(label: '수(水)', value: 'water', color: SajuColor.water),
  ];

  @override
  Widget build(BuildContext context) {
    final recommendations = ref.watch(dailyRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭'),
      ),
      body: Column(
        children: [
          // ---- 1. 오행 필터 칩 행 ----
          _buildFilterChips(context),

          // ---- 2. 프로필 그리드 ----
          Expanded(
            child: recommendations.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      '프로필을 불러오지 못했어요',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(dailyRecommendationsProvider.notifier)
                            .refresh();
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              data: (profiles) {
                final filtered = _selectedFilter == null
                    ? profiles
                    : profiles
                        .where((p) => p.elementType == _selectedFilter)
                        .toList();
                return _buildProfileGrid(context, filtered);
              },
            ),
          ),

          // ---- 3. 하단 무료 좋아요 카운터 ----
          _buildLikeCounter(context),
        ],
      ),
    );
  }

  /// 오행 필터 칩 가로 스크롤 행
  Widget _buildFilterChips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((option) {
            final isSelected = _selectedFilter == option.value;
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: SajuChip(
                label: option.label,
                color: option.color,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedFilter = option.value;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 프로필 2열 그리드
  Widget _buildProfileGrid(BuildContext context, List<MatchProfile> profiles) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '해당 오행의 프로필이 없어요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: profiles.length,
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
          onTap: () => showCompatibilityPreview(context, ref, profile),
        );
      },
    );
  }

  /// 하단 무료 좋아요 카운터 바
  Widget _buildLikeCounter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 16,
              color: AppTheme.fireColor,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              '오늘 무료 좋아요: 3/3회 남음',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 필터 옵션 데이터 클래스
// =============================================================================

class _FilterOption {
  const _FilterOption({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String? value;
  final SajuColor? color;
}
