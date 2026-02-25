# 사주 저장 파이프라인 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 온보딩→사주분석→DB저장→궁합계산이 실데이터로 동작하는 완전한 파이프라인 구축

**Architecture:** SajuRepositoryImpl.analyzeSaju() 내부에 DB 저장을 원자적으로 통합. 온보딩 폼에서 시진→HH:mm 변환 및 userId 전달을 수정하여 전체 데이터 흐름 완성.

**Tech Stack:** Flutter/Dart, Supabase (PostgreSQL + Edge Functions), Riverpod, go_router

---

## Task 1: DB 마이그레이션 — profiles.saju_profile_id 추가

**Files:**
- Create: `supabase/migrations/20260225000001_add_saju_profile_id_to_profiles.sql`

**Step 1: 마이그레이션 파일 생성**

```sql
-- profiles 테이블에 saju_profile_id 컬럼 추가
-- saju_profiles와 1:1 관계 설정
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS saju_profile_id uuid
  REFERENCES public.saju_profiles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_saju_profile
  ON public.profiles(saju_profile_id);
```

**Step 2: 커밋**

```bash
git add supabase/migrations/20260225000001_add_saju_profile_id_to_profiles.sql
git commit -m "feat: profiles.saju_profile_id 컬럼 추가 마이그레이션"
```

---

## Task 2: SajuRemoteDatasource — 저장 메서드 추가

**Files:**
- Modify: `lib/features/saju/data/datasources/saju_remote_datasource.dart`

**Step 1: saveSajuProfile 메서드 추가**

`SajuRemoteDatasource` 클래스 끝(line 139, `generateInsight` 다음)에 추가:

```dart
  /// 사주 분석 결과를 DB에 저장 (upsert)
  ///
  /// [userId]: profiles.id
  /// [sajuModel]: 사주 계산 결과
  /// [insightModel]: AI 인사이트 결과
  ///
  /// 반환: 저장된 saju_profiles 행의 UUID
  Future<String> saveSajuProfile({
    required String userId,
    required SajuProfileModel sajuModel,
    required SajuInsightModel insightModel,
  }) async {
    final data = <String, dynamic>{
      'user_id': userId,
      'year_pillar': sajuModel.yearPillar.toJson(),
      'month_pillar': sajuModel.monthPillar.toJson(),
      'day_pillar': sajuModel.dayPillar.toJson(),
      'hour_pillar': sajuModel.hourPillar?.toJson(),
      'five_elements': sajuModel.fiveElements.toJson(),
      'dominant_element': sajuModel.dominantElement ?? 'wood',
      'personality_traits': insightModel.personalityTraits,
      'ai_interpretation': insightModel.interpretation,
      'is_lunar_calendar': sajuModel.isLunar,
      'calculated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final row = await _helper.upsert(_sajuProfilesTable, data);
    return row['id'] as String;
  }

  /// 사주 프로필을 유저 프로필에 연결
  ///
  /// profiles 테이블의 saju_profile_id, dominant_element, character_type 갱신
  Future<void> linkSajuProfileToUser({
    required String userId,
    required String sajuProfileId,
    required String dominantElement,
    required String characterType,
  }) async {
    await _helper.update(
      SupabaseTables.profiles,
      userId,
      {
        'saju_profile_id': sajuProfileId,
        'dominant_element': dominantElement,
        'character_type': characterType,
      },
    );
  }
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/saju/data/datasources/saju_remote_datasource.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/saju/data/datasources/saju_remote_datasource.dart
git commit -m "feat: SajuRemoteDatasource에 saveSajuProfile/linkSajuProfileToUser 추가"
```

---

## Task 3: SajuRepository 인터페이스 — saveSajuProfile 추가

**Files:**
- Modify: `lib/features/saju/domain/repositories/saju_repository.dart`

**Step 1: 추상 메서드 추가**

`getSajuForCompatibility` 아래(line 55 이후)에 추가:

```dart

  /// 사주 분석 결과를 DB에 저장하고 프로필에 연결
  ///
  /// [analyzeSaju] 내부에서 자동 호출되므로 직접 호출할 일은 드뭅니다.
  /// 재분석 시 upsert로 안전하게 덮어씁니다.
  ///
  /// [userId]: profiles.id
  /// [sajuProfile]: 저장할 사주 프로필 엔티티
  ///
  /// 반환: 저장된 saju_profiles의 UUID
  Future<String> saveSajuProfile({
    required String userId,
    required SajuProfile sajuProfile,
  });
```

**Step 2: 커밋**

```bash
git add lib/features/saju/domain/repositories/saju_repository.dart
git commit -m "feat: SajuRepository에 saveSajuProfile 추상 메서드 추가"
```

---

## Task 4: SajuRepositoryImpl — analyzeSaju에 저장 로직 통합

**Files:**
- Modify: `lib/features/saju/data/repositories/saju_repository_impl.dart`

**Step 1: 오행→캐릭터 매핑 상수 추가**

파일 상단(import 아래, 클래스 선언 전)에 추가:

```dart
/// 오행 → 캐릭터 타입 매핑 (DB 저장용)
const _elementToCharacter = <String, String>{
  'wood': 'namuri',
  'fire': 'bulkkori',
  'earth': 'heuksuni',
  'metal': 'soedongi',
  'water': 'mulgyeori',
};
```

**Step 2: analyzeSaju 메서드 수정**

기존 `analyzeSaju` 전체를 교체 (line 29~61):

```dart
  @override
  Future<SajuProfile> analyzeSaju({
    required String userId,
    required String birthDate,
    String? birthTime,
    bool isLunar = false,
    String? userName,
  }) async {
    // Step 1: 만세력 기반 사주팔자 계산
    final sajuModel = await _datasource.calculateSaju(
      birthDate: birthDate,
      birthTime: birthTime,
      isLunar: isLunar,
    );

    // Step 2: AI 인사이트 생성
    final insightModel = await _datasource.generateInsight(
      sajuResult: sajuModel.toJson(),
      userName: userName,
    );

    // Step 3: DB에 사주 프로필 저장 (upsert)
    final savedId = await _datasource.saveSajuProfile(
      userId: userId,
      sajuModel: sajuModel,
      insightModel: insightModel,
    );

    // Step 4: 프로필에 사주 연결 (saju_profile_id + dominant_element + character_type)
    final element = sajuModel.dominantElement ?? 'wood';
    final character = _elementToCharacter[element] ?? 'namuri';
    await _datasource.linkSajuProfileToUser(
      userId: userId,
      sajuProfileId: savedId,
      dominantElement: element,
      characterType: character,
    );

    // Step 5: 실제 DB ID로 엔티티 생성
    return sajuModel.toEntity(
      id: savedId,
      userId: userId,
      personalityTraits: insightModel.personalityTraits,
      aiInterpretation: insightModel.interpretation,
    );
  }
```

**Step 3: saveSajuProfile 구현 추가**

`getSajuForCompatibility` 아래에:

```dart
  @override
  Future<String> saveSajuProfile({
    required String userId,
    required SajuProfile sajuProfile,
  }) async {
    // 이 메서드는 analyzeSaju 내부에서 이미 처리하므로
    // 외부에서 직접 호출할 경우를 위한 폴백 구현
    throw UnimplementedError(
      'saveSajuProfile은 analyzeSaju 내부에서 자동으로 호출됩니다.',
    );
  }
```

**Step 4: flutter analyze 확인**

Run: `flutter analyze lib/features/saju/`
Expected: No issues

**Step 5: 커밋**

```bash
git add lib/features/saju/data/repositories/saju_repository_impl.dart
git commit -m "feat: analyzeSaju에 DB 저장 + 프로필 연결 로직 통합"
```

---

## Task 5: 온보딩 폼 — 시진→HH:mm 변환

**Files:**
- Modify: `lib/features/auth/presentation/pages/onboarding_form_page.dart`

**Step 1: 시진→HH:mm 변환 메서드 추가**

`_OnboardingFormPageState` 클래스 내부, `_siJinList` 아래(line 64 이후)에 추가:

```dart
  /// 시진 index → HH:mm 대표 시각 변환
  ///
  /// 각 시진의 2시간 범위 중 짝수 정시를 대표값으로 사용.
  /// 예: 자시(23:00~01:00) → "00:00", 축시(01:00~03:00) → "02:00"
  static String _siJinToHHmm(int index) {
    const times = [
      '00:00', // 0: 자시
      '02:00', // 1: 축시
      '04:00', // 2: 인시
      '06:00', // 3: 묘시
      '08:00', // 4: 진시
      '10:00', // 5: 사시
      '12:00', // 6: 오시
      '14:00', // 7: 미시
      '16:00', // 8: 신시
      '18:00', // 9: 유시
      '20:00', // 10: 술시
      '22:00', // 11: 해시
    ];
    return times[index];
  }
```

**Step 2: _submitForm 수정**

기존 (line 146~157):
```dart
  void _submitForm() {
    final formData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'birthDate': _birthDate?.toIso8601String(),
      'birthHour': _selectedSiJinIndex != null
          ? _siJinList[_selectedSiJinIndex!].name
          : null,
    };

    widget.onComplete(formData);
  }
```

변경 후:
```dart
  void _submitForm() {
    final formData = <String, dynamic>{
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'birthDate': _birthDate?.toIso8601String(),
      'birthTime': _selectedSiJinIndex != null
          ? _siJinToHHmm(_selectedSiJinIndex!)
          : null,
    };

    widget.onComplete(formData);
  }
```

**Step 3: 커밋**

```bash
git add lib/features/auth/presentation/pages/onboarding_form_page.dart
git commit -m "feat: 온보딩 폼 시진→HH:mm 변환 + birthHour→birthTime 키 변경"
```

---

## Task 6: 온보딩 Provider — 키 이름 수정

**Files:**
- Modify: `lib/features/auth/presentation/providers/onboarding_provider.dart`

**Step 1: birthHour → birthTime 키 변경**

기존 (line 25):
```dart
        birthTime: formData['birthHour'] as String?,
```

변경 후:
```dart
        birthTime: formData['birthTime'] as String?,
```

**Step 2: 코드 생성 재실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, `onboarding_provider.g.dart` 재생성

**Step 3: 커밋**

```bash
git add lib/features/auth/presentation/providers/onboarding_provider.dart lib/features/auth/presentation/providers/onboarding_provider.g.dart
git commit -m "fix: onboarding provider birthHour→birthTime 키 이름 수정"
```

---

## Task 7: OnboardingPage — userId + analysisData 전달

**Files:**
- Modify: `lib/features/auth/presentation/pages/onboarding_page.dart`

**Step 1: _onFormComplete 수정**

기존 (line 84~100):
```dart
  Future<void> _onFormComplete(Map<String, dynamic> formData) async {
    try {
      await ref
          .read(onboardingNotifierProvider.notifier)
          .saveOnboardingData(formData);
      if (mounted) context.go(RoutePaths.sajuAnalysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장에 실패했어요. 다시 시도해주세요.'),
            backgroundColor: AppTheme.fireColor,
          ),
        );
      }
    }
  }
```

변경 후:
```dart
  Future<void> _onFormComplete(Map<String, dynamic> formData) async {
    try {
      final user = await ref
          .read(onboardingNotifierProvider.notifier)
          .saveOnboardingData(formData);
      if (mounted) {
        final analysisData = <String, dynamic>{
          'userId': user.id,
          'birthDate': formData['birthDate'] as String?,
          'birthTime': formData['birthTime'] as String?,
          'isLunar': false,
          'userName': formData['name'] as String?,
        };
        context.go(RoutePaths.sajuAnalysis, extra: analysisData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장에 실패했어요. 다시 시도해주세요.'),
            backgroundColor: AppTheme.fireColor,
          ),
        );
      }
    }
  }
```

**Step 2: flutter analyze 확인**

Run: `flutter analyze lib/features/auth/`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/auth/presentation/pages/onboarding_page.dart
git commit -m "feat: 온보딩→사주분석 userId+analysisData extra 전달"
```

---

## Task 8: 전체 빌드 검증 + 코드 생성

**Step 1: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, `.g.dart` 파일들 재생성

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: flutter test**

Run: `flutter test`
Expected: 기존 테스트 모두 통과

**Step 4: 최종 커밋**

```bash
git add -A
git commit -m "chore: build_runner 재생성 + 전체 빌드 검증"
```

---

## Task 9: 테스크 마스터 업데이트

**Files:**
- Modify: `docs/plans/2026-02-24-task-master.md`

**Step 1: #2 프로필·사주 저장 연동 완료 표시**

상태를 `⬜` → `✅`로 변경

**Step 2: 커밋**

```bash
git add docs/plans/2026-02-24-task-master.md
git commit -m "docs: 테스크 마스터 #2 프로필·사주 저장 연동 완료"
```

---

## 구현 순서 요약

```
Task 1: DB 마이그레이션 (profiles.saju_profile_id)
  ↓
Task 2: Datasource 저장 메서드 (saveSajuProfile + linkSajuProfileToUser)
  ↓
Task 3: Domain 인터페이스 (saveSajuProfile 추상 메서드)
  ↓
Task 4: Repository 구현 (analyzeSaju에 저장 로직 통합)
  ↓
Task 5: 온보딩 폼 (시진→HH:mm 변환)
  ↓
Task 6: 온보딩 Provider (키 이름 수정)
  ↓
Task 7: OnboardingPage (userId + analysisData 전달)
  ↓
Task 8: 전체 빌드 검증
  ↓
Task 9: 테스크 마스터 업데이트
```

## 변경 파일 총정리

| 파일 | Task | 작업 |
|------|------|------|
| `supabase/migrations/20260225000001_add_saju_profile_id_to_profiles.sql` | 1 | CREATE |
| `lib/features/saju/data/datasources/saju_remote_datasource.dart` | 2 | MODIFY |
| `lib/features/saju/domain/repositories/saju_repository.dart` | 3 | MODIFY |
| `lib/features/saju/data/repositories/saju_repository_impl.dart` | 4 | MODIFY |
| `lib/features/auth/presentation/pages/onboarding_form_page.dart` | 5 | MODIFY |
| `lib/features/auth/presentation/providers/onboarding_provider.dart` | 6 | MODIFY |
| `lib/features/auth/presentation/pages/onboarding_page.dart` | 7 | MODIFY |
| `docs/plans/2026-02-24-task-master.md` | 9 | MODIFY |
