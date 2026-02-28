/// 관상 결과 페이지 — 동물상 리빌 + 관상학 해석 결과
///
/// **이 앱의 와우 모먼트!** 바이럴의 핵심 포인트.
/// 동물상 리빌 → 매력 키워드 → 삼정(三停) → 오관(五官)
/// → 성격/연애 → traits 5축 → 공유 CTA.
/// 다크 테마(미스틱 모드), 스태거드 페이드인 애니메이션.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/tokens/saju_colors.dart';
import '../../../../core/theme/tokens/saju_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/face_measurements.dart';
import '../../domain/entities/gwansang_entity.dart';
import '../providers/gwansang_provider.dart';

/// 관상 결과 페이지 — 동물상 리빌
class GwansangResultPage extends ConsumerStatefulWidget {
  const GwansangResultPage({super.key, this.result});

  /// 관상 분석 결과 (GoRouter extra)
  final dynamic result;

  @override
  ConsumerState<GwansangResultPage> createState() =>
      _GwansangResultPageState();
}

class _GwansangResultPageState extends ConsumerState<GwansangResultPage> {
  GwansangAnalysisResult? get _analysisResult {
    if (widget.result is GwansangAnalysisResult) {
      return widget.result as GwansangAnalysisResult;
    }
    return null;
  }

  /// mock 데이터 (result가 null일 때 사용)
  GwansangProfile get _profile =>
      _analysisResult?.profile ?? _mockProfile;

  static final _mockProfile = GwansangProfile(
    id: 'mock-id',
    userId: 'mock-user',
    animalType: 'cat',
    animalModifier: '신비로운',
    animalTypeKorean: '고양이',
    measurements: FaceMeasurements.fromJson(const {}),
    photoUrls: const [],
    headline: '타고난 리더형 관상, 눈빛에 결단력이 서려 있어요',
    samjeong: const SamjeongReading(
      upper: '넓은 이마가 총명함과 학업운을 나타내요. 어릴 때부터 주변에서 인정받는 타입이에요.',
      middle: '코의 선이 반듯해 중년에 안정적인 성취를 이룰 상이에요. 사회적 신뢰감이 높아요.',
      lower: '턱선이 부드러워 말년에 화목한 가정을 이루고, 주변의 존경을 받을 상이에요.',
    ),
    ogwan: const OgwanReading(
      eyes: '눈매가 고양이처럼 날카로우면서도 깊이가 있어요. 사람의 마음을 단번에 읽는 직관력이 돋보여요.',
      nose: '코가 오뚝해서 자존심이 강하고, 자기 원칙에 충실한 타입이에요.',
      mouth: '입술이 적당히 도톰해서 표현력이 풍부하고 사교적이에요.',
      ears: '귀가 안정적인 형태로, 타인의 말에 귀 기울이는 경청의 복이 있어요.',
      eyebrows: '눈썹이 깔끔하게 정리된 형태로 의지가 강하고 목표 지향적이에요.',
    ),
    traits: const GwansangTraits(
      leadership: 72,
      warmth: 65,
      independence: 80,
      sensitivity: 58,
      energy: 68,
    ),
    personalitySummary:
        '겉으로는 도도하지만 마음 한 켠에는 따뜻함을 품고 있는 타입이에요. '
        '첫인상은 다가가기 어렵지만, 한번 친해지면 끝없이 매력을 발산하는 스타일이죠. '
        '독립적이고 자기 주관이 뚜렷해서, 주변 사람들에게 신뢰감을 줘요.',
    romanceSummary:
        '연애에서는 밀당의 달인이에요. 쉽게 마음을 열지 않지만, '
        '한번 마음을 주면 깊고 진실한 사랑을 해요. '
        '상대방의 지적인 면에 끌리고, 서로 독립적이면서도 깊은 유대감을 나누는 관계를 선호해요.',
    romanceKeyPoints: const ['밀당의 매력', '지적인 대화를 중시', '독립적이면서도 깊은 유대감'],
    charmKeywords: const ['밀당의 달인', '신비로운 눈빛', '도도한 매력'],
    createdAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          final colors = context.sajuColors;
          final profile = _profile;

          return Scaffold(
            backgroundColor: colors.bgPrimary,
            body: CustomScrollView(
              slivers: [
                // 앱바
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  leading: const SizedBox.shrink(),
                  actions: [
                    IconButton(
                      onPressed: () => context.go(RoutePaths.home),
                      icon: Icon(
                        Icons.close,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // 본문
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SajuSpacing.space24,
                    ),
                    child: _ResultRevealContent(
                      profile: profile,
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
}

// =============================================================================
// 스태거드 리빌 컨테이너
// =============================================================================

class _ResultRevealContent extends StatefulWidget {
  const _ResultRevealContent({required this.profile});

  final GwansangProfile profile;

  @override
  State<_ResultRevealContent> createState() => _ResultRevealContentState();
}

class _ResultRevealContentState extends State<_ResultRevealContent>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1400);
  static const _stagger = 0.12;
  static const _sectionCount = 10;

  late final AnimationController _controller;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    _fades = List.generate(_sectionCount, (i) {
      final start = (i * _stagger).clamp(0.0, 0.85);
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _slides = List.generate(_sectionCount, (i) {
      final start = (i * _stagger).clamp(0.0, 0.85);
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final colors = context.sajuColors;

    final sections = <Widget>[
      // 1. 동물상 히어로 리빌
      _buildAnimalHero(context, profile, colors),
      // 2. 헤드라인
      _buildHeadline(context, profile, colors),
      // 3. 매력 키워드 칩
      _buildCharmKeywords(context, profile),
      // 4. 삼정(三停) — 인생 3막
      _buildSamjeongCard(context, profile, colors),
      // 5. 오관(五官) — 얼굴이 말하는 것
      _buildOgwanCard(context, profile, colors),
      // 6. 성격 요약 카드
      _buildSectionCard(context, '성격', profile.personalitySummary, colors),
      // 7. 연애 스타일 카드
      _buildSectionCard(context, '연애 스타일', profile.romanceSummary, colors),
      // 8. 연애 핵심 포인트
      _buildRomanceKeyPointsCard(context, profile, colors),
      // 9. 성격 traits 5축
      _buildTraitsChart(context, profile, colors),
      // 10. CTA 액션 버튼
      _buildActions(context, profile.photoUrls),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: sections[i],
            ),
          ),
          SizedBox(height: i == 0 ? SajuSpacing.space16 : SajuSpacing.space24),
        ],
        const SizedBox(height: SajuSpacing.space48),
      ],
    );
  }

  // ===========================================================================
  // 1. 동물상 히어로 리빌
  // ===========================================================================

  Widget _buildAnimalHero(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    return Column(
      children: [
        // 글로우 배경 + 동물상 텍스트
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.mysticGlow.withValues(alpha: 0.15),
                AppTheme.mysticGlow.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Center(
            child: Text(
              '${profile.animalTypeKorean}상',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),

        SajuSpacing.gap16,

        // 수식어 + 동물상 라벨
        Text(
          profile.animalLabel,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),

        SajuSpacing.gap8,
      ],
    );
  }

  // ===========================================================================
  // 2. 헤드라인
  // ===========================================================================

  Widget _buildHeadline(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    return Text(
      profile.headline,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
            height: 1.6,
          ),
    );
  }

  // ===========================================================================
  // 3. 매력 키워드
  // ===========================================================================

  Widget _buildCharmKeywords(
    BuildContext context,
    GwansangProfile profile,
  ) {
    const elementColor = SajuColor.primary;

    return Wrap(
      spacing: SajuSpacing.space8,
      runSpacing: SajuSpacing.space8,
      alignment: WrapAlignment.center,
      children: profile.charmKeywords.map((keyword) {
        return SajuChip(
          label: keyword,
          color: elementColor,
          size: SajuSize.sm,
          isSelected: true,
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // 4. 삼정(三停) — 인생 3막
  // ===========================================================================

  Widget _buildSamjeongCard(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    final samjeong = profile.samjeong;
    final zones = [
      ('상정 · 초년운', '이마~눈썹', samjeong.upper, Icons.school_outlined),
      ('중정 · 중년운', '눈썹~코끝', samjeong.middle, Icons.work_outline),
      ('하정 · 말년운', '코끝~턱', samjeong.lower, Icons.home_outlined),
    ];

    return SajuCard(
      variant: SajuVariant.elevated,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.face_outlined, size: 18, color: AppTheme.mysticGlow),
              SajuSpacing.hGap8,
              Text(
                '삼정(三停) — 인생 3막',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SajuSpacing.gap16,
          ...zones.map((zone) {
            final (title, area, reading, icon) = zone;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.mysticGlow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: AppTheme.mysticGlow),
                  ),
                  SajuSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SajuSpacing.hGap8,
                            Text(
                              area,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reading,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. 오관(五官) — 얼굴이 말하는 것
  // ===========================================================================

  Widget _buildOgwanCard(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    final ogwan = profile.ogwan;
    final features = [
      ('눈 · 감찰관', ogwan.eyes, '👁️'),
      ('코 · 심판관', ogwan.nose, '👃'),
      ('입 · 출납관', ogwan.mouth, '👄'),
      ('귀 · 채청관', ogwan.ears, '👂'),
      ('눈썹 · 보수관', ogwan.eyebrows, '✨'),
    ];

    return SajuCard(
      variant: SajuVariant.elevated,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: AppTheme.mysticGlow),
              SajuSpacing.hGap8,
              Text(
                '오관(五官) — 얼굴이 말하는 것',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SajuSpacing.gap16,
          ...features.map((feature) {
            final (title, reading, emoji) = feature;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      SajuSpacing.hGap8,
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mysticGlow,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.6,
                        ),
                  ),
                  if (feature != features.last)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Divider(
                        height: 1,
                        color: colors.textTertiary.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6-7. 섹션 카드 (성격 / 연애 스타일)
  // ===========================================================================

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String body,
    SajuColors colors,
  ) {
    return SajuCard(
      variant: SajuVariant.elevated,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SajuSpacing.gap12,
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.7,
                ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. 연애 핵심 포인트
  // ===========================================================================

  Widget _buildRomanceKeyPointsCard(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    return SajuCard(
      variant: SajuVariant.elevated,
      borderColor: AppTheme.mysticGlow.withValues(alpha: 0.3),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_outlined, size: 18, color: AppTheme.mysticGlow),
              SajuSpacing.hGap8,
              Text(
                '연애 핵심 포인트',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.mysticGlow,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SajuSpacing.gap12,
          ...profile.romanceKeyPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.mysticGlow, fontSize: 14)),
                Expanded(
                  child: Text(
                    point,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.7,
                        ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ===========================================================================
  // 9. 성격 traits 5축
  // ===========================================================================

  Widget _buildTraitsChart(
    BuildContext context,
    GwansangProfile profile,
    SajuColors colors,
  ) {
    final traits = profile.traits;
    final axes = [
      ('리더십', traits.leadership, Icons.military_tech_outlined),
      ('온화함', traits.warmth, Icons.favorite_border),
      ('독립성', traits.independence, Icons.shield_outlined),
      ('감성', traits.sensitivity, Icons.auto_awesome_outlined),
      ('에너지', traits.energy, Icons.bolt_outlined),
    ];

    return SajuCard(
      variant: SajuVariant.elevated,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_outlined, size: 18, color: AppTheme.mysticGlow),
              SajuSpacing.hGap8,
              Text(
                '성격 특성 5축',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SajuSpacing.gap16,
          ...axes.map((axis) {
            final (label, value, icon) = axis;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: colors.textSecondary),
                      SajuSpacing.hGap8,
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '$value',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mysticGlow,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 6,
                      backgroundColor: colors.textTertiary.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.mysticGlow.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 10. 액션 버튼
  // ===========================================================================

  Widget _buildActions(BuildContext context, List<String> photoUrls) {
    return Column(
      children: [
        // 메인 CTA — 홈으로 복귀하여 동물상 케미 확인
        SajuButton(
          label: '동물상 케미 확인하러 가기',
          onPressed: () => context.go(RoutePaths.home),
          variant: SajuVariant.filled,
          color: SajuColor.primary,
          size: SajuSize.lg,
          leadingIcon: Icons.favorite_outlined,
        ),

        SajuSpacing.gap12,

        // 공유
        SajuButton(
          label: '내 관상 공유하기',
          onPressed: () {
            // TODO: 공유 기능 구현
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('공유 기능은 준비 중이에요!')),
            );
          },
          variant: SajuVariant.outlined,
          color: SajuColor.primary,
          size: SajuSize.lg,
          leadingIcon: Icons.share_outlined,
        ),
      ],
    );
  }

}
