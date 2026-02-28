# 홈 화면 & UX 리디자인 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 홈 화면을 추천 이성 중심 2열 그리드로 리디자인하고, 온보딩 문구를 해요체+위트로 개선한다.

**Architecture:** 기존 home_page.dart의 섹션을 교체하고, SajuMatchCard에 캐릭터 전용 모드를 추가. 프로필 상세 페이지를 신규 생성하여 블러 사진 + 궁합 분석을 풀스크린으로 표시. 온보딩/분석 페이지의 텍스트 문구를 일괄 교체.

**Tech Stack:** Flutter, Riverpod, go_router, 기존 디자인 토큰(SajuColors/Typography/Animation)

**설계 문서:** `docs/plans/2026-02-28-home-ux-redesign-design.md`

---

## Phase 1: 온보딩 문구 개선 (텍스트만 교체, 위험도 최저)

### Task 1: 로그인 페이지 카피 변경

**Files:**
- Modify: `lib/features/auth/presentation/pages/login_page.dart:203,218`

**Step 1: 문구 교체**

라인 203:
```dart
// before:
'사주가 이끄는\n운명적 만남',
// after:
'사주가 알고 있는\n나의 인연',
```

라인 218:
```dart
// before:
'당신의 사주팔자로 찾는, 진짜 인연',
// after:
'조상님 덕에 쌓인 사주 데이터, AI가 풀어드려요',
```

**Step 2: 빌드 검증**

Run: `cd /Users/noah/momo && flutter analyze lib/features/auth/presentation/pages/login_page.dart`

**Step 3: Commit**

```bash
git add lib/features/auth/presentation/pages/login_page.dart
git commit -m "copy: 로그인 페이지 카피 개선 — 해요체+위트"
```

---

### Task 2: 온보딩 인트로 슬라이드 문구 변경

**Files:**
- Modify: `lib/features/auth/presentation/pages/onboarding_page.dart:45-58`

**Step 1: 슬라이드 2, 3 문구 교체**

라인 51-52 (슬라이드 2):
```dart
// before:
title: '3분이면 완성되는\n나만의 운명 프로필',
subtitle: 'AI가 사주 해석부터 동물상까지 알려드려요',
// after:
title: '3분이면 알 수 있는\n나의 연애 사주',
subtitle: '조상님 덕에 쌓인 사주, AI가 풀어드려요',
```

라인 57-58 (슬라이드 3):
```dart
// before:
title: '사주 궁합으로 만나는\n운명적 인연',
subtitle: '4,000년 동양 지혜 × AI 매칭',
// after:
title: '사주 궁합이 좋은 사람,\n먼저 만나볼래요?',
subtitle: '수천 년 이어진 인연의 지혜가 여기 있어요',
```

**Step 2: Commit**

```bash
git add lib/features/auth/presentation/pages/onboarding_page.dart
git commit -m "copy: 온보딩 인트로 슬라이드 문구 개선 — 30대 타겟 톤"
```

---

### Task 3: 온보딩 폼 캐릭터 대사 해요체 통일

**Files:**
- Modify: `lib/features/auth/presentation/pages/onboarding_form_page.dart:367,410,465,521,682,840`

**Step 1: 6개 대사 교체**

| 라인 | before | after |
|------|--------|-------|
| 367 | `'반가워! 이름이 뭐야~?'` | `'반가워요! 이름이 어떻게 돼요~?'` |
| 410 | `'$displayName, 성별을 알려줘!'` | `'$displayName 반가워요! 성별도 알려주실래요?'` |
| 465 | `'태어난 날짜를 알려줘~'` | `'태어난 날을 알려주면 사주를 펼쳐볼게요!'` |
| 521 | `'태어난 시간까지 알면 더 정확해져!\n몰라도 괜찮아~'` | `'태어난 시간까지 알면 훨씬 정확해져요!\n몰라도 전혀 괜찮아요~'` |
| 682 | `'당신의 얼굴에 어떤 동물이 숨어있을까?\n정면 사진 한 장이면 충분해!'` | `'얼굴에 숨은 동물상이 궁금하지 않아요?\n셀카 한 장이면 충분해요!'` |
| 840 | `'좋아! 이제 사주와 관상을 함께 분석해볼까?'` | `'좋아요! 이제 조상님의 지혜를 빌려볼게요~'` |

**Step 2: Commit**

```bash
git add lib/features/auth/presentation/pages/onboarding_form_page.dart
git commit -m "copy: 온보딩 폼 캐릭터 대사 해요체+위트 통일"
```

---

### Task 4: 분석 로딩 페이즈 문구 위트 강화

**Files:**
- Modify: `lib/features/destiny/presentation/pages/destiny_analysis_page.dart:36-40`

**Step 1: 5개 페이즈 문구 교체**

```dart
// before (lines 36-40):
_Phase('사주팔자를 풀어보고 있어요', '생년월일시를 바탕으로 사주를 계산해요'),
_Phase('오행의 기운을 읽고 있어요', '목·화·토·금·수의 균형을 살펴봐요'),
_Phase('당신의 관상을 분석하고 있어요', '얼굴의 이목구비 비율을 측정해요'),
_Phase('닮은 동물상을 찾고 있어요', '10가지 동물상 중 가장 닮은 상을 찾아요'),
_Phase('운명을 정리하고 있어요', '사주와 관상을 하나로 통합해요'),

// after:
_Phase('사주팔자를 한 자 한 자 풀고 있어요', '4,000년 된 비밀 노트를 꺼내는 중...'),
_Phase('목·화·토·금·수, 어디에 힘이 실렸을까요?', '오행의 균형을 저울질하고 있어요'),
_Phase('얼굴에서 복(福)의 기운을 찾고 있어요', '조상님이 물려주신 복을 읽는 중이에요'),
_Phase('숨어있던 동물상이 슬슬 보여요...!', '여우? 곰? 고양이? 두근두근...'),
_Phase('드디어 퍼즐이 맞춰지고 있어요!', '사주 × 관상, 운명의 그림이 완성돼요'),
```

**Step 2: Commit**

```bash
git add lib/features/destiny/presentation/pages/destiny_analysis_page.dart
git commit -m "copy: 분석 로딩 페이즈 문구 위트 강화"
```

---

### Task 5: 결과 페이지 CTA 문구 변경

**Files:**
- Modify: `lib/features/destiny/presentation/pages/destiny_result_page.dart:373`
- Modify: `lib/features/saju/presentation/pages/saju_result_page.dart:375`

**Step 1: CTA 라벨 교체 (2 파일)**

```dart
// before:
label: '운명의 인연 찾으러 가기',
// after:
label: '내 사주와 찰떡인 사람, 만나볼까요?',
```

**Step 2: Commit**

```bash
git add lib/features/destiny/presentation/pages/destiny_result_page.dart lib/features/saju/presentation/pages/saju_result_page.dart
git commit -m "copy: 결과 페이지 CTA — '내 사주와 찰떡인 사람, 만나볼까요?'"
```

---

## Phase 2: SajuMatchCard v2 (캐릭터 모드 추가)

### Task 6: SajuMatchCard에 showCharacterInstead 파라미터 추가

**Files:**
- Modify: `lib/core/widgets/saju_match_card.dart`

**Step 1: 파라미터 추가**

생성자(line 51-67)에 추가:
```dart
this.showCharacterInstead = false,
this.isNew = false,
```

필드 선언(line 69-82)에 추가:
```dart
final bool showCharacterInstead;
final bool isNew;
```

**Step 2: _buildPhotoArea 분기 수정**

`_buildPhotoArea` 메서드(line 170)를 수정하여, `showCharacterInstead == true`이면 항상 placeholder(캐릭터)를 표시:

```dart
Widget _buildPhotoArea(Color elementColor, Color elementPastel, bool isDark) {
  return Stack(
    fit: StackFit.expand,
    children: [
      // Photo or character placeholder
      (widget.showCharacterInstead || widget.photoUrl == null)
          ? _buildPlaceholder(elementColor, elementPastel)
          : Image.network(
              widget.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildPlaceholder(elementColor, elementPastel),
            ),
      // Element badge (top-left)
      Positioned(
        top: SajuSpacing.space8,
        left: SajuSpacing.space8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                _elementLabel(widget.elementType),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: elementColor,
                ),
              ),
            ),
            if (widget.isNew) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.fireColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      // Score badge (top-right) — 기존 코드 유지
      Positioned(
        top: SajuSpacing.space8,
        right: SajuSpacing.space8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.compatibilityColor(widget.compatibilityScore).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(
            '${widget.compatibilityScore}%',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
```

**Step 3: 빌드 검증**

Run: `flutter analyze lib/core/widgets/saju_match_card.dart`

**Step 4: Commit**

```bash
git add lib/core/widgets/saju_match_card.dart
git commit -m "feat: SajuMatchCard v2 — showCharacterInstead + isNew 뱃지"
```

---

## Phase 3: 홈 화면 리디자인

### Task 7: 홈 페이지 섹션 재구성 (오늘의 연애운 + 2열 그리드 + 동물상)

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart` (전체 재구성)

**Step 1: 홈 build 메서드 — 섹션 순서 변경**

`build` 메서드(line 24-198)의 children 배열을 다음으로 교체:

```dart
children: [
  const SizedBox(height: 20),

  // ---- 1. 인사 + 캐릭터 (기존 유지) ----
  _FadeSlideSection(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 인연을\n만나봐요',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '사주가 이끄는 운명적 만남',
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            CharacterAssets.namuriWoodDefault,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 24),

  // ---- 2. 오늘의 연애운 (신설) ----
  _FadeSlideSection(
    delay: const Duration(milliseconds: 100),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const _DailyLoveFortuneCard(),
    ),
  ),

  const SizedBox(height: 32),

  // ---- 3. 궁합 매칭 추천 2열 그리드 (핵심) ----
  _FadeSlideSection(
    delay: const Duration(milliseconds: 200),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '궁합 매칭 추천 이성',
                style: textTheme.titleLarge,
              ),
              GestureDetector(
                onTap: () => context.go(RoutePaths.matching),
                child: Text(
                  '더보기',
                  style: textTheme.bodySmall?.copyWith(
                    color: textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        recommendations.when(
          loading: () => _buildGridSkeleton(context),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _EmptyState(
              message: '추천을 불러오지 못했어요',
              height: 200,
            ),
          ),
          data: (profiles) => _RecommendationGrid(
            profiles: profiles,
            ref: ref,
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 28),

  // ---- 4. 받은 좋아요 ----
  _FadeSlideSection(
    delay: const Duration(milliseconds: 300),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('받은 좋아요', style: textTheme.titleLarge),
              const SizedBox(width: 8),
              receivedLikes.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (likes) => likes.isNotEmpty
                    ? Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppTheme.fireColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${likes.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          receivedLikes.when(
            loading: () => Container(
              height: 64,
              decoration: BoxDecoration(
                color: context.sajuColors.bgSecondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (likes) =>
                _ReceivedLikesCard(count: likes.length),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 28),

  // ---- 5. 동물상 매칭 (관상 넛지 대체) ----
  _FadeSlideSection(
    delay: const Duration(milliseconds: 400),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const _AnimalMatchSection(),
    ),
  ),

  // 플로팅 네비바 뒤 여백
  SizedBox(height: MediaQuery.of(context).padding.bottom + 88),
],
```

**Step 2: _RecommendationGrid 위젯 (기존 _RecommendationList 대체)**

기존 `_RecommendationList`(line 205-248) 제거 후 대체:

```dart
class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid({
    required this.profiles,
    required this.ref,
  });

  final List<MatchProfile> profiles;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyState(
          message: '아직 추천이 준비되지 않았어요',
          height: 200,
        ),
      );
    }

    final displayProfiles = profiles.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemCount: displayProfiles.length,
        itemBuilder: (context, index) {
          final profile = displayProfiles[index];
          return SajuMatchCard(
            name: profile.name,
            age: profile.age,
            bio: profile.bio,
            photoUrl: profile.photoUrl,
            characterName: profile.characterName,
            characterAssetPath: profile.characterAssetPath,
            elementType: profile.elementType,
            compatibilityScore: profile.compatibilityScore,
            showCharacterInstead: true,
            onTap: () => showCompatibilityPreview(context, ref, profile),
          );
        },
      ),
    );
  }
}
```

**Step 3: _buildGridSkeleton 헬퍼**

```dart
Widget _buildGridSkeleton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: 4,
      itemBuilder: (_, _) => const SkeletonCard(),
    ),
  );
}
```

**Step 4: _DailyLoveFortuneCard 위젯 (기존 _FortuneCard 대체)**

기존 `_FortuneCard`(line 327-403)와 `_GwansangNudgeBanner`(line 409-465) 제거 후 대체:

```dart
class _DailyLoveFortuneCard extends StatelessWidget {
  const _DailyLoveFortuneCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.sajuColors;
    // TODO(PROD): 유저 오행에 따라 동적으로 변경
    const elementColor = AppTheme.woodColor;
    const elementPastel = AppTheme.woodPastel;
    final characterAssetPath = CharacterAssets.namuriWoodDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘의 연애운', style: textTheme.titleLarge),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.bgElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 캐릭터 + 라벨
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: elementPastel.withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: Image.asset(
                        characterAssetPath,
                        width: 28,
                        height: 28,
                        errorBuilder: (_, _, _) => const Text('🌳',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '나무리의 연애운',
                    style: textTheme.titleSmall?.copyWith(
                      color: elementColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 에너지 바
              Row(
                children: [
                  Text('💘', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '연애 에너지',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.82,
                        minHeight: 6,
                        backgroundColor: colors.bgSecondary,
                        valueColor: const AlwaysStoppedAnimation(elementColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '82%',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 운세 메시지
              Text(
                '오늘은 목(木)의 생기가 강해요.\n자연스러운 대화가 좋은 인연으로 이어질 수 있는 날이에요.',
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colors.textPrimary.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              // 하단 칩
              Row(
                children: [
                  _FortuneChip(
                    icon: '🌊',
                    label: '상생 오행',
                    value: '수(水)',
                    color: elementColor,
                    pastel: elementPastel,
                  ),
                  const SizedBox(width: 8),
                  _FortuneChip(
                    icon: '❤️',
                    label: '추천 행동',
                    value: '산책 데이트',
                    color: elementColor,
                    pastel: elementPastel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FortuneChip extends StatelessWidget {
  const _FortuneChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.pastel,
  });

  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color pastel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: pastel.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: context.sajuColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**Step 5: _AnimalMatchSection 위젯 (관상 넛지 대체)**

```dart
class _AnimalMatchSection extends StatelessWidget {
  const _AnimalMatchSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.sajuColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('동물상 매칭', style: textTheme.titleLarge),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => context.go(RoutePaths.matching),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.firePastel.withValues(alpha: 0.25),
                  AppTheme.waterPastel.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: colors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.firePastel.withValues(alpha: 0.4),
                      ),
                      child: const Center(
                        child: Text('🦊',
                            style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나는 여우상',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '본능적으로 분위기를 읽는 매력가',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '여우상과 찰떡인 동물상',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _AnimalChip(emoji: '🐻', label: '곰상', count: 3),
                    const SizedBox(width: 12),
                    _AnimalChip(emoji: '🐱', label: '고양이상', count: 5),
                    const SizedBox(width: 12),
                    _AnimalChip(emoji: '🐰', label: '토끼상', count: 2),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '동물상 매칭 보러가기',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimalChip extends StatelessWidget {
  const _AnimalChip({
    required this.emoji,
    required this.label,
    required this.count,
  });

  final String emoji;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: textTheme.labelSmall),
        Text(
          '$count명',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: context.sajuColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
```

**Step 6: 빌드 검증**

Run: `flutter analyze lib/features/home/`

**Step 7: Commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: 홈 화면 리디자인 — 2열 그리드 + 연애운 + 동물상 매칭"
```

---

## Phase 4: 프로필 상세 페이지 (블러 사진)

### Task 8: ProfileDetailPage 신규 생성

**Files:**
- Create: `lib/features/matching/presentation/pages/profile_detail_page.dart`

프로필 상세 풀스크린 페이지. 블러 사진 + 캐릭터 오버레이 + 궁합 게이지 + 좋아요 CTA.
기존 `CompatibilityPreviewPage`의 궁합 표시 로직을 참고하되, 풀스크린 다크 모드로 구현.

핵심 구성:
- `Scaffold(backgroundColor: #1D1E23)` 다크 모드 강제
- `CustomScrollView` with slivers
- 블러 사진 영역: `ImageFilter.blur(sigmaX: 25, sigmaY: 25)` + 캐릭터 80x80 오버레이
- 궁합 섹션: `CompatibilityGauge(size: 100, strokeWidth: 6)`
- 하단 고정 CTA: "좋아요 보내기" + "좋아요하면 사진이 공개돼요"

**이 Task의 상세 코드는 설계 문서 §5를 참조하여 구현.**

**Step 1: 파일 생성 & 빌드 검증**
**Step 2: Commit**

```bash
git add lib/features/matching/presentation/pages/profile_detail_page.dart
git commit -m "feat: 프로필 상세 페이지 — 블러 사진 + 궁합 + 좋아요 CTA"
```

---

### Task 9: 라우트 등록 + 홈에서 상세 페이지로 연결

**Files:**
- Modify: `lib/core/constants/app_constants.dart` — RoutePaths에 `profileDetail` 추가
- Modify: `lib/app/routes/app_router.dart` — GoRoute 등록
- Modify: `lib/features/home/presentation/pages/home_page.dart` — onTap에서 상세 페이지로 push

**Step 1: RoutePaths 상수 추가**

```dart
static const profileDetail = '/profile-detail';
```

**Step 2: GoRoute 등록 (standalone page)**

```dart
GoRoute(
  path: RoutePaths.profileDetail,
  name: 'profileDetail',
  builder: (context, state) {
    final profile = state.extra as MatchProfile;
    return ProfileDetailPage(profile: profile);
  },
),
```

**Step 3: 홈 그리드 onTap 변경**

```dart
// before:
onTap: () => showCompatibilityPreview(context, ref, profile),
// after:
onTap: () => context.push(RoutePaths.profileDetail, extra: profile),
```

**Step 4: Commit**

```bash
git add lib/core/constants/app_constants.dart lib/app/routes/app_router.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: 프로필 상세 라우트 등록 + 홈 카드 탭 → 상세 페이지"
```

---

## Phase 5: 통합 검증

### Task 10: flutter analyze + 빌드 검증

**Step 1: 정적 분석**

Run: `flutter analyze`
Expected: 기존 이슈와 동일 수준 (28개), 신규 에러 0개

**Step 2: iOS 빌드 검증**

Run: `flutter build ios --debug --no-codesign 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: 최종 Commit (있다면)**

```bash
git commit -m "chore: 홈 UX 리디자인 통합 검증 완료"
```

---

## 태스크 의존성 그래프

```
Phase 1 (문구): Task 1 ─┐
                Task 2 ─┤→ 독립 실행 가능 (텍스트만)
                Task 3 ─┤
                Task 4 ─┤
                Task 5 ─┘

Phase 2 (카드): Task 6 ─→ Phase 3에 의존됨

Phase 3 (홈):   Task 7 ─→ Task 6 필요

Phase 4 (상세): Task 8 ─→ Task 9 ─→ Task 7 필요

Phase 5 (검증): Task 10 ─→ 전체 완료 후
```

**병렬 가능**: Phase 1의 Task 1~5는 모두 독립, Phase 2-3은 순차.

---

## 산출물 요약

| # | Phase | 변경 파일 | 신규 파일 |
|---|-------|----------|----------|
| 1-5 | 문구 개선 | 5개 (login, onboarding x2, destiny x2) | 0 |
| 6 | 카드 v2 | 1개 (saju_match_card.dart) | 0 |
| 7 | 홈 리디자인 | 1개 (home_page.dart) | 0 |
| 8-9 | 상세 페이지 | 2개 (app_constants, app_router) | 1개 (profile_detail_page.dart) |
| 10 | 검증 | 0 | 0 |
| **합계** | | **9개 수정** | **1개 신규** |
