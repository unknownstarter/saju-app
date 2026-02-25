# AI 관상(觀相) + 동물상 Feature — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 사주 결과 후 AI 관상 분석을 통해 동물상을 부여하고, 자연스럽게 사진 3장을 확보하여 데이팅 퍼널로 연결하는 feature 구현

**Architecture:** 기존 사주 퍼널(`/saju-result`)과 매칭 프로필(`/matching-profile`) 사이에 관상 퍼널 4개 화면을 삽입. On-device ML Kit으로 얼굴 측정 → Supabase Edge Function에서 Claude Haiku로 관상 해석 생성. 사진은 Supabase Storage에 업로드되어 매칭 프로필 사진으로 재사용.

**Tech Stack:** Flutter 3.38+, google_mlkit_face_detection v0.13.2, image_picker v1.1.2, Supabase Edge Functions (Claude Haiku 4.5), Riverpod 2.x, go_router

---

## 전체 흐름 변경

```
[BEFORE]
사주 결과 → 매칭 프로필(5스텝: 사진→기본→자기표현→음주흡연→본인인증) → 홈

[AFTER]
사주 결과 → 관상 브릿지 → 사진 업로드(3장) → 관상 분석(로딩) → 관상 결과(동물상)
         → 매칭 프로필(4스텝: 사진스킵→기본→자기표현→음주흡연→본인인증) → 홈
```

## 수정 대상 기존 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/core/constants/app_constants.dart` | 관상 라우트 경로 + Edge Function명 + Storage 버킷 + 테이블명 추가 |
| `lib/app/routes/app_router.dart` | 관상 4개 라우트 등록 + publicPaths 추가 + import |
| `lib/core/di/providers.dart` | 관상 DI Provider 등록 |
| `lib/features/saju/presentation/pages/saju_result_page.dart:376` | "운명의 인연 찾으러 가기" → 관상 브릿지로 연결 |
| `lib/features/profile/presentation/pages/matching_profile_page.dart` | 관상 사진 존재 시 Step 1(사진) 자동 채움/스킵 |
| `pubspec.yaml` | google_mlkit_face_detection, image_picker, image_cropper 추가 |

---

## Task 1: 패키지 추가 + 상수 등록

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/constants/app_constants.dart:12-41` (RoutePaths, RouteNames)
- Modify: `lib/core/constants/app_constants.dart:71-88` (SupabaseTables)
- Modify: `lib/core/constants/app_constants.dart:90-95` (SupabaseBuckets)
- Modify: `lib/core/constants/app_constants.dart:98-110` (SupabaseFunctions)

**Step 1: pubspec.yaml에 패키지 추가**

`dependencies:` 블록에 추가:
```yaml
  # 관상 (Face Reading)
  google_mlkit_face_detection: ^0.13.2
  image_picker: ^1.1.2
  image_cropper: ^8.0.2
```

**Step 2: flutter pub get 실행**

Run: `cd /Users/noah/saju-app && flutter pub get`
Expected: 패키지 다운로드 성공

**Step 3: RoutePaths에 관상 경로 추가**

`lib/core/constants/app_constants.dart` RoutePaths 클래스의 `// --- 서브 페이지 ---` 섹션에 추가:
```dart
  // --- 관상 퍼널 ---
  static const gwansangBridge = '/gwansang-bridge';
  static const gwansangPhoto = '/gwansang-photo';
  static const gwansangAnalysis = '/gwansang-analysis';
  static const gwansangResult = '/gwansang-result';
```

**Step 4: RouteNames에 관상 이름 추가**

RouteNames 클래스에 추가:
```dart
  static const gwansangBridge = 'gwansang-bridge';
  static const gwansangPhoto = 'gwansang-photo';
  static const gwansangAnalysis = 'gwansang-analysis';
  static const gwansangResult = 'gwansang-result';
```

**Step 5: SupabaseTables에 관상 테이블 추가**

```dart
  static const gwansangProfiles = 'gwansang_profiles';
```

**Step 6: SupabaseBuckets에 관상 버킷 추가**

```dart
  static const gwansangPhotos = 'gwansang-photos';
```

**Step 7: SupabaseFunctions에 관상 함수 추가**

```dart
  static const generateGwansangReading = 'generate-gwansang-reading';
```

**Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/constants/app_constants.dart
git commit -m "feat: 관상 feature 패키지 추가 + 상수 등록"
```

---

## Task 2: 도메인 엔티티 — GwansangProfile + AnimalType

**Files:**
- Create: `lib/features/gwansang/domain/entities/gwansang_entity.dart`
- Create: `lib/features/gwansang/domain/entities/animal_type.dart`
- Create: `lib/features/gwansang/domain/entities/face_measurements.dart`

**Step 1: 디렉토리 구조 생성**

```bash
mkdir -p lib/features/gwansang/domain/entities
mkdir -p lib/features/gwansang/domain/repositories
mkdir -p lib/features/gwansang/data/datasources
mkdir -p lib/features/gwansang/data/models
mkdir -p lib/features/gwansang/data/repositories
mkdir -p lib/features/gwansang/presentation/pages
mkdir -p lib/features/gwansang/presentation/providers
mkdir -p lib/features/gwansang/presentation/widgets
```

**Step 2: AnimalType enum 생성**

`lib/features/gwansang/domain/entities/animal_type.dart`:

```dart
import '../../../../core/constants/app_constants.dart';

/// 동물상 10종 분류
///
/// 관상 분석을 통해 부여되는 동물상 타입.
/// 각 동물상은 오행(五行)과 연결되어 사주와 시너지를 이룬다.
enum AnimalType {
  cat(
    korean: '고양이',
    label: '도도한 고양이상',
    emoji: '🐱',
    element: FiveElementType.wood,
    description: '다가오면 도망가고, 멀어지면 다가오는 밀당의 제왕',
  ),
  dog(
    korean: '강아지',
    label: '충직한 강아지상',
    emoji: '🐶',
    element: FiveElementType.fire,
    description: '한번 마음 주면 끝까지, 사랑 앞에 솔직한 타입',
  ),
  fox(
    korean: '여우',
    label: '영리한 여우상',
    emoji: '🦊',
    element: FiveElementType.fire,
    description: '본능적으로 분위기를 읽는 타고난 소셜 천재',
  ),
  wolf(
    korean: '늑대',
    label: '자유로운 늑대상',
    emoji: '🐺',
    element: FiveElementType.water,
    description: '속박을 싫어하고, 깊은 눈빛으로 상대를 사로잡는 타입',
  ),
  deer(
    korean: '사슴',
    label: '순수한 사슴상',
    emoji: '🦌',
    element: FiveElementType.wood,
    description: '맑은 눈망울로 모든 걸 녹여버리는 천연 매력가',
  ),
  rabbit(
    korean: '토끼',
    label: '사랑스러운 토끼상',
    emoji: '🐰',
    element: FiveElementType.earth,
    description: '귀여움이 무기, 보호본능을 자극하는 타입',
  ),
  bear(
    korean: '곰',
    label: '든든한 곰상',
    emoji: '🐻',
    element: FiveElementType.earth,
    description: '말은 없지만 행동으로 보여주는 묵직한 존재감',
  ),
  snake(
    korean: '뱀',
    label: '신비로운 뱀상',
    emoji: '🐍',
    element: FiveElementType.water,
    description: '쉽게 읽히지 않는 미스터리, 한번 빠지면 헤어나올 수 없는 매력',
  ),
  tiger(
    korean: '호랑이',
    label: '카리스마 호랑이상',
    emoji: '🐯',
    element: FiveElementType.metal,
    description: '있는 것만으로도 존재감 폭발, 타고난 리더상',
  ),
  crane(
    korean: '학',
    label: '고고한 학상',
    emoji: '🦢',
    element: FiveElementType.metal,
    description: '우아함의 끝판왕, 범접할 수 없는 고급 아우라',
  );

  const AnimalType({
    required this.korean,
    required this.label,
    required this.emoji,
    required this.element,
    required this.description,
  });

  final String korean;
  final String label;
  final String emoji;
  final FiveElementType element;
  final String description;

  /// JSON 직렬화용
  static AnimalType fromString(String value) {
    return AnimalType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnimalType.cat,
    );
  }
}

/// 동물상 궁합 매트릭스
///
/// 찰떡궁합(5), 밀당궁합(4), 위험한 궁합(2) 등
abstract final class AnimalCompatibility {
  static const Map<(AnimalType, AnimalType), int> matrix = {
    (AnimalType.cat, AnimalType.dog): 5,
    (AnimalType.fox, AnimalType.bear): 5,
    (AnimalType.wolf, AnimalType.deer): 5,
    (AnimalType.rabbit, AnimalType.tiger): 5,
    (AnimalType.snake, AnimalType.crane): 5,
    (AnimalType.cat, AnimalType.wolf): 4,
    (AnimalType.fox, AnimalType.snake): 4,
    (AnimalType.tiger, AnimalType.wolf): 4,
    (AnimalType.cat, AnimalType.cat): 2,
    (AnimalType.tiger, AnimalType.tiger): 2,
    (AnimalType.wolf, AnimalType.rabbit): 2,
  };

  /// 두 동물상의 궁합 점수 (기본값 3)
  static int score(AnimalType a, AnimalType b) {
    return matrix[(a, b)] ?? matrix[(b, a)] ?? 3;
  }

  /// 궁합 등급 텍스트
  static String grade(int score) => switch (score) {
    5 => '찰떡궁합',
    4 => '밀당궁합',
    3 => '보통궁합',
    2 => '위험한 궁합',
    _ => '보통궁합',
  };
}
```

**Step 3: FaceMeasurements 엔티티 생성**

`lib/features/gwansang/domain/entities/face_measurements.dart`:

```dart
/// 얼굴 측정값 — ML Kit에서 추출한 구조화된 데이터
///
/// 사진이 서버로 전송되지 않고, 이 측정값(숫자)만 전송된다.
/// 관상학의 삼정(三停), 오관(五官) 분석에 필요한 모든 비율/수치를 포함.
class FaceMeasurements {
  const FaceMeasurements({
    required this.faceShape,
    required this.upperThird,
    required this.middleThird,
    required this.lowerThird,
    required this.eyeSpacing,
    required this.eyeSlant,
    required this.eyeSize,
    required this.noseBridgeHeight,
    required this.noseWidth,
    required this.mouthWidth,
    required this.lipThickness,
    required this.eyebrowArch,
    required this.eyebrowThickness,
    required this.foreheadHeight,
    required this.jawlineAngle,
    required this.faceSymmetry,
    required this.faceLengthRatio,
  });

  /// 얼굴형 (round, oval, square, heart, long, diamond)
  final String faceShape;

  /// 삼정(三停) 비율 — 이상적인 값은 각각 ~0.33
  final double upperThird;   // 이마~눈썹 (상정)
  final double middleThird;  // 눈썹~코끝 (중정)
  final double lowerThird;   // 코끝~턱 (하정)

  /// 눈 관련
  final double eyeSpacing;      // 미간 거리 (0~1, 0.5가 표준)
  final double eyeSlant;        // 눈꼬리 각도 (-1 처짐 ~ +1 올라감)
  final double eyeSize;         // 눈 크기 비율 (0~1)

  /// 코 관련
  final double noseBridgeHeight; // 콧대 높이 (0~1)
  final double noseWidth;        // 코 너비 (0~1)

  /// 입 관련
  final double mouthWidth;       // 입 너비 (0~1)
  final double lipThickness;     // 입술 두께 (0~1)

  /// 눈썹 관련
  final double eyebrowArch;      // 눈썹 아치 (0 일자 ~ 1 둥근)
  final double eyebrowThickness; // 눈썹 두께 (0~1)

  /// 이마
  final double foreheadHeight;   // 이마 높이 비율 (0~1)

  /// 턱
  final double jawlineAngle;     // 턱선 각도 (0 둥근 ~ 1 각진)

  /// 대칭도 (0~1, 1이 완벽 대칭)
  final double faceSymmetry;

  /// 얼굴 세로/가로 비율
  final double faceLengthRatio;

  Map<String, dynamic> toJson() => {
    'face_shape': faceShape,
    'upper_third': upperThird,
    'middle_third': middleThird,
    'lower_third': lowerThird,
    'eye_spacing': eyeSpacing,
    'eye_slant': eyeSlant,
    'eye_size': eyeSize,
    'nose_bridge_height': noseBridgeHeight,
    'nose_width': noseWidth,
    'mouth_width': mouthWidth,
    'lip_thickness': lipThickness,
    'eyebrow_arch': eyebrowArch,
    'eyebrow_thickness': eyebrowThickness,
    'forehead_height': foreheadHeight,
    'jawline_angle': jawlineAngle,
    'face_symmetry': faceSymmetry,
    'face_length_ratio': faceLengthRatio,
  };

  factory FaceMeasurements.fromJson(Map<String, dynamic> json) {
    return FaceMeasurements(
      faceShape: json['face_shape'] as String? ?? 'oval',
      upperThird: (json['upper_third'] as num?)?.toDouble() ?? 0.33,
      middleThird: (json['middle_third'] as num?)?.toDouble() ?? 0.33,
      lowerThird: (json['lower_third'] as num?)?.toDouble() ?? 0.34,
      eyeSpacing: (json['eye_spacing'] as num?)?.toDouble() ?? 0.5,
      eyeSlant: (json['eye_slant'] as num?)?.toDouble() ?? 0.0,
      eyeSize: (json['eye_size'] as num?)?.toDouble() ?? 0.5,
      noseBridgeHeight: (json['nose_bridge_height'] as num?)?.toDouble() ?? 0.5,
      noseWidth: (json['nose_width'] as num?)?.toDouble() ?? 0.5,
      mouthWidth: (json['mouth_width'] as num?)?.toDouble() ?? 0.5,
      lipThickness: (json['lip_thickness'] as num?)?.toDouble() ?? 0.5,
      eyebrowArch: (json['eyebrow_arch'] as num?)?.toDouble() ?? 0.5,
      eyebrowThickness: (json['eyebrow_thickness'] as num?)?.toDouble() ?? 0.5,
      foreheadHeight: (json['forehead_height'] as num?)?.toDouble() ?? 0.5,
      jawlineAngle: (json['jawline_angle'] as num?)?.toDouble() ?? 0.5,
      faceSymmetry: (json['face_symmetry'] as num?)?.toDouble() ?? 0.8,
      faceLengthRatio: (json['face_length_ratio'] as num?)?.toDouble() ?? 1.3,
    );
  }
}
```

**Step 4: GwansangProfile 엔티티 생성**

`lib/features/gwansang/domain/entities/gwansang_entity.dart`:

```dart
import 'animal_type.dart';
import 'face_measurements.dart';

/// 관상 분석 결과 엔티티
///
/// ML Kit 측정값 + AI 해석 + 동물상 분류를 모두 포함하는 도메인 엔티티.
class GwansangProfile {
  const GwansangProfile({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.measurements,
    required this.photoUrls,
    required this.headline,
    required this.personalitySummary,
    required this.romanceSummary,
    required this.sajuSynergy,
    required this.charmKeywords,
    this.elementModifier,
    this.detailedReading,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// 동물상 타입
  final AnimalType animalType;

  /// 얼굴 측정값
  final FaceMeasurements measurements;

  /// 업로드된 사진 URL (3장)
  final List<String> photoUrls;

  /// 한 줄 헤드라인 (예: "타고난 리더형 관상, 눈빛에 결단력이 서려 있어요")
  final String headline;

  /// 성격 요약
  final String personalitySummary;

  /// 연애 스타일 요약
  final String romanceSummary;

  /// 사주 × 관상 시너지 메시지
  final String sajuSynergy;

  /// 매력 키워드 (3개)
  final List<String> charmKeywords;

  /// 오행 수식어 (사주 일간 기반, 예: "숲속의", "달빛 아래의")
  final String? elementModifier;

  /// 상세 관상 풀이 (프리미엄)
  final String? detailedReading;

  final DateTime createdAt;

  /// 오행 × 동물상 유니크 레이블
  /// 예: "숲속의 신비로운 고양이" (木 + 고양이)
  String get uniqueLabel {
    if (elementModifier != null) {
      return '$elementModifier ${animalType.label}';
    }
    return animalType.label;
  }

  GwansangProfile copyWith({
    String? id,
    String? userId,
    AnimalType? animalType,
    FaceMeasurements? measurements,
    List<String>? photoUrls,
    String? headline,
    String? personalitySummary,
    String? romanceSummary,
    String? sajuSynergy,
    List<String>? charmKeywords,
    String? elementModifier,
    String? detailedReading,
    DateTime? createdAt,
  }) {
    return GwansangProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      animalType: animalType ?? this.animalType,
      measurements: measurements ?? this.measurements,
      photoUrls: photoUrls ?? this.photoUrls,
      headline: headline ?? this.headline,
      personalitySummary: personalitySummary ?? this.personalitySummary,
      romanceSummary: romanceSummary ?? this.romanceSummary,
      sajuSynergy: sajuSynergy ?? this.sajuSynergy,
      charmKeywords: charmKeywords ?? this.charmKeywords,
      elementModifier: elementModifier ?? this.elementModifier,
      detailedReading: detailedReading ?? this.detailedReading,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GwansangProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 5: Commit**

```bash
git add lib/features/gwansang/
git commit -m "feat(gwansang): 도메인 엔티티 — GwansangProfile, AnimalType, FaceMeasurements"
```

---

## Task 3: Repository 인터페이스 + Data 레이어

**Files:**
- Create: `lib/features/gwansang/domain/repositories/gwansang_repository.dart`
- Create: `lib/features/gwansang/data/models/gwansang_profile_model.dart`
- Create: `lib/features/gwansang/data/datasources/gwansang_remote_datasource.dart`
- Create: `lib/features/gwansang/data/repositories/gwansang_repository_impl.dart`

**Step 1: Repository 인터페이스 (domain)**

`lib/features/gwansang/domain/repositories/gwansang_repository.dart`:

```dart
import '../entities/face_measurements.dart';
import '../entities/gwansang_entity.dart';

/// 관상 분석 Repository 인터페이스
abstract class GwansangRepository {
  /// 관상 분석 실행 (사진 업로드 + 측정 + AI 해석 + 저장)
  Future<GwansangProfile> analyzeGwansang({
    required String userId,
    required List<String> photoLocalPaths,
    required FaceMeasurements measurements,
    required Map<String, dynamic> sajuData,
    required String gender,
    required int age,
  });

  /// 저장된 관상 프로필 조회
  Future<GwansangProfile?> getGwansangProfile(String userId);
}
```

**Step 2: GwansangProfileModel (data)**

`lib/features/gwansang/data/models/gwansang_profile_model.dart`:

```dart
import '../../domain/entities/animal_type.dart';
import '../../domain/entities/face_measurements.dart';
import '../../domain/entities/gwansang_entity.dart';

/// GwansangProfile DTO — Supabase JSON ↔ Domain Entity 변환
class GwansangProfileModel {
  const GwansangProfileModel({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.measurements,
    required this.photoUrls,
    required this.headline,
    required this.personalitySummary,
    required this.romanceSummary,
    required this.sajuSynergy,
    required this.charmKeywords,
    this.elementModifier,
    this.detailedReading,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String animalType;
  final Map<String, dynamic> measurements;
  final List<String> photoUrls;
  final String headline;
  final String personalitySummary;
  final String romanceSummary;
  final String sajuSynergy;
  final List<String> charmKeywords;
  final String? elementModifier;
  final String? detailedReading;
  final DateTime createdAt;

  factory GwansangProfileModel.fromJson(Map<String, dynamic> json) {
    return GwansangProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      animalType: json['animal_type'] as String,
      measurements: json['face_measurements'] as Map<String, dynamic>? ?? {},
      photoUrls: (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      headline: json['headline'] as String? ?? '',
      personalitySummary: json['personality_summary'] as String? ?? '',
      romanceSummary: json['romance_summary'] as String? ?? '',
      sajuSynergy: json['saju_synergy'] as String? ?? '',
      charmKeywords: (json['charm_keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      elementModifier: json['element_modifier'] as String?,
      detailedReading: json['detailed_reading'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'animal_type': animalType,
    'face_measurements': measurements,
    'photo_urls': photoUrls,
    'headline': headline,
    'personality_summary': personalitySummary,
    'romance_summary': romanceSummary,
    'saju_synergy': sajuSynergy,
    'charm_keywords': charmKeywords,
    'element_modifier': elementModifier,
    'detailed_reading': detailedReading,
  };

  GwansangProfile toEntity() => GwansangProfile(
    id: id,
    userId: userId,
    animalType: AnimalType.fromString(animalType),
    measurements: FaceMeasurements.fromJson(measurements),
    photoUrls: photoUrls,
    headline: headline,
    personalitySummary: personalitySummary,
    romanceSummary: romanceSummary,
    sajuSynergy: sajuSynergy,
    charmKeywords: charmKeywords,
    elementModifier: elementModifier,
    detailedReading: detailedReading,
    createdAt: createdAt,
  );
}
```

**Step 3: Remote Datasource**

`lib/features/gwansang/data/datasources/gwansang_remote_datasource.dart`:

```dart
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/gwansang_profile_model.dart';

/// 관상 분석 원격 데이터소스
///
/// Supabase Storage(사진 업로드) + Edge Function(AI 해석) + DB(결과 저장)
class GwansangRemoteDatasource {
  GwansangRemoteDatasource(this._helper);

  final SupabaseHelper _helper;

  /// 사진 3장을 Storage에 업로드하고 public URL 반환
  Future<List<String>> uploadPhotos({
    required String userId,
    required List<String> localPaths,
  }) async {
    final client = _helper.client;
    final urls = <String>[];

    for (var i = 0; i < localPaths.length; i++) {
      final file = File(localPaths[i]);
      final storagePath = '$userId/gwansang_${i + 1}.jpg';

      await client.storage
          .from(SupabaseBuckets.gwansangPhotos)
          .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

      final url = client.storage
          .from(SupabaseBuckets.gwansangPhotos)
          .getPublicUrl(storagePath);

      urls.add(url);
    }

    return urls;
  }

  /// Edge Function 호출 → AI 관상 해석 생성
  Future<Map<String, dynamic>> generateReading({
    required Map<String, dynamic> faceMeasurements,
    required Map<String, dynamic> sajuData,
    required String gender,
    required int age,
  }) async {
    final response = await _helper.callFunction(
      SupabaseFunctions.generateGwansangReading,
      body: {
        'face_measurements': faceMeasurements,
        'saju_data': sajuData,
        'gender': gender,
        'age': age,
      },
    );

    return response as Map<String, dynamic>;
  }

  /// 관상 프로필 DB 저장 (upsert)
  Future<String> saveGwansangProfile(Map<String, dynamic> data) async {
    final response = await _helper.client
        .from(SupabaseTables.gwansangProfiles)
        .upsert(data, onConflict: 'user_id')
        .select('id')
        .single();

    return response['id'] as String;
  }

  /// profiles 테이블에 관상 정보 연결
  Future<void> linkGwansangToProfile({
    required String userId,
    required String gwansangProfileId,
    required String animalType,
    required List<String> photoUrls,
  }) async {
    await _helper.client
        .from(SupabaseTables.profiles)
        .update({
          'gwansang_profile_id': gwansangProfileId,
          'animal_type': animalType,
          'is_gwansang_complete': true,
          // 관상 사진을 프로필 사진으로도 설정 (비어있을 경우)
          'profile_images': photoUrls,
        })
        .eq('id', userId);
  }

  /// 관상 프로필 조회
  Future<GwansangProfileModel?> getByUserId(String userId) async {
    final response = await _helper.client
        .from(SupabaseTables.gwansangProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return GwansangProfileModel.fromJson(response);
  }
}
```

**Step 4: Repository 구현체**

`lib/features/gwansang/data/repositories/gwansang_repository_impl.dart`:

```dart
import '../../domain/entities/face_measurements.dart';
import '../../domain/entities/gwansang_entity.dart';
import '../../domain/repositories/gwansang_repository.dart';
import '../datasources/gwansang_remote_datasource.dart';
import '../models/gwansang_profile_model.dart';

class GwansangRepositoryImpl implements GwansangRepository {
  GwansangRepositoryImpl(this._datasource);

  final GwansangRemoteDatasource _datasource;

  @override
  Future<GwansangProfile> analyzeGwansang({
    required String userId,
    required List<String> photoLocalPaths,
    required FaceMeasurements measurements,
    required Map<String, dynamic> sajuData,
    required String gender,
    required int age,
  }) async {
    // 1. 사진 업로드
    final photoUrls = await _datasource.uploadPhotos(
      userId: userId,
      localPaths: photoLocalPaths,
    );

    // 2. AI 관상 해석 생성
    final reading = await _datasource.generateReading(
      faceMeasurements: measurements.toJson(),
      sajuData: sajuData,
      gender: gender,
      age: age,
    );

    // 3. DB 저장
    final data = {
      'user_id': userId,
      'animal_type': reading['animal_type'],
      'face_measurements': measurements.toJson(),
      'photo_urls': photoUrls,
      'headline': reading['headline'],
      'personality_summary': reading['personality_summary'],
      'romance_summary': reading['romance_summary'],
      'saju_synergy': reading['saju_synergy'],
      'charm_keywords': reading['charm_keywords'],
      'element_modifier': reading['element_modifier'],
      'detailed_reading': reading['detailed_reading'],
    };

    final savedId = await _datasource.saveGwansangProfile(data);

    // 4. profiles 테이블 연결
    await _datasource.linkGwansangToProfile(
      userId: userId,
      gwansangProfileId: savedId,
      animalType: reading['animal_type'] as String,
      photoUrls: photoUrls,
    );

    // 5. 엔티티 변환 후 반환
    return GwansangProfileModel.fromJson({
      ...data,
      'id': savedId,
      'created_at': DateTime.now().toIso8601String(),
    }).toEntity();
  }

  @override
  Future<GwansangProfile?> getGwansangProfile(String userId) async {
    final model = await _datasource.getByUserId(userId);
    return model?.toEntity();
  }
}
```

**Step 5: Commit**

```bash
git add lib/features/gwansang/
git commit -m "feat(gwansang): data 레이어 — Repository, Datasource, Model"
```

---

## Task 4: Face Analysis Service (ML Kit 통합)

**Files:**
- Create: `lib/features/gwansang/domain/services/face_analyzer_service.dart`

**Step 1: FaceAnalyzerService 생성**

이 서비스는 on-device에서 실행되며, 사진에서 얼굴 측정값을 추출한다.
`google_mlkit_face_detection` 패키지를 사용하여 15개 contour type에서 비율/각도를 계산.

`lib/features/gwansang/domain/services/face_analyzer_service.dart`:

```dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../entities/face_measurements.dart';

/// On-device 얼굴 분석 서비스
///
/// ML Kit Face Detection으로 얼굴 랜드마크/컨투어 추출 → 관상 측정값 계산.
/// 사진은 기기에서만 처리되며 서버로 전송되지 않는다.
class FaceAnalyzerService {
  FaceAnalyzerService() : _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final FaceDetector _detector;

  /// 사진 파일에서 얼굴 측정값 추출
  ///
  /// 반환값이 null이면 얼굴을 감지하지 못한 것이다.
  Future<FaceMeasurements?> analyze(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) return null;

    // 가장 큰 얼굴(가장 가까운 얼굴)을 선택
    final face = faces.reduce((a, b) =>
      a.boundingBox.width * a.boundingBox.height >
      b.boundingBox.width * b.boundingBox.height ? a : b);

    return _computeMeasurements(face);
  }

  /// 3장의 사진에서 측정값을 평균
  Future<FaceMeasurements?> analyzeMultiple(List<File> images) async {
    final measurements = <FaceMeasurements>[];

    for (final image in images) {
      final m = await analyze(image);
      if (m != null) measurements.add(m);
    }

    if (measurements.isEmpty) return null;
    if (measurements.length == 1) return measurements.first;

    // 여러 사진의 측정값 평균
    return _averageMeasurements(measurements);
  }

  /// 사진에서 얼굴이 감지되는지 빠르게 검증
  Future<bool> validatePhoto(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector.processImage(inputImage);
    return faces.isNotEmpty;
  }

  FaceMeasurements _computeMeasurements(Face face) {
    final box = face.boundingBox;
    final faceWidth = box.width;
    final faceHeight = box.height;

    // 얼굴형 판별
    final lengthRatio = faceHeight / faceWidth;
    final faceShape = _classifyFaceShape(lengthRatio, face);

    // 삼정 비율 계산
    final (upper, middle, lower) = _computeThirds(face, faceHeight);

    // 눈 측정
    final (eyeSpacing, eyeSlant, eyeSize) = _computeEyeMetrics(face, faceWidth);

    // 코 측정
    final (noseBridge, noseWidth) = _computeNoseMetrics(face, faceWidth, faceHeight);

    // 입 측정
    final (mouthWidth, lipThickness) = _computeMouthMetrics(face, faceWidth, faceHeight);

    // 눈썹 측정
    final (browArch, browThickness) = _computeEyebrowMetrics(face, faceHeight);

    // 이마 높이
    final foreheadHeight = upper; // 삼정 상정이 곧 이마 비율

    // 턱선 각도
    final jawAngle = _computeJawlineAngle(face);

    // 대칭도
    final symmetry = _computeSymmetry(face);

    return FaceMeasurements(
      faceShape: faceShape,
      upperThird: upper,
      middleThird: middle,
      lowerThird: lower,
      eyeSpacing: eyeSpacing,
      eyeSlant: eyeSlant,
      eyeSize: eyeSize,
      noseBridgeHeight: noseBridge,
      noseWidth: noseWidth,
      mouthWidth: mouthWidth,
      lipThickness: lipThickness,
      eyebrowArch: browArch,
      eyebrowThickness: browThickness,
      foreheadHeight: foreheadHeight,
      jawlineAngle: jawAngle,
      faceSymmetry: symmetry,
      faceLengthRatio: lengthRatio,
    );
  }

  String _classifyFaceShape(double ratio, Face face) {
    final jaw = _computeJawlineAngle(face);

    if (ratio < 1.15) return 'round';
    if (ratio > 1.5) return 'long';
    if (jaw > 0.7) return 'square';
    if (jaw < 0.3 && ratio > 1.2) return 'heart';
    if (ratio > 1.3 && jaw > 0.4 && jaw < 0.6) return 'diamond';
    return 'oval';
  }

  (double, double, double) _computeThirds(Face face, double faceHeight) {
    // 랜드마크 기반 삼정 계산
    final topY = face.boundingBox.top;
    final bottomY = face.boundingBox.bottom;

    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];

    if (leftEye == null || noseBase == null) {
      return (0.33, 0.34, 0.33);
    }

    final eyeY = leftEye.position.y;
    final noseY = noseBase.position.y;

    final upper = (eyeY - topY) / faceHeight;
    final middle = (noseY - eyeY) / faceHeight;
    final lower = (bottomY - noseY) / faceHeight;

    final total = upper + middle + lower;
    return (upper / total, middle / total, lower / total);
  }

  (double, double, double) _computeEyeMetrics(Face face, double faceWidth) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    if (leftEye == null || rightEye == null) {
      return (0.5, 0.0, 0.5);
    }

    // 미간 거리 (눈 사이 거리 / 얼굴 너비)
    final eyeDist = (rightEye.position.x - leftEye.position.x).abs();
    final spacing = (eyeDist / faceWidth).clamp(0.0, 1.0);

    // 눈꼬리 각도
    final leftContour = face.contours[FaceContourType.leftEye];
    double slant = 0.0;
    if (leftContour != null && leftContour.points.length >= 2) {
      final inner = leftContour.points.first;
      final outer = leftContour.points[leftContour.points.length ~/ 2];
      slant = ((outer.y - inner.y) / faceWidth * 10).clamp(-1.0, 1.0);
    }

    // 눈 크기
    final leftEyeContour = face.contours[FaceContourType.leftEye];
    double eyeSize = 0.5;
    if (leftEyeContour != null && leftEyeContour.points.length >= 4) {
      final topmost = leftEyeContour.points.reduce((a, b) => a.y < b.y ? a : b);
      final bottommost = leftEyeContour.points.reduce((a, b) => a.y > b.y ? a : b);
      eyeSize = ((bottommost.y - topmost.y) / face.boundingBox.height * 5).clamp(0.0, 1.0);
    }

    return (spacing, slant, eyeSize);
  }

  (double, double) _computeNoseMetrics(Face face, double faceWidth, double faceHeight) {
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    final noseContour = face.contours[FaceContourType.noseBridge];
    final noseBottom = face.contours[FaceContourType.noseBottom];

    double bridgeHeight = 0.5;
    double width = 0.5;

    if (noseContour != null && noseContour.points.length >= 2) {
      final top = noseContour.points.first;
      final bottom = noseContour.points.last;
      bridgeHeight = ((bottom.y - top.y) / faceHeight * 3).clamp(0.0, 1.0);
    }

    if (noseBottom != null && noseBottom.points.length >= 2) {
      final left = noseBottom.points.first;
      final right = noseBottom.points.last;
      width = ((right.x - left.x) / faceWidth * 2.5).clamp(0.0, 1.0);
    }

    return (bridgeHeight, width);
  }

  (double, double) _computeMouthMetrics(Face face, double faceWidth, double faceHeight) {
    final mouthLeft = face.landmarks[FaceLandmarkType.leftMouth];
    final mouthRight = face.landmarks[FaceLandmarkType.rightMouth];
    final mouthBottom = face.landmarks[FaceLandmarkType.bottomMouth];

    double width = 0.5;
    double thickness = 0.5;

    if (mouthLeft != null && mouthRight != null) {
      width = ((mouthRight.position.x - mouthLeft.position.x) / faceWidth).clamp(0.0, 1.0);
    }

    final upperLip = face.contours[FaceContourType.upperLipTop];
    final lowerLip = face.contours[FaceContourType.lowerLipBottom];
    if (upperLip != null && lowerLip != null &&
        upperLip.points.isNotEmpty && lowerLip.points.isNotEmpty) {
      final topY = upperLip.points.map((p) => p.y).reduce(math.min);
      final bottomY = lowerLip.points.map((p) => p.y).reduce(math.max);
      thickness = ((bottomY - topY) / faceHeight * 5).clamp(0.0, 1.0);
    }

    return (width, thickness);
  }

  (double, double) _computeEyebrowMetrics(Face face, double faceHeight) {
    final leftBrow = face.contours[FaceContourType.leftEyebrowTop];

    double arch = 0.5;
    double thickness = 0.5;

    if (leftBrow != null && leftBrow.points.length >= 3) {
      final first = leftBrow.points.first;
      final mid = leftBrow.points[leftBrow.points.length ~/ 2];
      final last = leftBrow.points.last;

      // 아치: 중간점이 양끝보다 얼마나 위에 있는지
      final baseY = (first.y + last.y) / 2;
      arch = ((baseY - mid.y) / faceHeight * 10).clamp(0.0, 1.0);
    }

    final browTop = face.contours[FaceContourType.leftEyebrowTop];
    final browBottom = face.contours[FaceContourType.leftEyebrowBottom];
    if (browTop != null && browBottom != null &&
        browTop.points.isNotEmpty && browBottom.points.isNotEmpty) {
      final topY = browTop.points.map((p) => p.y).reduce(math.min);
      final bottomY = browBottom.points.map((p) => p.y).reduce(math.max);
      thickness = ((bottomY - topY) / faceHeight * 10).clamp(0.0, 1.0);
    }

    return (arch, thickness);
  }

  double _computeJawlineAngle(Face face) {
    final jawContour = face.contours[FaceContourType.face];

    if (jawContour == null || jawContour.points.length < 10) return 0.5;

    // 턱 끝 부분의 포인트들로 각도 계산
    final points = jawContour.points;
    final chin = points[points.length ~/ 2]; // 턱 끝
    final leftJaw = points[points.length ~/ 4];
    final rightJaw = points[(points.length * 3) ~/ 4];

    final leftAngle = math.atan2(
      (chin.y - leftJaw.y).abs().toDouble(),
      (chin.x - leftJaw.x).abs().toDouble(),
    );
    final rightAngle = math.atan2(
      (chin.y - rightJaw.y).abs().toDouble(),
      (chin.x - rightJaw.x).abs().toDouble(),
    );

    // 급한 각도 = 각진 턱, 완만한 각도 = 둥근 턱
    final avgAngle = (leftAngle + rightAngle) / 2;
    return (avgAngle / (math.pi / 2)).clamp(0.0, 1.0);
  }

  double _computeSymmetry(Face face) {
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour == null || faceContour.points.length < 6) return 0.8;

    final points = faceContour.points;
    final centerX = face.boundingBox.center.dx;

    double totalDiff = 0;
    int count = 0;

    // 좌우 대칭점의 거리 차이
    for (var i = 0; i < points.length ~/ 2; i++) {
      final left = points[i];
      final right = points[points.length - 1 - i];

      final leftDist = (left.x - centerX).abs();
      final rightDist = (right.x - centerX).abs();

      if (leftDist > 0 || rightDist > 0) {
        totalDiff += (leftDist - rightDist).abs() / math.max(leftDist, rightDist);
        count++;
      }
    }

    if (count == 0) return 0.8;
    return (1.0 - totalDiff / count).clamp(0.0, 1.0);
  }

  FaceMeasurements _averageMeasurements(List<FaceMeasurements> list) {
    final n = list.length;
    // 얼굴형은 가장 빈번한 것 선택
    final shapeCounts = <String, int>{};
    for (final m in list) {
      shapeCounts[m.faceShape] = (shapeCounts[m.faceShape] ?? 0) + 1;
    }
    final dominantShape = shapeCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    double avg(double Function(FaceMeasurements) selector) {
      return list.map(selector).reduce((a, b) => a + b) / n;
    }

    return FaceMeasurements(
      faceShape: dominantShape,
      upperThird: avg((m) => m.upperThird),
      middleThird: avg((m) => m.middleThird),
      lowerThird: avg((m) => m.lowerThird),
      eyeSpacing: avg((m) => m.eyeSpacing),
      eyeSlant: avg((m) => m.eyeSlant),
      eyeSize: avg((m) => m.eyeSize),
      noseBridgeHeight: avg((m) => m.noseBridgeHeight),
      noseWidth: avg((m) => m.noseWidth),
      mouthWidth: avg((m) => m.mouthWidth),
      lipThickness: avg((m) => m.lipThickness),
      eyebrowArch: avg((m) => m.eyebrowArch),
      eyebrowThickness: avg((m) => m.eyebrowThickness),
      foreheadHeight: avg((m) => m.foreheadHeight),
      jawlineAngle: avg((m) => m.jawlineAngle),
      faceSymmetry: avg((m) => m.faceSymmetry),
      faceLengthRatio: avg((m) => m.faceLengthRatio),
    );
  }

  /// 리소스 해제
  void dispose() {
    _detector.close();
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/gwansang/domain/services/
git commit -m "feat(gwansang): FaceAnalyzerService — ML Kit on-device 얼굴 분석"
```

---

## Task 5: DI 등록 + Riverpod Provider

**Files:**
- Modify: `lib/core/di/providers.dart`
- Create: `lib/features/gwansang/presentation/providers/gwansang_provider.dart`

**Step 1: DI 등록**

`lib/core/di/providers.dart`에 관상 섹션 추가 (Chat 섹션 아래):

```dart
// --- imports 추가 ---
import '../../features/gwansang/data/datasources/gwansang_remote_datasource.dart';
import '../../features/gwansang/data/repositories/gwansang_repository_impl.dart';
import '../../features/gwansang/domain/repositories/gwansang_repository.dart';

// =============================================================================
// Gwansang (관상)
// =============================================================================

/// 관상 데이터소스 Provider
@riverpod
GwansangRemoteDatasource gwansangRemoteDatasource(Ref ref) {
  return GwansangRemoteDatasource(ref.watch(supabaseHelperProvider));
}

/// 관상 Repository Provider
@riverpod
GwansangRepository gwansangRepository(Ref ref) {
  return GwansangRepositoryImpl(ref.watch(gwansangRemoteDatasourceProvider));
}
```

**Step 2: GwansangProvider (프레젠테이션 상태 관리)**

`lib/features/gwansang/presentation/providers/gwansang_provider.dart`:

```dart
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/face_measurements.dart';
import '../../domain/entities/gwansang_entity.dart';
import '../../domain/services/face_analyzer_service.dart';

part 'gwansang_provider.g.dart';

/// 관상 분석 결과 (프레젠테이션용)
class GwansangAnalysisResult {
  const GwansangAnalysisResult({
    required this.profile,
    required this.isNewAnalysis,
  });

  final GwansangProfile profile;
  final bool isNewAnalysis;
}

/// 관상 분석 상태 관리
@riverpod
class GwansangAnalysisNotifier extends _$GwansangAnalysisNotifier {
  FaceAnalyzerService? _faceAnalyzer;

  @override
  FutureOr<GwansangAnalysisResult?> build() {
    ref.onDispose(() => _faceAnalyzer?.dispose());
    return null;
  }

  /// 전체 관상 분석 실행
  ///
  /// 1. ML Kit으로 얼굴 측정 (on-device)
  /// 2. 사진 업로드 (Storage)
  /// 3. AI 해석 생성 (Edge Function)
  /// 4. DB 저장
  Future<void> analyze({
    required String userId,
    required List<String> photoLocalPaths,
    required Map<String, dynamic> sajuData,
    required String gender,
    required int age,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 1. On-device 얼굴 분석
      _faceAnalyzer ??= FaceAnalyzerService();

      final images = photoLocalPaths.map((p) => File(p)).toList();
      final measurements = await _faceAnalyzer!.analyzeMultiple(images);

      if (measurements == null) {
        throw Exception('얼굴을 감지하지 못했어요. 정면 사진으로 다시 시도해주세요.');
      }

      // 2-4. Repository 통해 업로드 + AI 해석 + 저장
      final repository = ref.read(gwansangRepositoryProvider);
      final profile = await repository.analyzeGwansang(
        userId: userId,
        photoLocalPaths: photoLocalPaths,
        measurements: measurements,
        sajuData: sajuData,
        gender: gender,
        age: age,
      );

      return GwansangAnalysisResult(
        profile: profile,
        isNewAnalysis: true,
      );
    });
  }

  /// 기존 관상 프로필 로드 (이미 분석한 경우)
  Future<void> loadExisting(String userId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(gwansangRepositoryProvider);
      final profile = await repository.getGwansangProfile(userId);

      if (profile == null) return null;

      return GwansangAnalysisResult(
        profile: profile,
        isNewAnalysis: false,
      );
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

/// 사진 유효성 검증 Provider
@riverpod
class PhotoValidator extends _$PhotoValidator {
  FaceAnalyzerService? _analyzer;

  @override
  FutureOr<bool?> build() {
    ref.onDispose(() => _analyzer?.dispose());
    return null;
  }

  /// 사진에서 얼굴이 감지되는지 검증
  Future<bool> validate(String path) async {
    _analyzer ??= FaceAnalyzerService();
    return _analyzer!.validatePhoto(File(path));
  }
}
```

**Step 3: build_runner 실행**

Run: `cd /Users/noah/saju-app && dart run build_runner build --delete-conflicting-outputs`
Expected: `providers.g.dart`, `gwansang_provider.g.dart` 생성

**Step 4: Commit**

```bash
git add lib/core/di/providers.dart lib/features/gwansang/presentation/providers/
git commit -m "feat(gwansang): DI 등록 + Riverpod Provider"
```

---

## Task 6: 라우트 등록 + 사주 결과 페이지 연결

**Files:**
- Modify: `lib/app/routes/app_router.dart:75-82` (publicPaths)
- Modify: `lib/app/routes/app_router.dart:243-250` (라우트 추가)
- Modify: `lib/features/saju/presentation/pages/saju_result_page.dart:376` (네비게이션 변경)

**Step 1: app_router.dart에 import 추가**

```dart
import '../../features/gwansang/presentation/pages/gwansang_bridge_page.dart';
import '../../features/gwansang/presentation/pages/gwansang_photo_page.dart';
import '../../features/gwansang/presentation/pages/gwansang_analysis_page.dart';
import '../../features/gwansang/presentation/pages/gwansang_result_page.dart';
import '../../features/gwansang/presentation/providers/gwansang_provider.dart';
```

**Step 2: publicPaths에 관상 경로 추가**

`app_router.dart:75-82`의 publicPaths에 추가:
```dart
RoutePaths.gwansangBridge,
RoutePaths.gwansangPhoto,
RoutePaths.gwansangAnalysis,
RoutePaths.gwansangResult,
```

**Step 3: 관상 라우트 4개 등록**

`app_router.dart`의 사주 결과 라우트 뒤(line 243 이후)에 추가:

```dart
      // --- 관상 퍼널 ---

      // 관상 브릿지 (사주 결과 → 관상 유도)
      GoRoute(
        path: RoutePaths.gwansangBridge,
        name: RouteNames.gwansangBridge,
        builder: (context, state) {
          final sajuResult = state.extra as SajuAnalysisResult?;
          return GwansangBridgePage(sajuResult: sajuResult);
        },
      ),

      // 관상 사진 업로드
      GoRoute(
        path: RoutePaths.gwansangPhoto,
        name: RouteNames.gwansangPhoto,
        builder: (context, state) {
          final sajuResult = state.extra as SajuAnalysisResult?;
          return GwansangPhotoPage(sajuResult: sajuResult);
        },
      ),

      // 관상 분석 (로딩 애니메이션)
      GoRoute(
        path: RoutePaths.gwansangAnalysis,
        name: RouteNames.gwansangAnalysis,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return GwansangAnalysisPage(analysisData: data);
        },
      ),

      // 관상 결과 (동물상 리빌)
      GoRoute(
        path: RoutePaths.gwansangResult,
        name: RouteNames.gwansangResult,
        builder: (context, state) {
          final result = state.extra as GwansangAnalysisResult?;
          return GwansangResultPage(result: result);
        },
      ),
```

**Step 4: 사주 결과 페이지 네비게이션 변경**

`saju_result_page.dart:376`을 수정:

변경 전:
```dart
onPressed: () => context.go(RoutePaths.matchingProfile),
```

변경 후:
```dart
onPressed: () => context.go(RoutePaths.gwansangBridge, extra: widget.result),
```

버튼 텍스트도 변경:
```dart
label: '내 관상도 알아보기',  // "운명의 인연 찾으러 가기" → "내 관상도 알아보기"
leadingIcon: Icons.face_retouching_natural,  // Icons.favorite → face icon
```

**주의:** 이 단계에서는 관상 페이지 파일들이 아직 없으므로, Task 7-10에서 생성할 때까지 임시 플레이스홀더를 만들어두거나, Task 7-10과 함께 커밋한다.

**Step 5: Commit**

```bash
git add lib/app/routes/app_router.dart lib/features/saju/presentation/pages/saju_result_page.dart
git commit -m "feat(gwansang): 라우트 등록 + 사주 결과→관상 연결"
```

---

## Task 7: 관상 브릿지 페이지

**Files:**
- Create: `lib/features/gwansang/presentation/pages/gwansang_bridge_page.dart`

**Step 1: 브릿지 페이지 구현**

사주 결과 직후, "관상까지 더하면 운명이 더 정확해져요"로 유도하는 화면.
기존 SajuCharacterBubble, SajuButton 위젯 재사용.

`lib/features/gwansang/presentation/pages/gwansang_bridge_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/tokens/saju_animation.dart';
import '../../../../core/theme/tokens/saju_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../saju/presentation/providers/saju_provider.dart';

/// 관상 브릿지 페이지 — 사주 결과 → 관상 퍼널 유도
///
/// "사주에 관상까지 더하면 운명이 더 정확해져요"
/// 관상의 가치를 설명하고, 무료임을 강조하여 전환 유도.
class GwansangBridgePage extends StatefulWidget {
  const GwansangBridgePage({super.key, this.sajuResult});

  final SajuAnalysisResult? sajuResult;

  @override
  State<GwansangBridgePage> createState() => _GwansangBridgePageState();
}

class _GwansangBridgePageState extends State<GwansangBridgePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: SajuAnimation.entrance);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: SajuAnimation.entrance));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterName = widget.sajuResult?.characterName ?? '나무리';
    final characterAsset = widget.sajuResult?.characterAssetPath ??
        CharacterAssets.namuriWoodDefault;
    final elementColor = SajuColor.fromElement(
      widget.sajuResult?.profile.dominantElement?.name,
    );

    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        backgroundColor: context.sajuColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: SajuSpacing.page,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 캐릭터 안내
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: SajuCharacterBubble(
                      characterName: characterName,
                      message: '사주를 봤으니 이제 관상도 볼까?\n'
                          '얼굴에서 보이는 운명의 기운을 읽어줄게!',
                      elementColor: elementColor,
                      characterAssetPath: characterAsset,
                      size: SajuSize.lg,
                    ),
                  ),
                ),

                SajuSpacing.gap32,

                // 가치 제안 카드
                FadeTransition(
                  opacity: _fadeIn,
                  child: SajuCard(
                    variant: SajuVariant.elevated,
                    content: Column(
                      children: [
                        Icon(
                          Icons.face_retouching_natural,
                          size: 48,
                          color: AppTheme.mysticGlow,
                        ),
                        SajuSpacing.gap16,
                        Text(
                          'AI 관상 분석',
                          style: context.sajuTypo.heading1,
                        ),
                        SajuSpacing.gap8,
                        Text(
                          '사진 3장으로 당신의 관상을 읽어드려요\n'
                          '사주와 관상을 함께 보면 운명이 더 선명해져요',
                          textAlign: TextAlign.center,
                          style: context.sajuTypo.body2.copyWith(
                            color: context.sajuColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        SajuSpacing.gap16,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.mysticGlow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '✨ 무료',
                            style: context.sajuTypo.caption1.copyWith(
                              color: AppTheme.mysticGlow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    padding: SajuSpacing.cardInner,
                  ),
                ),

                const Spacer(flex: 3),

                // CTA 버튼
                SajuButton(
                  label: '내 관상 알아보기',
                  onPressed: () => context.go(
                    RoutePaths.gwansangPhoto,
                    extra: widget.sajuResult,
                  ),
                  variant: SajuVariant.filled,
                  color: SajuColor.primary,
                  size: SajuSize.lg,
                  leadingIcon: Icons.camera_alt_outlined,
                ),
                SajuSpacing.gap12,
                SajuButton(
                  label: '나중에 할게요',
                  onPressed: () => context.go(RoutePaths.matchingProfile),
                  variant: SajuVariant.ghost,
                  color: SajuColor.primary,
                  size: SajuSize.sm,
                ),

                SajuSpacing.gap16,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/gwansang/presentation/pages/gwansang_bridge_page.dart
git commit -m "feat(gwansang): 관상 브릿지 페이지 — 사주→관상 전환 유도"
```

---

## Task 8: 관상 사진 업로드 페이지

**Files:**
- Create: `lib/features/gwansang/presentation/pages/gwansang_photo_page.dart`

**핵심:** 사진 3장을 "관상 정확도를 위해" 수집. 각 사진마다 가이드 제공.
- 정면 사진: "이목구비 분석을 위해 정면 사진이 필요해요"
- 미소 사진: "웃을 때 관상이 진짜 관상! 자연스러운 미소를 보여주세요"
- 상반신 사진: "전체 인상을 분석하기 위해 상반신 사진이 필요해요"

3장 모두 업로드하면 다음으로 넘어감.
image_picker로 카메라/갤러리 선택.
ML Kit으로 얼굴 감지 여부 실시간 체크 (감지 안 되면 재촬영 안내).

이 페이지는 기존 matching_profile_page.dart의 Step 1 (사진 업로드)과 유사한 패턴이지만,
관상 프레이밍으로 3장에 집중하는 전용 UX.

**코드 길이 관계상 핵심 구조만 기술:**

```dart
/// 3단계 사진 업로드: 정면 → 미소 → 상반신
/// 각 단계마다 캐릭터 가이드 + 사진 프리뷰 + 유효성 검증
class GwansangPhotoPage extends ConsumerStatefulWidget { ... }

// 내부 상태:
// - _currentPhotoIndex (0-2)
// - _photoPaths: List<String?>.filled(3, null)
// - _isValidating: bool (ML Kit 검증 중)
//
// 각 사진 업로드 후 PhotoValidator.validate() 호출
// → 얼굴 미감지 시 SnackBar + 재촬영 유도
// → 3장 모두 완료 시 "관상 분석 시작" CTA 활성화
// → CTA 클릭 시 context.go(RoutePaths.gwansangAnalysis, extra: analysisData)
//   analysisData = {
//     'userId': ...,
//     'photoLocalPaths': _photoPaths,
//     'sajuResult': widget.sajuResult,
//     'gender': ...,
//     'age': ...,
//   }
```

**Step 2: Commit**

```bash
git add lib/features/gwansang/presentation/pages/gwansang_photo_page.dart
git commit -m "feat(gwansang): 사진 업로드 페이지 — 3장 가이드 + 얼굴 검증"
```

---

## Task 9: 관상 분석 로딩 페이지

**Files:**
- Create: `lib/features/gwansang/presentation/pages/gwansang_analysis_page.dart`

**핵심:** 사주 분석 페이지(`saju_analysis_page.dart`)와 동일한 패턴의 로딩 애니메이션.
분석이 완료되면 자동으로 결과 페이지로 이동.

```
애니메이션 시퀀스 (8-12초 연출):
1. (0-2초) 캐릭터 등장 + "관상을 읽고 있어요..."
2. (2-4초) 사진에서 얼굴 포인트 스캔하는 연출
3. (4-6초) "삼정(이마/눈/턱) 분석 중..."
4. (6-8초) "오행 기운과 교차 분석 중..."
5. (8-10초) 동물상 실루엣 서서히 등장
6. (분석 완료 시) 자동 이동 → gwansang_result
```

실제 API 호출은 페이지 진입 시 즉시 시작.
애니메이션은 최소 8초 보장 (API가 더 빨리 끝나도 기다림).

```dart
class GwansangAnalysisPage extends ConsumerStatefulWidget { ... }

// initState에서:
// 1. ref.read(gwansangAnalysisNotifierProvider.notifier).analyze(...)
// 2. _startAnimationSequence()
// 3. 둘 다 완료되면 context.go(RoutePaths.gwansangResult, extra: result)
```

**Step 2: Commit**

```bash
git add lib/features/gwansang/presentation/pages/gwansang_analysis_page.dart
git commit -m "feat(gwansang): 관상 분석 로딩 페이지 — 8초 연출 + 실시간 분석"
```

---

## Task 10: 관상 결과 페이지 (동물상 리빌)

**Files:**
- Create: `lib/features/gwansang/presentation/pages/gwansang_result_page.dart`
- Create: `lib/features/gwansang/presentation/widgets/animal_type_hero.dart`
- Create: `lib/features/gwansang/presentation/widgets/face_reading_section.dart`

**핵심:** 가장 중요한 WOW 모먼트 + 바이럴 공유 화면.

```
레이아웃:
1. 동물상 히어로 (대형 이모지 + 타입명 + 오행 수식어)
   → "🐱 도도한 고양이상" + "木 기운의 신비로운 매력가"
   → 바운스 애니메이션으로 등장
   → [📸 카드 저장] [📤 공유하기] CTA 즉시 노출

2. 헤드라인 (1줄)
   → "타고난 리더형 관상, 눈빛에 결단력이 서려 있어요"

3. 매력 키워드 (3개 Chip)
   → SajuChip으로 표시

4. 성격 요약
   → SajuCard + body1 텍스트

5. 연애 스타일
   → SajuCard + body1 텍스트

6. 사주 × 관상 시너지
   → SajuCard + 교차 검증 메시지

7. 궁합 힌트
   → "찰떡궁합: 충직한 강아지상 🐶"
   → "밀당궁합: 자유로운 늑대상 🐺"

8. 액션 버튼
   → "운명의 인연 찾으러 가기" → matchingProfile
   → "내 관상 공유하기" → TODO: 공유 기능
   → "나중에 할게요" → home
```

**테마:** `AppTheme.dark` (신비로운 분위기)

**애니메이션:** 기존 `_ResultRevealContent` 패턴 재사용 (1400ms, 0.14 stagger)

**Step 2: Commit**

```bash
git add lib/features/gwansang/presentation/pages/ lib/features/gwansang/presentation/widgets/
git commit -m "feat(gwansang): 관상 결과 페이지 — 동물상 리빌 + 바이럴 공유"
```

---

## Task 11: 매칭 프로필 사진 스킵 통합

**Files:**
- Modify: `lib/features/profile/presentation/pages/matching_profile_page.dart`

**핵심:** 관상에서 이미 사진 3장을 업로드했으면, 매칭 프로필 Step 1(사진)을 자동으로 채우거나 스킵.

**Step 1: 관상 사진 존재 여부 체크**

`_MatchingProfilePageState.initState()`에서:
```dart
// 관상에서 업로드한 사진이 있으면 자동 채움
final gwansangProfile = ref.read(/* gwansang profile provider */);
if (gwansangProfile?.photoUrls.isNotEmpty == true) {
  // _photoSlots 자동 채움 + Step 2부터 시작
  _currentStep = 1; // Step 1(사진) 스킵
  _pageController = PageController(initialPage: 1);
}
```

**Step 2: 사진 스킵 시 진행률 보정**

기존 40% base → 52% base (사진 단계 자동 완료)

**Step 3: Commit**

```bash
git add lib/features/profile/presentation/pages/matching_profile_page.dart
git commit -m "feat(gwansang): 매칭 프로필 사진 스킵 — 관상 사진 자동 연동"
```

---

## Task 12: Supabase 마이그레이션 + Edge Function

**Files:**
- Create: `supabase/migrations/20260225100000_gwansang_profiles.sql`
- Create: `supabase/functions/generate-gwansang-reading/index.ts`

**Step 1: DB 마이그레이션**

```sql
-- gwansang_profiles 테이블
CREATE TABLE IF NOT EXISTS public.gwansang_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  animal_type text NOT NULL,
  face_measurements jsonb NOT NULL DEFAULT '{}',
  photo_urls text[] NOT NULL DEFAULT '{}',
  headline text NOT NULL DEFAULT '',
  personality_summary text NOT NULL DEFAULT '',
  romance_summary text NOT NULL DEFAULT '',
  saju_synergy text NOT NULL DEFAULT '',
  charm_keywords text[] NOT NULL DEFAULT '{}',
  element_modifier text,
  detailed_reading text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- profiles 테이블에 관상 컬럼 추가
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS gwansang_profile_id uuid REFERENCES public.gwansang_profiles(id),
  ADD COLUMN IF NOT EXISTS animal_type text,
  ADD COLUMN IF NOT EXISTS is_gwansang_complete boolean NOT NULL DEFAULT false;

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_gwansang_profiles_user_id ON public.gwansang_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_animal_type ON public.profiles(animal_type);

-- RLS
ALTER TABLE public.gwansang_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own gwansang" ON public.gwansang_profiles
  FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own gwansang" ON public.gwansang_profiles
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own gwansang" ON public.gwansang_profiles
  FOR UPDATE USING (auth.uid()::text = user_id::text);

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION update_gwansang_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gwansang_updated_at
  BEFORE UPDATE ON public.gwansang_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_gwansang_updated_at();

-- Storage 버킷
INSERT INTO storage.buckets (id, name, public)
VALUES ('gwansang-photos', 'gwansang-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS
CREATE POLICY "Users can upload own gwansang photos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'gwansang-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Anyone can view gwansang photos" ON storage.objects
  FOR SELECT USING (bucket_id = 'gwansang-photos');
```

**Step 2: Edge Function**

`supabase/functions/generate-gwansang-reading/index.ts`:

Edge Function은 Claude Haiku 4.5를 호출하여 관상 해석을 생성.
입력: face_measurements (JSON) + saju_data + gender + age
출력: animal_type, headline, personality_summary, romance_summary, saju_synergy, charm_keywords, element_modifier, detailed_reading

프롬프트는 "도현 선생" 페르소나 (30년 경력 관상 전문가) + 관상학 삼정/오관 프레임워크.
결과는 80% 긍정 / 20% 성장 포인트 비율.

**Step 3: Commit**

```bash
git add supabase/
git commit -m "feat(gwansang): DB 마이그레이션 + Edge Function"
```

---

## Task 13: flutter analyze + 통합 테스트

**Step 1: flutter analyze 실행**

Run: `cd /Users/noah/saju-app && flutter analyze`
Expected: 0 errors

**Step 2: import 정리 + 누락 export 체크**

**Step 3: 전체 빌드 확인**

Run: `flutter build apk --debug` (빌드 성공 여부 확인)

**Step 4: Commit + Push**

```bash
git add -A
git commit -m "feat(gwansang): 통합 검증 완료 — flutter analyze 통과"
git push origin main
```

---

## 요약

| Task | 내용 | 새 파일 | 수정 파일 |
|------|------|---------|----------|
| 1 | 패키지 + 상수 | - | pubspec.yaml, app_constants.dart |
| 2 | 도메인 엔티티 | 3개 | - |
| 3 | Data 레이어 | 4개 | - |
| 4 | Face Analysis Service | 1개 | - |
| 5 | DI + Provider | 1개 | providers.dart |
| 6 | 라우트 + 연결 | - | app_router.dart, saju_result_page.dart |
| 7 | 브릿지 페이지 | 1개 | - |
| 8 | 사진 업로드 페이지 | 1개 | - |
| 9 | 분석 로딩 페이지 | 1개 | - |
| 10 | 결과 페이지 + 위젯 | 3개 | - |
| 11 | 매칭 프로필 통합 | - | matching_profile_page.dart |
| 12 | Supabase (DB + Edge Function) | 2개 | - |
| 13 | 통합 검증 | - | - |

**총: 새 파일 ~17개, 수정 파일 ~6개, 13개 Task**
