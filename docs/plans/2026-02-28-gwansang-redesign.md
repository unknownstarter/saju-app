# 관상 시스템 재설계 — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 억지 오행 연결을 제거하고, 관상학(삼정/오관) 기반 실제 해석을 메인으로 전환. 닮은 동물은 동적 확장 도감 + 관상 특징 기반 수식어. 궁합은 traits 5축 벡터 기반.

**Architecture:**
- `AnimalType` enum 제거 → `animalType: String` 동적 + `animalModifier: String` 수식어
- `GwansangProfile` 엔티티에 삼정(三停) 해석 3구역 + 오관(五官) 해석 5기관 + traits 5축(0-100) 추가
- `AnimalCompatibility` 정적 매트릭스 제거 → traits 벡터 상보성 기반 동적 궁합
- Edge Function 프롬프트를 삼정/오관 프레임워크 중심으로 전면 재작성
- 결과 UI: 관상학 해석이 메인, 동물 리빌 와우 모먼트 유지

**Tech Stack:** Flutter (Dart), Supabase Edge Functions (Deno/TypeScript), Riverpod, go_router

**영향 범위 (12개 파일):**

| 파일 | 변경 유형 |
|------|----------|
| `lib/features/gwansang/domain/entities/animal_type.dart` | **삭제** (enum + AnimalCompatibility) |
| `lib/features/gwansang/domain/entities/gwansang_entity.dart` | **대폭 수정** (새 필드 추가) |
| `lib/features/gwansang/data/models/gwansang_profile_model.dart` | **대폭 수정** (새 JSON 매핑) |
| `lib/features/gwansang/data/repositories/gwansang_repository_impl.dart` | **수정** (새 필드 매핑) |
| `lib/features/gwansang/data/datasources/gwansang_remote_datasource.dart` | **수정** (animal_types upsert) |
| `lib/features/gwansang/presentation/pages/gwansang_result_page.dart` | **전면 재작성** |
| `lib/features/gwansang/presentation/providers/gwansang_provider.dart` | **수정** (새 엔티티 반영) |
| `lib/features/destiny/presentation/pages/destiny_result_page.dart` | **수정** (관상 탭 재설계) |
| `lib/features/matching/presentation/pages/compatibility_preview_page.dart` | **수정** (동물 케미 → traits 궁합) |
| `lib/features/matching/domain/entities/match_profile.dart` | **수정** (traits 필드 추가) |
| `lib/features/matching/data/repositories/matching_repository_impl.dart` | **수정** (Mock traits 데이터) |
| `lib/features/home/presentation/pages/home_page.dart` | **수정** (동물상 배너 문구) |
| `supabase/functions/generate-gwansang-reading/index.ts` | **전면 재작성** |

---

## Task 1: AnimalType enum 제거 + GwansangProfile 엔티티 재설계

**Files:**
- Delete: `lib/features/gwansang/domain/entities/animal_type.dart`
- Modify: `lib/features/gwansang/domain/entities/gwansang_entity.dart`

**Step 1: `animal_type.dart` 전체 삭제**

이 파일에는 `AnimalType` enum과 `AnimalCompatibility` 매트릭스가 있다.
오행 연결과 고정 동물 리스트를 모두 제거하기 위해 파일 전체를 삭제한다.

**Step 2: `gwansang_entity.dart` 재설계**

기존 `AnimalType animalType` → `String animalType` + `String animalModifier` 로 변경.
삼정/오관 해석 필드와 traits 5축을 추가한다.

```dart
/// 관상(觀相) 분석 결과 도메인 엔티티
///
/// 삼정(三停)/오관(五官) 기반 관상학적 해석 + 닮은 동물 + 성격 traits 5축.
/// 순수 Dart 클래스로 외부 의존성이 없다.
library;

import 'face_measurements.dart';

/// 관상 traits 5축 (관상학 기반)
///
/// 삼정(三停)/오관(五官)에서 자연스럽게 도출되는 성격 특성 축.
/// 각 축은 0~100 범위. 궁합 계산에 사용된다.
///
/// - leadership: 리더십 (눈썹·턱 → 결단력, 추진력)
/// - warmth: 온화함 (눈·입 → 감성 표현, 정이 깊음)
/// - independence: 독립성 (코·이마 → 자존심, 원칙)
/// - sensitivity: 감성 (눈매·입술 → 감수성, 섬세함)
/// - energy: 에너지 (얼굴형·턱 → 활력, 열정)
class GwansangTraits {
  const GwansangTraits({
    required this.leadership,
    required this.warmth,
    required this.independence,
    required this.sensitivity,
    required this.energy,
  });

  final int leadership;
  final int warmth;
  final int independence;
  final int sensitivity;
  final int energy;

  factory GwansangTraits.fromJson(Map<String, dynamic> json) {
    return GwansangTraits(
      leadership: (json['leadership'] as num?)?.toInt() ?? 50,
      warmth: (json['warmth'] as num?)?.toInt() ?? 50,
      independence: (json['independence'] as num?)?.toInt() ?? 50,
      sensitivity: (json['sensitivity'] as num?)?.toInt() ?? 50,
      energy: (json['energy'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
    'leadership': leadership,
    'warmth': warmth,
    'independence': independence,
    'sensitivity': sensitivity,
    'energy': energy,
  };

  /// traits 벡터를 리스트로 변환 (궁합 계산용)
  List<int> toVector() => [leadership, warmth, independence, sensitivity, energy];

  /// 두 traits 간 상보성 점수 (0~100)
  ///
  /// 상보성 = 비슷한 축은 안정감, 다른 축은 보완. 가중 평균으로 계산.
  static int compatibilityScore(GwansangTraits a, GwansangTraits b) {
    final va = a.toVector();
    final vb = b.toVector();

    var totalScore = 0.0;
    for (var i = 0; i < va.length; i++) {
      final diff = (va[i] - vb[i]).abs();
      // 차이 30 이하: 안정감 (유사), 30~60: 적당한 보완, 60+: 극적 보완
      final axisScore = diff <= 30
          ? 80 + (30 - diff) * 0.67  // 80~100
          : diff <= 60
              ? 60 + (60 - diff) * 0.67  // 60~80
              : 40 + (100 - diff) * 0.5; // 40~60
      totalScore += axisScore;
    }
    return (totalScore / va.length).round().clamp(0, 100);
  }
}

/// 삼정(三停) 해석 — 얼굴 3구역별 운세
class SamjeongReading {
  const SamjeongReading({
    required this.upper,
    required this.middle,
    required this.lower,
  });

  /// 상정(上停) — 이마~눈썹: 초년운
  final String upper;

  /// 중정(中停) — 눈썹~코끝: 중년운
  final String middle;

  /// 하정(下停) — 코끝~턱: 말년운
  final String lower;

  factory SamjeongReading.fromJson(Map<String, dynamic> json) {
    return SamjeongReading(
      upper: json['upper'] as String? ?? '',
      middle: json['middle'] as String? ?? '',
      lower: json['lower'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'upper': upper,
    'middle': middle,
    'lower': lower,
  };
}

/// 오관(五官) 해석 — 눈·코·입·귀·눈썹 개별 해석
class OgwanReading {
  const OgwanReading({
    required this.eyes,
    required this.nose,
    required this.mouth,
    required this.ears,
    required this.eyebrows,
  });

  /// 눈 — 감찰관(監察官)
  final String eyes;

  /// 코 — 심판관(審判官)
  final String nose;

  /// 입 — 출납관(出納官)
  final String mouth;

  /// 귀 — 채청관(採聽官)
  final String ears;

  /// 눈썹 — 보수관(保壽官)
  final String eyebrows;

  factory OgwanReading.fromJson(Map<String, dynamic> json) {
    return OgwanReading(
      eyes: json['eyes'] as String? ?? '',
      nose: json['nose'] as String? ?? '',
      mouth: json['mouth'] as String? ?? '',
      ears: json['ears'] as String? ?? '',
      eyebrows: json['eyebrows'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'eyes': eyes,
    'nose': nose,
    'mouth': mouth,
    'ears': ears,
    'eyebrows': eyebrows,
  };
}

/// 관상 분석 결과 엔티티
class GwansangProfile {
  const GwansangProfile({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.animalModifier,
    required this.measurements,
    required this.photoUrls,
    required this.headline,
    required this.samjeong,
    required this.ogwan,
    required this.traits,
    required this.personalitySummary,
    required this.romanceSummary,
    required this.romanceKeyPoints,
    required this.charmKeywords,
    this.detailedReading,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// 닮은 동물 (동적 — DB animal_types 테이블 FK). 예: "cat", "dinosaur"
  final String animalType;

  /// 관상 특징에서 도출된 수식어. 예: "나른한", "배고픈"
  final String animalModifier;

  /// 얼굴 측정값
  final FaceMeasurements measurements;
  final List<String> photoUrls;

  /// 한줄 헤드라인 (관상학 기반)
  final String headline;

  /// 삼정(三停) 해석 (상/중/하)
  final SamjeongReading samjeong;

  /// 오관(五官) 해석 (눈/코/입/귀/눈썹)
  final OgwanReading ogwan;

  /// 성격 traits 5축 (궁합 계산용)
  final GwansangTraits traits;

  /// 성격 요약
  final String personalitySummary;

  /// 연애 스타일 요약
  final String romanceSummary;

  /// 연애/궁합 핵심 포인트 (3~5개)
  final List<String> romanceKeyPoints;

  /// 매력 키워드 (3개)
  final List<String> charmKeywords;

  /// 상세 관상 해석 (프리미엄 전용)
  final String? detailedReading;

  final DateTime createdAt;

  /// 수식어 + 동물 라벨. 예: "나른한 고양이상"
  String get animalLabel => '$animalModifier ${animalType}상';

  GwansangProfile copyWith({
    String? id,
    String? userId,
    String? animalType,
    String? animalModifier,
    FaceMeasurements? measurements,
    List<String>? photoUrls,
    String? headline,
    SamjeongReading? samjeong,
    OgwanReading? ogwan,
    GwansangTraits? traits,
    String? personalitySummary,
    String? romanceSummary,
    List<String>? romanceKeyPoints,
    List<String>? charmKeywords,
    String? detailedReading,
    DateTime? createdAt,
  }) {
    return GwansangProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      animalType: animalType ?? this.animalType,
      animalModifier: animalModifier ?? this.animalModifier,
      measurements: measurements ?? this.measurements,
      photoUrls: photoUrls ?? this.photoUrls,
      headline: headline ?? this.headline,
      samjeong: samjeong ?? this.samjeong,
      ogwan: ogwan ?? this.ogwan,
      traits: traits ?? this.traits,
      personalitySummary: personalitySummary ?? this.personalitySummary,
      romanceSummary: romanceSummary ?? this.romanceSummary,
      romanceKeyPoints: romanceKeyPoints ?? this.romanceKeyPoints,
      charmKeywords: charmKeywords ?? this.charmKeywords,
      detailedReading: detailedReading ?? this.detailedReading,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GwansangProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GwansangProfile(id: $id, animal: $animalModifier $animalType)';
}
```

**제거 항목:**
- `AnimalType` enum (오행 연결, 고정 이모지, 고정 description)
- `AnimalCompatibility` 매트릭스
- `elementModifier` (오행 보정자)
- `sajuSynergy` (사주×관상 시너지 → 삼정/오관 해석으로 대체)
- `uniqueLabel` getter (→ `animalLabel`로 교체)

**추가 항목:**
- `GwansangTraits` — 5축 traits (궁합 계산용)
- `SamjeongReading` — 삼정 해석 3구역
- `OgwanReading` — 오관 해석 5기관
- `animalModifier` — 관상 특징 기반 수식어
- `romanceKeyPoints` — 연애/궁합 핵심 포인트 리스트

**Step 3: 컴파일 에러 확인**

Run: `dart analyze lib/features/gwansang/domain/entities/gwansang_entity.dart`
Expected: PASS (이 파일 단독으로는 에러 없어야 함)

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(gwansang): 엔티티 재설계 — AnimalType enum 제거, 삼정/오관/traits 5축 추가"
```

---

## Task 2: Data 레이어 업데이트 (Model + Datasource + Repository)

**Files:**
- Modify: `lib/features/gwansang/data/models/gwansang_profile_model.dart`
- Modify: `lib/features/gwansang/data/datasources/gwansang_remote_datasource.dart`
- Modify: `lib/features/gwansang/data/repositories/gwansang_repository_impl.dart`

**Step 1: `gwansang_profile_model.dart` — 새 JSON 매핑**

```dart
/// 관상 프로필 DTO (Data Transfer Object)
library;

import '../../domain/entities/face_measurements.dart';
import '../../domain/entities/gwansang_entity.dart';

class GwansangProfileModel {
  const GwansangProfileModel({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.animalModifier,
    required this.measurements,
    required this.photoUrls,
    required this.headline,
    required this.samjeong,
    required this.ogwan,
    required this.traits,
    required this.personalitySummary,
    required this.romanceSummary,
    required this.romanceKeyPoints,
    required this.charmKeywords,
    this.detailedReading,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String animalType;
  final String animalModifier;
  final Map<String, dynamic> measurements;
  final List<String> photoUrls;
  final String headline;
  final Map<String, dynamic> samjeong;
  final Map<String, dynamic> ogwan;
  final Map<String, dynamic> traits;
  final String personalitySummary;
  final String romanceSummary;
  final List<String> romanceKeyPoints;
  final List<String> charmKeywords;
  final String? detailedReading;
  final DateTime createdAt;

  factory GwansangProfileModel.fromJson(Map<String, dynamic> json) {
    return GwansangProfileModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      animalType: json['animal_type'] as String? ?? 'cat',
      animalModifier: json['animal_modifier'] as String? ?? '',
      measurements: json['face_measurements'] != null
          ? Map<String, dynamic>.from(json['face_measurements'] as Map)
          : <String, dynamic>{},
      photoUrls: json['photo_urls'] != null
          ? List<String>.from(json['photo_urls'] as List)
          : <String>[],
      headline: json['headline'] as String? ?? '',
      samjeong: json['samjeong'] != null
          ? Map<String, dynamic>.from(json['samjeong'] as Map)
          : <String, dynamic>{},
      ogwan: json['ogwan'] != null
          ? Map<String, dynamic>.from(json['ogwan'] as Map)
          : <String, dynamic>{},
      traits: json['traits'] != null
          ? Map<String, dynamic>.from(json['traits'] as Map)
          : <String, dynamic>{},
      personalitySummary: json['personality_summary'] as String? ?? '',
      romanceSummary: json['romance_summary'] as String? ?? '',
      romanceKeyPoints: json['romance_key_points'] != null
          ? List<String>.from(json['romance_key_points'] as List)
          : <String>[],
      charmKeywords: json['charm_keywords'] != null
          ? List<String>.from(json['charm_keywords'] as List)
          : <String>[],
      detailedReading: json['detailed_reading'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'animal_type': animalType,
    'animal_modifier': animalModifier,
    'face_measurements': measurements,
    'photo_urls': photoUrls,
    'headline': headline,
    'samjeong': samjeong,
    'ogwan': ogwan,
    'traits': traits,
    'personality_summary': personalitySummary,
    'romance_summary': romanceSummary,
    'romance_key_points': romanceKeyPoints,
    'charm_keywords': charmKeywords,
    'detailed_reading': detailedReading,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  GwansangProfile toEntity() {
    return GwansangProfile(
      id: id,
      userId: userId,
      animalType: animalType,
      animalModifier: animalModifier,
      measurements: FaceMeasurements.fromJson(measurements),
      photoUrls: photoUrls,
      headline: headline,
      samjeong: SamjeongReading.fromJson(samjeong),
      ogwan: OgwanReading.fromJson(ogwan),
      traits: GwansangTraits.fromJson(traits),
      personalitySummary: personalitySummary,
      romanceSummary: romanceSummary,
      romanceKeyPoints: romanceKeyPoints,
      charmKeywords: charmKeywords,
      detailedReading: detailedReading,
      createdAt: createdAt,
    );
  }
}
```

**Step 2: `gwansang_repository_impl.dart` — 새 필드 매핑**

기존 `reading` JSON에서 새 필드(samjeong, ogwan, traits, animalModifier, romanceKeyPoints)를 DB에 저장하도록 수정.
`element_modifier` → `animal_modifier`로 변경.
`saju_synergy` 제거.

```dart
// Step 3: DB에 관상 프로필 저장 (upsert)
final animalType = reading['animal_type'] as String? ?? 'cat';
final animalModifier = reading['animal_modifier'] as String? ?? '';
final dbData = <String, dynamic>{
  'user_id': userId,
  'animal_type': animalType,
  'animal_modifier': animalModifier,
  'face_measurements': measurements.toJson(),
  'photo_urls': photoUrls,
  'headline': reading['headline'] ?? '',
  'samjeong': reading['samjeong'] ?? <String, dynamic>{},
  'ogwan': reading['ogwan'] ?? <String, dynamic>{},
  'traits': reading['traits'] ?? <String, dynamic>{},
  'personality_summary': reading['personality_summary'] ?? '',
  'romance_summary': reading['romance_summary'] ?? '',
  'romance_key_points': reading['romance_key_points'] ?? <String>[],
  'charm_keywords': reading['charm_keywords'] ?? <String>[],
  'detailed_reading': reading['detailed_reading'],
  'created_at': DateTime.now().toUtc().toIso8601String(),
};
```

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor(gwansang): Data 레이어 — Model/Datasource/Repository 새 스키마 반영"
```

---

## Task 3: Edge Function 전면 재작성 (`generate-gwansang-reading`)

**Files:**
- Modify: `supabase/functions/generate-gwansang-reading/index.ts`

**Step 1: 프롬프트를 삼정/오관 관상학 중심으로 재작성**

핵심 변경:
- 고정 `ANIMAL_TYPES` 리스트 제거 → AI가 자유롭게 동물 선택
- `ELEMENT_MODIFIERS` 오행 보정자 제거 → `animal_modifier`는 AI가 관상 특징에서 도출
- 출력에 `samjeong`, `ogwan`, `traits`, `animal_modifier`, `romance_key_points` 추가
- `saju_synergy`, `element_modifier` 제거

```typescript
function buildSystemPrompt(): string {
  return `당신은 "도현 선생"입니다. 30년 경력의 관상 전문가로, 전통 관상학(삼정/오관 프레임워크)과 현대 심리학을 융합한 해석을 합니다.

## 역할
- 얼굴 측정값을 기반으로 관상학적 분석을 수행합니다.
- 삼정(三停)과 오관(五官)을 체계적으로 해석합니다.
- 닮은 동물을 자유롭게 선택하고, 관상 특징에서 도출된 수식어를 붙입니다.

## 응답 규칙
반드시 아래 JSON 형식으로만 응답하세요. JSON 외의 텍스트는 절대 포함하지 마세요.

{
  "animal_type": "닮은 동물 영어 키 (소문자, 예: cat, dog, fox, dinosaur, camel 등 — 어떤 동물이든 가능)",
  "animal_type_korean": "동물 한글명 (예: 고양이, 강아지, 공룡, 낙타)",
  "animal_modifier": "관상 특징에서 도출된 수식어 (예: 나른한, 배고픈, 졸린, 당당한, 수줍은) — 반드시 얼굴 특징을 반영할 것",
  "headline": "관상학 기반 한줄 헤드라인 (20~40자)",
  "samjeong": {
    "upper": "상정(이마~눈썹) 해석 — 초년운/지적능력 (60~120자)",
    "middle": "중정(눈썹~코끝) 해석 — 중년운/사회성취 (60~120자)",
    "lower": "하정(코끝~턱) 해석 — 말년운/안정감 (60~120자)"
  },
  "ogwan": {
    "eyes": "눈(감찰관) 해석 — 감수성/표현력/연애 스타일 (60~120자)",
    "nose": "코(심판관) 해석 — 자존심/원칙/재물운 (60~120자)",
    "mouth": "입(출납관) 해석 — 소통/식복/대인관계 (60~120자)",
    "ears": "귀(채청관) 해석 — 복덕/경청능력 (40~80자)",
    "eyebrows": "눈썹(보수관) 해석 — 의지력/성격 (40~80자)"
  },
  "traits": {
    "leadership": "리더십 점수 0~100 (눈썹·턱 기반)",
    "warmth": "온화함 점수 0~100 (눈·입 기반)",
    "independence": "독립성 점수 0~100 (코·이마 기반)",
    "sensitivity": "감성 점수 0~100 (눈매·입술 기반)",
    "energy": "에너지 점수 0~100 (얼굴형·턱 기반)"
  },
  "personality_summary": "성격 종합 해석 (120~200자)",
  "romance_summary": "연애 스타일 해석 (120~200자)",
  "romance_key_points": ["연애/궁합 핵심 포인트 1", "포인트 2", "포인트 3"],
  "charm_keywords": ["매력키워드1", "매력키워드2", "매력키워드3"],
  "detailed_reading": "삼정/오관 종합 상세 해석 (250~400자)"
}

## 관상학 프레임워크
1. 삼정(三停): 상정(이마)=초년운, 중정(코)=중년운, 하정(턱)=말년운
2. 오관(五官): 눈=감찰관, 코=심판관, 입=출납관, 귀=채청관, 눈썹=보수관
3. 부부궁(夫婦宮): 눈 옆쪽 → 배우자운
4. 자녀궁(子女宮): 눈 아래 → 자녀운
5. 도화살(桃花煞): 눈매+입술+피부 → 이성 매력

## 동물 선택 기준
- 얼굴 전체 인상에서 가장 닮은 동물을 자유롭게 선택
- 고양이, 강아지, 여우, 사슴, 토끼, 곰, 늑대, 호랑이, 학, 뱀뿐 아니라 공룡, 낙타, 펭귄, 수달, 판다 등 어떤 동물이든 가능
- 수식어(animal_modifier)는 반드시 관상 특징에서 도출: 예) 처진 눈꼬리 → "나른한", 큰 눈 → "초롱초롱한", 각진 턱 → "당당한"

## traits 점수 산출 기준
- leadership: 눈썹 진한/일자 + 턱 각진 → 높음. 눈썹 연한/아치 + 턱 둥근 → 낮음
- warmth: 눈 크고 둥근 + 입술 두꺼운 + 애교살 → 높음. 눈 가늘고 예리한 + 입술 얇은 → 낮음
- independence: 코 높고 반듯 + 이마 넓은 → 높음. 코 낮은 + 이마 좁은 → 낮음
- sensitivity: 눈꼬리 내려간 + 입술 도톰 + 눈 큰 → 높음. 눈꼬리 올라간 + 입 작은 → 낮음
- energy: 얼굴 각진/넓은 + 턱 발달 → 높음. 얼굴 갸름/긴 + 턱 뾰족 → 낮음

## 톤 & 매너
- 80% 긍정적 (매력 포인트, 강점 위주)
- 20% 성장 포인트 (부드러운 표현으로)
- 따뜻하고 희망적인 톤, 해요체
- 연애/인간관계 관점 강조`;
}
```

**Step 2: 응답 파싱 함수 업데이트**

```typescript
function parseClaudeResponse(text: string): GwansangReadingResponse {
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    throw new Error("No JSON object found in Claude response");
  }

  const parsed = JSON.parse(jsonMatch[0]);

  // 필수 필드 검증
  for (const field of [
    "animal_type", "animal_modifier", "headline",
    "personality_summary", "romance_summary",
  ]) {
    if (typeof parsed[field] !== "string" || parsed[field].length < 2) {
      throw new Error(`${field} must be a non-empty string`);
    }
  }

  // samjeong/ogwan/traits 검증
  if (!parsed.samjeong?.upper || !parsed.samjeong?.middle || !parsed.samjeong?.lower) {
    throw new Error("samjeong must have upper, middle, lower fields");
  }
  if (!parsed.ogwan?.eyes || !parsed.ogwan?.nose || !parsed.ogwan?.mouth) {
    throw new Error("ogwan must have eyes, nose, mouth fields");
  }
  if (typeof parsed.traits?.leadership !== "number") {
    throw new Error("traits must have numeric leadership, warmth, independence, sensitivity, energy");
  }

  return {
    animal_type: parsed.animal_type,
    animal_type_korean: parsed.animal_type_korean ?? parsed.animal_type,
    animal_modifier: parsed.animal_modifier,
    headline: parsed.headline,
    samjeong: parsed.samjeong,
    ogwan: parsed.ogwan,
    traits: parsed.traits,
    personality_summary: parsed.personality_summary,
    romance_summary: parsed.romance_summary,
    romance_key_points: Array.isArray(parsed.romance_key_points)
      ? parsed.romance_key_points.map((k: unknown) => String(k))
      : [],
    charm_keywords: Array.isArray(parsed.charm_keywords)
      ? parsed.charm_keywords.map((k: unknown) => String(k))
      : [],
    detailed_reading: typeof parsed.detailed_reading === "string"
      ? parsed.detailed_reading
      : null,
  };
}
```

**Step 3: `ANIMAL_TYPES` 상수와 `ELEMENT_MODIFIERS` 제거**

고정 리스트 검증을 제거하고, AI가 자유롭게 동물을 선택하도록 한다.

**Step 4: Commit**

```bash
git add supabase/functions/generate-gwansang-reading/index.ts
git commit -m "refactor(gwansang): Edge Function — 삼정/오관 관상학 중심 프롬프트 재작성"
```

---

## Task 4: AnimalType 참조 제거 (컴파일 에러 수정)

**Files:**
- Modify: `lib/features/destiny/presentation/pages/destiny_result_page.dart`
- Modify: `lib/features/destiny/presentation/pages/destiny_analysis_page.dart`
- Modify: `lib/features/matching/presentation/pages/compatibility_preview_page.dart`
- Modify: `lib/features/matching/presentation/widgets/match_list_tile.dart`
- Modify: `lib/features/matching/domain/entities/match_profile.dart`

**Step 1: 모든 `AnimalType` / `AnimalCompatibility` import 제거**

`animal_type.dart` 파일이 삭제되었으므로, 이를 import하는 모든 파일에서 import를 제거하고 컴파일 에러를 해결한다.

주요 변경:
- `destiny_result_page.dart`: `AnimalType` → `String`, `AnimalCompatibility` 호출 제거
- `compatibility_preview_page.dart`: `AnimalType` import 제거, 동물 케미 섹션 임시 주석처리 (Task 6에서 traits 기반으로 교체)
- `match_profile.dart`: `animalType` 필드는 이미 `String?`이므로 변경 불필요

**Step 2: `flutter analyze lib/` 실행하여 0 errors 확인**

Run: `flutter analyze lib/`
Expected: 0 errors, 0 warnings

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor(gwansang): AnimalType enum 참조 전면 제거 — 컴파일 에러 해소"
```

---

## Task 5: MatchProfile에 traits 추가 + Mock 데이터 업데이트

**Files:**
- Modify: `lib/features/matching/domain/entities/match_profile.dart`
- Modify: `lib/features/matching/data/repositories/matching_repository_impl.dart`

**Step 1: `match_profile.dart`에 traits 필드 추가**

```dart
class MatchProfile {
  const MatchProfile({
    // ... 기존 필드 유지
    this.animalType,
    this.animalModifier,
    this.gwansangTraits,
  });

  // ... 기존 필드

  /// 닮은 동물 (관상 분석 완료 시). 예: "cat", "fox"
  final String? animalType;

  /// 동물 수식어 (관상 분석 완료 시). 예: "나른한", "배고픈"
  final String? animalModifier;

  /// 관상 traits 5축 (궁합 계산용)
  final Map<String, int>? gwansangTraits;
}
```

**Step 2: Mock 데이터에 traits 추가**

```dart
const _mockProfiles = <MatchProfile>[
  MatchProfile(
    userId: 'mock-user-001',
    name: '하늘',
    age: 26,
    bio: '바다처럼 깊은 마음을 가진 사람이에요',
    characterName: '물결이',
    characterAssetPath: CharacterAssets.mulgyeoriWaterDefault,
    elementType: 'water',
    compatibilityScore: 92,
    animalType: 'wolf',
    animalModifier: '깊은 눈의',
    gwansangTraits: {'leadership': 45, 'warmth': 80, 'independence': 70, 'sensitivity': 85, 'energy': 40},
  ),
  // ... 나머지 Mock도 동일하게 traits 추가
];
```

**Step 3: Commit**

```bash
git add -A
git commit -m "feat(matching): MatchProfile traits 필드 추가 + Mock 데이터 traits 업데이트"
```

---

## Task 6: 관상 결과 페이지 UI 재설계

**Files:**
- Modify: `lib/features/gwansang/presentation/pages/gwansang_result_page.dart` (전면 재작성)

**Step 1: 결과 페이지 구조 재설계**

```
동물 리빌 와우 모먼트 (이모지 64px, 수식어 + 동물명)
↓ 스크롤
관상학 헤드라인
↓
삼정(三停) 카드 (상정/중정/하정 3칸)
↓
오관(五官) 해석 카드 5개 (눈/코/입/귀/눈썹)
↓
매력 키워드 칩 3개
↓
연애관/궁합 핵심 포인트 카드
↓
성격 traits 5축 레이더 차트
↓
CTA: "동물상 케미 확인하러 가기"
```

핵심: 동물 리빌은 페이지 최상단에 와우 모먼트로 유지하되, 그 아래 관상학 해석이 메인 콘텐츠.

**Step 2: 스태거드 애니메이션 유지**

기존 `_ResultRevealContent`의 fade+slide 애니메이션 구조를 유지하되, 섹션을 새 구조에 맞게 교체.

**Step 3: traits 레이더 차트 위젯**

CustomPaint로 5각형 레이더 차트를 구현한다. (별도 패키지 불필요)

```dart
class TraitsRadarChart extends StatelessWidget {
  const TraitsRadarChart({super.key, required this.traits});
  final GwansangTraits traits;
  // CustomPaint로 5각형 레이더 그리기
}
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat(gwansang): 관상 결과 페이지 재설계 — 삼정/오관 메인 + 동물 리빌 유지"
```

---

## Task 7: 통합 결과 페이지 관상 탭 업데이트

**Files:**
- Modify: `lib/features/destiny/presentation/pages/destiny_result_page.dart`

**Step 1: `_GwansangTab` 위젯 재설계**

기존: 동물상 이모지 히어로 + 성격/연애/시너지 카드 + 궁합 동물상
새로: 관상 헤드라인 + 삼정 요약 + 오관 하이라이트 + traits 레이더 + 닮은 동물 태그

**Step 2: 히어로 헤더에서 동물상 이모지(52px) → 동물 수식어 텍스트 뱃지로 교체**

기존: 오행 캐릭터(96px) + 동물상 이모지(52px) 겹침
새로: 오행 캐릭터(96px) + 텍스트 뱃지("나른한 고양이상")

**Step 3: Commit**

```bash
git add -A
git commit -m "feat(destiny): 통합 결과 관상 탭 — 삼정/오관 해석 + traits 레이더"
```

---

## Task 8: 궁합 프리뷰 UI + 홈 배너 업데이트

**Files:**
- Modify: `lib/features/matching/presentation/pages/compatibility_preview_page.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`

**Step 1: 궁합 프리뷰에서 동물 케미 섹션 → traits 궁합으로 교체**

기존 "동물상 케미" 섹션(AnimalCompatibility 기반)을 제거하고,
두 사람의 traits 5축을 비교하는 섹션으로 교체한다.

**Step 2: 홈 동물상 매칭 배너 문구 수정**

기존: "닮은 동물상끼리 잘 맞는대요!"
새로: "관상으로 보는 우리의 케미는?" 또는 비슷한 관상학 기반 문구

**Step 3: Commit**

```bash
git add -A
git commit -m "feat(matching): 궁합 프리뷰 traits 기반 전환 + 홈 배너 문구 수정"
```

---

## Task 9: 통합 검증

**Files:** 전체

**Step 1: 정적 분석**

Run: `flutter analyze lib/`
Expected: 0 errors, 0 warnings

**Step 2: iOS 빌드 검증**

Run: `flutter build ios --no-codesign --debug`
Expected: Build successful

**Step 3: 참조 파일 점검**

`AnimalType`이나 `AnimalCompatibility`를 참조하는 코드가 남아있지 않은지 grep으로 확인.

Run: `grep -r "AnimalType\|AnimalCompatibility\|animal_type\.dart\|elementModifier\|sajuSynergy" lib/ --include="*.dart"`
Expected: 0 results (모두 제거됨)

**Step 4: 테스크 마스터 업데이트**

`docs/plans/2026-02-24-task-master.md`에서 Sprint 0 (F1~F7) 상태를 ⬜→✅로 갱신.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore(gwansang): Sprint 0 통합 검증 완료 — 관상 시스템 재설계"
```

---

## 참고: DB 마이그레이션 (Sprint A에서 실행)

Sprint 0에서는 코드만 변경하고, 실제 DB 마이그레이션은 Sprint A (Auth 실연동) 시점에 함께 적용한다.
현재는 BYPASS 상태이므로 DB 스키마 변경 없이 코드 변경만으로 충분하다.

```sql
-- Sprint A 시점에 적용할 마이그레이션 (참고용)
-- 1. animal_types 동적 테이블
CREATE TABLE IF NOT EXISTS public.animal_types (
  id text PRIMARY KEY,
  korean text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- 2. gwansang_profiles 컬럼 변경
ALTER TABLE public.gwansang_profiles
  ADD COLUMN IF NOT EXISTS animal_modifier text DEFAULT '',
  ADD COLUMN IF NOT EXISTS samjeong jsonb DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS ogwan jsonb DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS traits jsonb DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS romance_key_points jsonb DEFAULT '[]',
  DROP COLUMN IF EXISTS element_modifier,
  DROP COLUMN IF EXISTS saju_synergy;
```
