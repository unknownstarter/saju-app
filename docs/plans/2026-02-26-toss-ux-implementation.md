# 토스 스타일 UX 리팩토링 — 구현 계획서

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 온보딩 입력 UX를 "양식 작성" → "대화형 한 화면 하나" 패턴으로 전면 리팩토링하여 토스 수준 경험 달성

**Architecture:** 기존 PageView+PageController 패턴 유지, 스텝을 세분화(2→5). 선택형 입력은 0.3초 자동진행, 텍스트형은 버튼 활성화 방식. HapticService로 글로벌 햅틱 피드백, SajuButton/SajuInput에 비활성·흔들림 시각 강화.

**Tech Stack:** Flutter 3.38+, Riverpod 2.x, go_router, flutter/services (HapticFeedback)

**설계 문서:** `docs/plans/2026-02-26-toss-ux-refactoring-design.md`

---

## Task 1: HapticService 생성 — 글로벌 햅틱 피드백

**Files:**
- Create: `lib/core/services/haptic_service.dart`

**핵심:** 모든 인터랙션에 햅틱 피드백을 일관되게 적용하기 위한 중앙 서비스

**Step 1: HapticService 작성**

```dart
import 'package:flutter/services.dart';

/// 글로벌 햅틱 피드백 서비스
///
/// 모든 인터랙션에 일관된 햅틱 피드백을 제공한다.
/// iOS에서는 Taptic Engine, Android에서는 진동 피드백을 사용.
abstract final class HapticService {
  /// 칩/옵션 선택 시 — 가벼운 클릭
  static void selection() => HapticFeedback.selectionClick();

  /// 자동 진행, 버튼 활성화 시 — 가벼운 임팩트
  static void light() => HapticFeedback.lightImpact();

  /// CTA 탭, 중요 액션 시 — 중간 임팩트
  static void medium() => HapticFeedback.mediumImpact();

  /// 에러 발생 시 — 강한 임팩트
  static void error() => HapticFeedback.heavyImpact();

  /// 성공/축하 시 — 가벼운 임팩트
  static void success() => HapticFeedback.lightImpact();
}
```

**Step 2: Commit**

```bash
git add lib/core/services/haptic_service.dart
git commit -m "feat: HapticService — 글로벌 햅틱 피드백 서비스"
```

---

## Task 2: SajuButton 비활성 시각 상태 강화

**Files:**
- Modify: `lib/core/widgets/saju_button.dart`

**핵심:** `onPressed: null`일 때 기존 Flutter 기본 비활성 스타일(거의 변화 없음) → 명확한 시각적 비활성 (opacity 0.4, 배경색 회색화)

**Step 1: _buildButtonStyle에 disabledBackgroundColor / disabledForegroundColor 추가**

`SajuAnimation.disabledOpacity` (0.4) 토큰을 활용하여:

filled variant:
```dart
disabledBackgroundColor: resolvedColor.withValues(alpha: SajuAnimation.disabledOpacity),
disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
```

outlined variant:
```dart
disabledForegroundColor: resolvedColor.withValues(alpha: SajuAnimation.disabledOpacity),
```

ghost/flat variant:
```dart
disabledForegroundColor: resolvedColor.withValues(alpha: SajuAnimation.disabledOpacity),
```

**Step 2: Commit**

```bash
git add lib/core/widgets/saju_button.dart
git commit -m "feat: SajuButton 비활성 시각 상태 강화 (opacity 0.4)"
```

---

## Task 3: SajuInput 에러 시 흔들림(shake) 애니메이션

**Files:**
- Modify: `lib/core/widgets/saju_input.dart`

**핵심:** `errorText`가 non-null로 바뀔 때 필드가 좌우 1회 흔들리는 shake 애니메이션. AnimationController 기반.

**Step 1: StatelessWidget → StatefulWidget 변환**

SajuInput을 StatefulWidget으로 변환하여 AnimationController를 사용할 수 있게 한다.

**Step 2: shake AnimationController 추가**

```dart
late final AnimationController _shakeController;
late final Animation<double> _shakeAnimation;

@override
void initState() {
  super.initState();
  _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  // -6px ~ +6px 좌우 흔들림 (2번 진동)
  _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
  ]).animate(CurvedAnimation(
    parent: _shakeController,
    curve: Curves.easeInOut,
  ));
}
```

**Step 3: didUpdateWidget에서 errorText 변화 감지**

```dart
@override
void didUpdateWidget(covariant SajuInput oldWidget) {
  super.didUpdateWidget(oldWidget);
  // errorText가 null → non-null로 바뀔 때만 shake 실행
  if (widget.errorText != null && oldWidget.errorText == null) {
    _shakeController.forward(from: 0);
    HapticService.error();
  }
}
```

**Step 4: build에서 AnimatedBuilder로 Transform 적용**

```dart
AnimatedBuilder(
  animation: _shakeAnimation,
  builder: (context, child) => Transform.translate(
    offset: Offset(_shakeAnimation.value, 0),
    child: child,
  ),
  child: TextField(...),
)
```

**Step 5: Commit**

```bash
git add lib/core/widgets/saju_input.dart
git commit -m "feat: SajuInput 에러 시 shake 애니메이션 + 햅틱"
```

---

## Task 4: 온보딩 폼 "한 화면 하나" 리팩토링 (2→5 스텝)

**Files:**
- Modify: `lib/features/auth/presentation/pages/onboarding_form_page.dart`

**핵심:** 기존 2스텝(이름+성별+생년월일 / 시진)을 5스텝(이름 / 성별 / 생년월일 / 시진 / 확인)으로 분리. 선택형은 자동진행, 텍스트형은 버튼 활성화. 기존 _SiJin, _StepCharacter, _submitForm 로직은 그대로 유지.

**Step 1: _stepCharacters 확장 (2→5)**

```dart
static const _stepCharacters = [
  _StepCharacter(
    name: '물결이', asset: CharacterAssets.mulgyeoriWaterDefault, color: SajuColor.water,
  ),
  _StepCharacter(
    name: '물결이', asset: CharacterAssets.mulgyeoriWaterDefault, color: SajuColor.water,
  ),
  _StepCharacter(
    name: '물결이', asset: CharacterAssets.mulgyeoriWaterDefault, color: SajuColor.water,
  ),
  _StepCharacter(
    name: '쇠동이', asset: CharacterAssets.soedongiMetalDefault, color: SajuColor.metal,
  ),
  _StepCharacter(
    name: '물결이', asset: CharacterAssets.mulgyeoriWaterDefault, color: SajuColor.water,
  ),
];
```

**Step 2: 프로그레스바 교체**

기존 캐릭터 아이콘 프로그레스 → **리니어 프로그레스바** (한지 스타일)

```dart
Widget _buildProgressBar() {
  final progress = (_currentStep + 1) / 5;
  final currentColor = _stepCharacters[_currentStep].color.resolve(context);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SajuSpacing.space24),
    child: Column(
      children: [
        // 스텝 카운터
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currentStep + 1} / 5',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
        SajuSpacing.gap8,
        // 프로그레스 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: SajuAnimation.slow,
            curve: SajuAnimation.entrance,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE8E4DF),
              valueColor: AlwaysStoppedAnimation<Color>(currentColor),
              minHeight: 4,
            ),
          ),
        ),
      ],
    ),
  );
}
```

**Step 3: PageView를 5개 스텝으로 분리**

```dart
PageView(
  controller: _pageController,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    _buildStepName(),      // Step 0: 이름
    _buildStepGender(),    // Step 1: 성별
    _buildStepBirthDate(), // Step 2: 생년월일
    _buildStepSiJin(),     // Step 3: 시진
    _buildStepConfirm(),   // Step 4: 확인
  ],
),
```

**Step 4: Step 0 — 이름 (auto-focus, 버튼 활성화)**

```dart
Widget _buildStepName() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SajuSpacing.space24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SajuSpacing.gap8,
        SajuCharacterBubble(
          characterName: '물결이',
          message: '반가워! 이름이 뭐야~?',
          elementColor: SajuColor.water,
          size: SajuSize.md,
        ),
        SajuSpacing.gap32,
        SajuInput(
          label: '이름',
          hint: '이름을 입력해주세요',
          controller: _nameController,
          errorText: _nameError,
          autofocus: true,
          maxLength: 20,
          size: SajuSize.lg,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
            setState(() {}); // 버튼 활성화 갱신
          },
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    ),
  );
}
```

**Step 5: Step 1 — 성별 (자동 진행)**

```dart
Widget _buildStepGender() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SajuSpacing.space24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SajuSpacing.gap8,
        SajuCharacterBubble(
          characterName: '물결이',
          message: '${_nameController.text.trim()}님, 성별을 알려줘!',
          elementColor: SajuColor.water,
          size: SajuSize.md,
        ),
        SajuSpacing.gap48,
        Row(
          children: [
            Expanded(
              child: SajuChip(
                label: '남성',
                color: SajuColor.water,
                isSelected: _selectedGender == '남성',
                size: SajuSize.lg,
                onTap: () => _selectGender('남성'),
              ),
            ),
            SajuSpacing.hGap16,
            Expanded(
              child: SajuChip(
                label: '여성',
                color: SajuColor.fire,
                isSelected: _selectedGender == '여성',
                size: SajuSize.lg,
                onTap: () => _selectGender('여성'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _selectGender(String gender) {
  setState(() => _selectedGender = gender);
  HapticService.selection();
  Future.delayed(const Duration(milliseconds: 300), () {
    HapticService.light();
    _goToStep(_currentStep + 1);
  });
}
```

**Step 6: Step 2 — 생년월일 (인라인 CupertinoDatePicker)**

기존 바텀시트 피커 → 인라인 피커.
화면 상단에 캐릭터 버블 + 선택된 날짜 미리보기, 하단에 CupertinoDatePicker.

```dart
Widget _buildStepBirthDate() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SajuSpacing.space24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SajuSpacing.gap8,
        SajuCharacterBubble(
          characterName: '물결이',
          message: '태어난 날짜를 알려줘~',
          elementColor: SajuColor.water,
          size: SajuSize.md,
        ),
        SajuSpacing.gap24,
        // 선택된 날짜 미리보기
        if (_birthDate != null)
          Center(
            child: Text(
              '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.waterColor,
              ),
            ),
          ),
        SajuSpacing.gap16,
        // 인라인 날짜 피커
        SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _birthDate ?? DateTime(2000, 1, 1),
            minimumDate: DateTime(1940, 1, 1),
            maximumDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
            onDateTimeChanged: (date) {
              setState(() => _birthDate = date);
              HapticService.selection();
            },
          ),
        ),
      ],
    ),
  );
}
```

**Step 7: Step 3 — 시진 (기존 그리드 재활용 + 자동 진행)**

기존 `_buildStep2()`의 그리드를 재활용하되, 칩 탭 시 0.3초 후 자동 진행:

```dart
void _selectSiJin(int? index) {
  setState(() => _selectedSiJinIndex = index);
  HapticService.selection();
  Future.delayed(const Duration(milliseconds: 300), () {
    HapticService.light();
    _goToStep(_currentStep + 1);
  });
}
```

"모르겠어요" 탭도 동일하게 자동 진행.

**Step 8: Step 4 — 입력 확인 요약**

```dart
Widget _buildStepConfirm() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SajuSpacing.space24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SajuSpacing.gap8,
        SajuCharacterBubble(
          characterName: '물결이',
          message: '좋아! 이제 사주를 분석해볼까?',
          elementColor: SajuColor.water,
          size: SajuSize.md,
        ),
        SajuSpacing.gap32,
        // 입력 요약 카드
        _buildSummaryCard(),
      ],
    ),
  );
}

Widget _buildSummaryCard() {
  return Container(
    padding: const EdgeInsets.all(SajuSpacing.space20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      border: Border.all(color: const Color(0xFFE0DCD7)),
    ),
    child: Column(
      children: [
        _summaryRow(Icons.person, '이름', _nameController.text.trim(), 0),
        const Divider(height: 24),
        _summaryRow(Icons.wc, '성별', _selectedGender ?? '', 1),
        const Divider(height: 24),
        _summaryRow(
          Icons.cake,
          '생년월일',
          _birthDate != null
              ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
              : '',
          2,
        ),
        const Divider(height: 24),
        _summaryRow(
          Icons.access_time,
          '생시',
          _selectedSiJinIndex != null
              ? '${_siJinList[_selectedSiJinIndex!].name} (${_siJinList[_selectedSiJinIndex!].timeRange})'
              : '모르겠어요',
          3,
        ),
      ],
    ),
  );
}

Widget _summaryRow(IconData icon, String label, String value, int stepIndex) {
  return GestureDetector(
    onTap: () => _goToStep(stepIndex),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.waterColor),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: const Color(0xFF6B6B6B))),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Icon(Icons.edit, size: 14, color: const Color(0xFFA0A0A0)),
      ],
    ),
  );
}
```

**Step 9: 네비게이션 로직 업데이트**

```dart
void _nextStep() {
  if (!_validateCurrentStep()) return;

  if (_currentStep < 4) {
    _goToStep(_currentStep + 1);
  } else {
    HapticService.medium();
    _submitForm();
  }
}

bool _validateCurrentStep() {
  switch (_currentStep) {
    case 0: // 이름
      final name = _nameController.text.trim();
      if (name.length < 2) {
        setState(() => _nameError = '이름은 2자 이상이어야 해요');
        return false;
      }
      setState(() => _nameError = null);
      return true;
    case 1: // 성별 — 자동 진행이므로 항상 true (이미 선택됨)
      return _selectedGender != null;
    case 2: // 생년월일
      return _birthDate != null;
    case 3: // 시진 — 모르겠어요 허용이므로 항상 true
      return true;
    case 4: // 확인
      return true;
    default:
      return true;
  }
}
```

**Step 10: 하단 버튼 업데이트 — 조건부 활성화**

```dart
Widget _buildBottomButtons() {
  // 성별(1), 시진(3) 스텝은 자동 진행이므로 하단 버튼 숨김
  final isAutoAdvanceStep = _currentStep == 1 || _currentStep == 3;
  if (isAutoAdvanceStep) return const SizedBox.shrink();

  final isLastStep = _currentStep == 4;
  final isValid = _isCurrentStepValid;

  return Container(
    padding: const EdgeInsets.fromLTRB(
      SajuSpacing.space24, SajuSpacing.space8,
      SajuSpacing.space24, SajuSpacing.space16,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F3EE),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SajuButton(
      label: isLastStep ? '사주 분석하기' : '다음',
      onPressed: isValid ? _nextStep : null,
      color: _stepCharacters[_currentStep].color,
      size: SajuSize.xl,
      leadingIcon: isLastStep ? Icons.auto_awesome : null,
    ),
  );
}

bool get _isCurrentStepValid => switch (_currentStep) {
  0 => _nameController.text.trim().length >= 2,
  2 => _birthDate != null,
  4 => true,
  _ => true,
};
```

**Step 11: Commit**

```bash
git add lib/features/auth/presentation/pages/onboarding_form_page.dart
git commit -m "feat: 온보딩 폼 — 한 화면 하나 패턴 (2→5스텝, 자동진행, 햅틱)"
```

---

## Task 5: 홈 페이지 — 스켈레톤 로딩 + 섹션 등장 애니메이션

**Files:**
- Create: `lib/core/widgets/skeleton_card.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/core/widgets/widgets.dart` (배럴 export 추가)

**핵심:** 스피너 → 스켈레톤 카드 교체, 각 섹션 스크롤 진입 시 fadeIn+slideUp

**Step 1: SkeletonCard 위젯 생성**

```dart
/// lib/core/widgets/skeleton_card.dart
import 'package:flutter/material.dart';

/// 매칭 카드 형태의 스켈레톤 로딩 위젯
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.width = 180, this.height = 260});

  final double width;
  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDE8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 영역
              Container(
                height: widget.height * 0.6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + 2 * _shimmerController.value, 0),
                    end: Alignment(1 + 2 * _shimmerController.value, 0),
                    colors: [
                      const Color(0xFFE8E4DF),
                      const Color(0xFFF0EDE8),
                      const Color(0xFFE8E4DF),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // 텍스트 영역
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBar(width: widget.width * 0.5, height: 14),
                    const SizedBox(height: 8),
                    _shimmerBar(width: widget.width * 0.7, height: 12),
                    const SizedBox(height: 8),
                    _shimmerBar(width: widget.width * 0.4, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DF),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
```

**Step 2: home_page.dart 로딩 영역 교체**

`recommendations.when` loading 부분:
```dart
loading: () => SizedBox(
  height: 260,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: 3,
    separatorBuilder: (_, _) => const SizedBox(width: 12),
    itemBuilder: (_, _) => const SkeletonCard(),
  ),
),
```

`receivedLikes.when` loading 부분:
```dart
loading: () => Container(
  height: 64,
  decoration: BoxDecoration(
    color: const Color(0xFFF0EDE8),
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
  ),
),
```

**Step 3: 섹션 등장 애니메이션 — _FadeSlideSection 래퍼**

```dart
class _FadeSlideSection extends StatefulWidget {
  const _FadeSlideSection({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_FadeSlideSection> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlideSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
```

홈 페이지 각 섹션을 `_FadeSlideSection`으로 래핑:
```dart
_FadeSlideSection(
  delay: Duration.zero,
  child: /* 인사 섹션 */,
),
_FadeSlideSection(
  delay: const Duration(milliseconds: 100),
  child: /* 오늘의 추천 */,
),
_FadeSlideSection(
  delay: const Duration(milliseconds: 200),
  child: /* 관상 넛지 */,
),
// ...
```

**Step 4: widgets.dart 배럴 export 추가**

```dart
export 'skeleton_card.dart';
```

**Step 5: Commit**

```bash
git add lib/core/widgets/skeleton_card.dart lib/core/widgets/widgets.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: 홈 스켈레톤 로딩 + 섹션 fadeIn/slideUp 등장 애니메이션"
```

---

## Task 6: 통합 검증 + 테스크 마스터 업데이트

**Step 1: flutter analyze**

```bash
cd /Users/noah/saju-app && flutter analyze
```

Expected: 0 new errors

**Step 2: 플로우 검증 체크리스트**

- [ ] 온보딩 Step 1 (이름): auto-focus, 2자 이상 시 버튼 활성화, Enter로 진행
- [ ] 온보딩 Step 2 (성별): 칩 탭 → 0.3초 후 자동 진행
- [ ] 온보딩 Step 3 (생년월일): 인라인 피커, 날짜 미리보기, 버튼으로 진행
- [ ] 온보딩 Step 4 (시진): 그리드 탭 → 0.3초 후 자동 진행, 모르겠어요도 동일
- [ ] 온보딩 Step 5 (확인): 요약 카드 표시, 각 항목 탭→해당 스텝으로 이동, 사주 분석하기 CTA
- [ ] 햅틱: 칩 선택 시 selectionClick, 자동 진행 시 lightImpact, 에러 시 heavyImpact
- [ ] SajuButton: onPressed=null일 때 opacity 0.4로 비활성 표시
- [ ] SajuInput: errorText 등장 시 shake 애니메이션
- [ ] 홈: 스켈레톤 카드 로딩, 섹션 등장 애니메이션

**Step 3: 테스크 마스터 + 설계 문서 업데이트**

```bash
# docs/plans/2026-02-24-task-master.md에 UX 리팩토링 섹션 추가
git add docs/plans/
git commit -m "feat: 토스 스타일 UX 리팩토링 Phase A+B 완료 — 한 화면 하나 + 햅틱 + 스켈레톤"
```

---

## 요약

| Task | 내용 | 파일 | 규모 |
|------|------|------|------|
| 1 | HapticService 생성 | 신규 1개 | 소 |
| 2 | SajuButton 비활성 시각 강화 | 수정 1개 | 소 |
| 3 | SajuInput shake 애니메이션 | 수정 1개 | 중 |
| 4 | 온보딩 폼 5스텝 리팩토링 | 수정 1개 | 대 |
| 5 | 홈 스켈레톤 + 등장 애니메이션 | 신규 1개 + 수정 2개 | 중 |
| 6 | 통합 검증 | - | - |

**총: 신규 2개, 수정 4개, 6 Tasks**
**기존 코드 삭제 없음 — 리팩토링 + 인프라 추가**
