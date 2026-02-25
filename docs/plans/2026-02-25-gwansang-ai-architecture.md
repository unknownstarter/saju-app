# AI 관상 (Face Reading) Feature -- Technical Architecture

> **Author**: Ari (Technical Architecture Agent)
> **Date**: 2026-02-25
> **Status**: Architecture Design (Pre-Implementation)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Package Selection & Rationale](#2-package-selection--rationale)
3. [Data Flow Pipeline](#3-data-flow-pipeline)
4. [On-Device Face Analysis (MediaPipe/ML Kit)](#4-on-device-face-analysis)
5. [Face Measurement Computation for 관상](#5-face-measurement-computation)
6. [AI Interpretation Layer](#6-ai-interpretation-layer)
7. [Photo Quality Validation](#7-photo-quality-validation)
8. [Performance & Cost Estimates](#8-performance--cost-estimates)
9. [Flutter Implementation Architecture](#9-flutter-implementation-architecture)
10. [Privacy & Security](#10-privacy--security)
11. [Key Code Snippets](#11-key-code-snippets)
12. [Risk Analysis & Mitigations](#12-risk-analysis--mitigations)

---

## 1. Architecture Overview

### Text-Based Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP (Client)                        │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────────────────┐  │
│  │  Photo Layer  │    │  ML Kit      │    │  관상 Presentation    │  │
│  │              │    │  Processing   │    │                       │  │
│  │ image_picker │───▶│  (On-Device)  │───▶│ GwansangResultPage   │  │
│  │ image_cropper│    │              │    │ FaceAnalysisWidget    │  │
│  │ camera       │    │ Face Detect  │    │ GwansangCard          │  │
│  └──────────────┘    │ Contours     │    └───────────────────────┘  │
│                       │ Landmarks    │              ▲                │
│                       │ Classification│              │                │
│                       └──────┬───────┘              │                │
│                              │                       │                │
│                     structured JSON            result JSON           │
│                     (measurements)           (interpretation)        │
│                              │                       │                │
│                              ▼                       │                │
│                    ┌─────────────────┐               │                │
│                    │  Gwansang       │               │                │
│                    │  Measurement    │               │                │
│                    │  Computer       │               │                │
│                    │  (Pure Dart)    │               │                │
│                    └────────┬────────┘               │                │
│                             │                        │                │
└─────────────────────────────┼────────────────────────┼────────────────┘
                              │                        │
                              ▼                        │
┌─────────────────────────────────────────────────────────────────────┐
│                     SUPABASE EDGE FUNCTIONS                         │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  generate-gwansang-insight                                   │    │
│  │                                                               │    │
│  │  Input:                                                       │    │
│  │  ├── face_measurements: { ... structured JSON ... }          │    │
│  │  ├── saju_profile: { pillars, five_elements, dominant }      │    │
│  │  └── user_name: string                                       │    │
│  │                                                               │    │
│  │  Processing:                                                  │    │
│  │  ├── 1. Validate measurements                                │    │
│  │  ├── 2. Construct 관상 + 사주 combined prompt                 │    │
│  │  ├── 3. Call Claude API (Haiku 4.5)                          │    │
│  │  └── 4. Parse & return structured result                     │    │
│  │                                                               │    │
│  │  Output:                                                      │    │
│  │  ├── gwansang_reading: string (관상 해석문)                   │    │
│  │  ├── face_traits: string[] (성격 키워드)                      │    │
│  │  ├── combined_insight: string (사주+관상 통합 인사이트)        │    │
│  │  ├── love_fortune: string (연애운)                            │    │
│  │  └── compatibility_hints: string[] (궁합 힌트)               │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  save-gwansang-profile                                       │    │
│  │  (measurements + interpretation → gwansang_profiles table)   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     SUPABASE POSTGRESQL                              │
│                                                                     │
│  gwansang_profiles                                                  │
│  ├── id (uuid, PK)                                                  │
│  ├── user_id (uuid, FK → profiles)                                 │
│  ├── face_measurements (jsonb)     -- structured measurements      │
│  ├── face_shape (text)             -- oval/round/square/heart/long │
│  ├── gwansang_reading (text)       -- AI 관상 해석문                │
│  ├── face_traits (text[])          -- 성격 키워드                   │
│  ├── combined_insight (text)       -- 사주+관상 통합 인사이트       │
│  ├── love_fortune (text)           -- 연애운                        │
│  ├── compatibility_hints (text[])  -- 궁합 힌트                    │
│  ├── photo_hash (text)             -- 사진 변경 감지용 해시        │
│  ├── created_at (timestamptz)                                       │
│  └── updated_at (timestamptz)                                       │
│                                                                     │
│  RLS: 본인만 조회/수정 가능                                         │
└─────────────────────────────────────────────────────────────────────┘
```

### Core Design Principles

1. **Privacy-First**: Raw photos NEVER leave the device. Only computed measurements (numbers/ratios) are sent to the server.
2. **On-Device ML**: Face detection and landmark extraction run entirely on-device via Google ML Kit.
3. **Coherent 사주+관상**: The AI interprets face measurements in context of the user's saju profile, producing a unified narrative -- not two separate readings.
4. **Cost Efficiency**: Use Haiku 4.5 for 관상 interpretation (sufficient quality for structured-input interpretation).

---

## 2. Package Selection & Rationale

### Primary Package: `google_mlkit_face_detection` v0.13.2

| Criterion | `google_mlkit_face_detection` | `google_mlkit_face_mesh_detection` | Direct MediaPipe |
|-----------|------|---------|--------|
| **iOS Support** | YES | NO (Android only) | Complex setup |
| **Android Support** | YES | YES | YES |
| **Landmark Count** | 10 landmarks + 15 contour types | 468 3D points | 478 points |
| **Flutter Integration** | Native plugin (pub.dev) | Native plugin (pub.dev) | Platform channels needed |
| **Maturity** | Stable, v0.13.2 | Beta, v0.4.2 | Requires custom bridges |
| **Sufficient for 관상?** | YES (see analysis below) | Overkill | Overkill |

**Decision: `google_mlkit_face_detection`**

Rationale:
- Cross-platform (iOS + Android) is mandatory for a dating app
- The 10 landmarks + 15 contour types provide sufficient data for all 관상 measurements
- Face contours provide point arrays (not just single points), giving detailed shape information for eyes, eyebrows, nose, lips, jawline, and face outline
- Face Mesh (468 points) would be ideal but is Android-only -- a dealbreaker
- Direct MediaPipe requires building custom platform channels, adding maintenance burden with no significant quality gain

### Full Package List

```yaml
# pubspec.yaml additions for 관상 feature

dependencies:
  # --- Face Analysis (On-Device ML) ---
  google_mlkit_face_detection: ^0.13.2    # Face detection + contours + landmarks
  google_mlkit_commons: ^0.8.0            # Shared types (InputImage, etc.)

  # --- Photo Capture & Processing ---
  image_picker: ^1.1.2                    # Camera/gallery photo selection
  image_cropper: ^8.0.2                   # Face-area cropping with guide overlay
  image: ^4.5.3                           # Image manipulation (resize, normalize)

  # --- Crypto (photo hashing) ---
  crypto: ^3.0.6                          # SHA-256 hash for photo change detection
```

### Contour Types Available (15 total)

These contour types each return an array of `Point<int>` values:

| Contour Type | Points | 관상 Usage |
|---|---|---|
| `face` | ~36 points | Face shape (얼굴형), symmetry |
| `leftEye` | ~16 points | Eye shape, size |
| `rightEye` | ~16 points | Eye shape, size |
| `leftEyebrowTop` | ~5 points | Eyebrow arch, length |
| `leftEyebrowBottom` | ~5 points | Eyebrow thickness |
| `rightEyebrowTop` | ~5 points | Eyebrow arch, length |
| `rightEyebrowBottom` | ~5 points | Eyebrow thickness |
| `upperLipTop` | ~11 points | Lip shape, width |
| `upperLipBottom` | ~9 points | Lip thickness |
| `lowerLipTop` | ~9 points | Lip ratio |
| `lowerLipBottom` | ~9 points | Mouth size |
| `noseBridge` | ~2 points | Nose bridge height |
| `noseBottom` | ~3 points | Nose width, tip shape |
| `leftCheek` | ~1 point | Face width |
| `rightCheek` | ~1 point | Face width |

### Landmark Types Available (10 total)

| Landmark | 관상 Usage |
|---|---|
| `leftEye` | Eye center position |
| `rightEye` | Eye center position, spacing |
| `leftEar` | Face width measurement |
| `rightEar` | Face width measurement |
| `leftMouth` | Mouth width |
| `rightMouth` | Mouth width |
| `bottomMouth` | Lower lip position, chin distance |
| `noseBase` | Nose position, face center |
| `leftCheek` | Cheek prominence |
| `rightCheek` | Cheek prominence |

### Classifications Available

| Classification | 관상 Usage |
|---|---|
| `smilingProbability` | Expression baseline |
| `leftEyeOpenProbability` | Eye symmetry |
| `rightEyeOpenProbability` | Eye symmetry |
| `headEulerAngleX` | Head tilt (quality check) |
| `headEulerAngleY` | Head rotation (quality check) |
| `headEulerAngleZ` | Head tilt (quality check) |

---

## 3. Data Flow Pipeline

### End-to-End Flow

```
User taps "관상 분석하기"
         │
         ▼
┌─ STEP 1: Photo Capture ─────────────────────────────────────────┐
│  ┌─ Camera OR Gallery ──┐    ┌─ Quality Gate ──────────────────┐ │
│  │ image_picker          │───▶│ 1. Face detected?              │ │
│  │ preferredCameraDevice │    │ 2. Face size > 20% of image?   │ │
│  │ = CameraDevice.front  │    │ 3. Head angle < 15 degrees?    │ │
│  │ maxWidth: 1080        │    │ 4. Both eyes open?             │ │
│  │ imageQuality: 85      │    │ 5. Lighting adequate?          │ │
│  └───────────────────────┘    └──────────┬─────────────────────┘ │
│                                    PASS │ FAIL → retry guidance  │
│                                          ▼                       │
│                               ┌─ Face Crop ─────┐               │
│                               │ Auto-crop to     │               │
│                               │ face bounding    │               │
│                               │ box + 30% margin │               │
│                               └────────┬────────┘               │
│                                        ▼                         │
│                               Repeat for 3 photos               │
│                               (front, slight-left, slight-right) │
└──────────────────────────────────────────────────────────────────┘
         │
         ▼  (3 validated face images, on-device only)
┌─ STEP 2: ML Kit Processing (On-Device) ─────────────────────────┐
│  For each photo:                                                  │
│  ├── FaceDetector.processImage(inputImage)                       │
│  ├── Extract: 10 landmarks, 15 contour types, classifications   │
│  └── Store raw landmark/contour data                             │
│                                                                   │
│  Aggregate across 3 photos:                                       │
│  ├── Use frontal photo as PRIMARY (most reliable)                │
│  ├── Side photos for: nose bridge depth, jawline profile         │
│  └── Average measurements where applicable                       │
└──────────────────────────────────────────────────────────────────┘
         │
         ▼  (raw landmarks + contours for 3 photos)
┌─ STEP 3: 관상 Measurement Computation (On-Device, Pure Dart) ───┐
│  GwansangMeasurementComputer.compute(faceLandmarks) →            │
│  {                                                                │
│    "face_shape": "oval",                                         │
│    "sam_jeong": { "upper": 0.34, "middle": 0.33, "lower": 0.33 },│
│    "eyes": { "spacing_ratio": 0.28, "slant_angle": 3.2, ... },  │
│    "nose": { "bridge_ratio": 0.42, "width_ratio": 0.31, ... },  │
│    "mouth": { "width_ratio": 0.38, "lip_ratio": 0.55, ... },    │
│    "eyebrows": { "arch_height": 0.12, "thickness": 0.04, ... }, │
│    "forehead": { "height_ratio": 0.34, "width_ratio": 0.92 },   │
│    "jawline": { "angle": 125, "shape": "rounded" },             │
│    "symmetry": { "score": 87, "left_right_diff": 0.03 },        │
│    "overall_proportions": { ... }                                 │
│  }                                                                │
└──────────────────────────────────────────────────────────────────┘
         │
         ▼  (structured measurements JSON -- NO photos)
┌─ STEP 4: AI Interpretation (Server-Side) ────────────────────────┐
│  Supabase Edge Function: generate-gwansang-insight               │
│  Input:  measurements JSON + saju_profile                        │
│  LLM:    Claude Haiku 4.5 ($1/$5 per 1M tokens)                 │
│  Output: 관상 해석, 성격 키워드, 사주+관상 통합 인사이트,        │
│          연애운, 궁합 힌트                                        │
└──────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─ STEP 5: Result Display & Storage ───────────────────────────────┐
│  ├── Save to gwansang_profiles table                             │
│  ├── Link to user profile (profiles.gwansang_profile_id)         │
│  └── Display GwansangResultPage with animated reveal             │
└──────────────────────────────────────────────────────────────────┘
```

### Why 3 Photos?

| Photo | Purpose | What It Captures Best |
|---|---|---|
| **Frontal** (primary) | All measurements | Face shape, symmetry, eye/nose/mouth proportions, 삼정 |
| **Slight Left** (~15-20 deg) | Nose profile, jawline | Nose bridge height, jaw angle, ear position |
| **Slight Right** (~15-20 deg) | Cross-validation | Confirms left-side measurements, catches asymmetry |

**Aggregation Strategy**: Frontal photo is the primary data source for all 2D measurements. Side photos supplement with depth-related features (nose bridge prominence, jaw protrusion) and provide symmetry cross-validation. We do NOT average all measurements blindly -- each measurement uses the photo angle that provides the most reliable data for that specific measurement.

---

## 4. On-Device Face Analysis

### ML Kit Configuration

```dart
/// Optimal FaceDetector configuration for 관상 analysis
final faceDetectorOptions = FaceDetectorOptions(
  enableClassification: true,    // smiling/eye-open probability
  enableLandmarks: true,         // 10 facial landmark points
  enableContours: true,          // 15 contour types (point arrays)
  enableTracking: false,         // not needed for static photos
  performanceMode: FaceDetectorMode.accurate,  // accuracy over speed
  minFaceSize: 0.25,             // face must be >= 25% of image
);
```

### Processing Pipeline

```dart
/// Process a single photo and extract face data
Future<FaceAnalysisResult?> analyzePhoto(XFile photo) async {
  // 1. Convert to InputImage
  final inputImage = InputImage.fromFilePath(photo.path);

  // 2. Detect faces
  final faces = await _faceDetector.processImage(inputImage);

  // 3. Validate: exactly 1 face
  if (faces.isEmpty) throw NoFaceDetectedException();
  if (faces.length > 1) throw MultipleFacesDetectedException();

  final face = faces.first;

  // 4. Quality checks
  _validateFaceQuality(face);

  // 5. Extract all data
  return FaceAnalysisResult(
    boundingBox: face.boundingBox,
    landmarks: _extractLandmarks(face),
    contours: _extractContours(face),
    headEulerAngleX: face.headEulerAngleX,
    headEulerAngleY: face.headEulerAngleY,
    headEulerAngleZ: face.headEulerAngleZ,
    smilingProbability: face.smilingProbability,
    leftEyeOpenProbability: face.leftEyeOpenProbability,
    rightEyeOpenProbability: face.rightEyeOpenProbability,
  );
}
```

### Expected On-Device Performance

| Metric | Estimate | Notes |
|---|---|---|
| Face detection (per photo) | 200-400ms | Accurate mode, single face |
| Landmark + contour extraction | Included above | Same pass |
| Measurement computation | <50ms | Pure Dart math |
| Total per photo | ~300-450ms | On modern devices (iPhone 13+, Pixel 6+) |
| Total for 3 photos | ~1.0-1.5s | Sequential processing |
| Memory overhead | ~30-50MB | ML model loaded in memory |

---

## 5. Face Measurement Computation for 관상

### 관상학 Framework: 삼정(三停) + 오관(五官)

Korean physiognomy (관상학) analyzes faces through two primary frameworks:

**삼정 (Three Zones / Three Sections)**
```
┌───────────────────────────┐
│     上停 (상정/Upper)      │  이마 상단 ~ 눈썹: 초년운(~30세), 부모궁
│     Forehead to Eyebrows   │  지혜, 학업, 가문
├───────────────────────────┤
│     中停 (중정/Middle)      │  눈썹 ~ 코 끝: 중년운(30~50세)
│     Eyebrows to Nose Tip   │  사업, 의지, 결단력
├───────────────────────────┤
│     下停 (하정/Lower)       │  코 끝 ~ 턱: 만년운(50세~), 자녀궁
│     Nose Tip to Chin        │  재물, 건강, 복덕
└───────────────────────────┘

Ideal: 1:1:1 ratio (균형잡힌 삼정 = 고른 인생운)
```

**오관 (Five Features / Five Organs)**
1. **귀 (Ears)** -- 채청관(采聽官): 지혜, 장수
2. **눈썹 (Eyebrows)** -- 보수관(保壽官): 건강, 수명
3. **눈 (Eyes)** -- 감찰관(監察官): 부귀빈천 (얼굴이 천 냥이면 눈이 구백 냥)
4. **코 (Nose)** -- 심판관(審判官): 재물, 자존심
5. **입 (Mouth)** -- 출납관(出納官): 식록, 표현력

### Measurement Computation: Contour Points to 관상 Metrics

#### Output JSON Schema: `GwansangMeasurements`

```json
{
  "version": "1.0",
  "source_photos": 3,
  "primary_photo_index": 0,

  "face_shape": {
    "type": "oval",
    "confidence": 0.82,
    "width_height_ratio": 0.74,
    "jaw_forehead_ratio": 0.88,
    "description": "달걀형"
  },

  "sam_jeong": {
    "upper_ratio": 0.34,
    "middle_ratio": 0.33,
    "lower_ratio": 0.33,
    "balance_score": 95,
    "dominant_zone": "upper"
  },

  "eyes": {
    "left_width": 42,
    "right_width": 41,
    "spacing_ratio": 0.28,
    "slant_angle_left": 3.2,
    "slant_angle_right": 2.8,
    "size_category": "medium",
    "shape": "almond",
    "open_ratio_left": 0.35,
    "open_ratio_right": 0.36,
    "symmetry_score": 92
  },

  "eyebrows": {
    "left_length": 58,
    "right_length": 57,
    "arch_height_left": 8,
    "arch_height_right": 7,
    "thickness_left": 6,
    "thickness_right": 6,
    "shape": "natural_arch",
    "spacing_from_eye": 12,
    "symmetry_score": 90
  },

  "nose": {
    "bridge_length": 48,
    "bridge_width": 14,
    "tip_width": 32,
    "bridge_height_ratio": 0.42,
    "width_ratio": 0.31,
    "tip_shape": "rounded",
    "profile_angle": null
  },

  "mouth": {
    "width": 52,
    "upper_lip_height": 8,
    "lower_lip_height": 10,
    "lip_ratio": 0.44,
    "width_ratio": 0.38,
    "shape": "balanced",
    "corner_angle": 2.1
  },

  "forehead": {
    "height": 68,
    "width": 128,
    "height_ratio": 0.34,
    "width_to_face_ratio": 0.92,
    "shape": "rounded"
  },

  "jawline": {
    "width": 112,
    "angle_left": 125,
    "angle_right": 127,
    "shape": "rounded",
    "chin_prominence": "moderate",
    "jaw_to_forehead_ratio": 0.88
  },

  "symmetry": {
    "overall_score": 87,
    "eye_symmetry": 92,
    "eyebrow_symmetry": 90,
    "mouth_symmetry": 95,
    "face_centerline_deviation": 0.02
  },

  "proportions": {
    "golden_ratio_score": 78,
    "eye_spacing_to_face_width": 0.28,
    "nose_width_to_face_width": 0.24,
    "mouth_width_to_face_width": 0.38,
    "face_height_to_width": 1.35
  }
}
```

### Face Shape Classification Algorithm

```dart
/// Classify face shape from face contour points
FaceShapeType classifyFaceShape({
  required List<Point<int>> faceContour,  // ~36 points outlining face
  required Rect boundingBox,
}) {
  final faceWidth = boundingBox.width;
  final faceHeight = boundingBox.height;
  final ratio = faceWidth / faceHeight;

  // Measure jaw width vs forehead width
  // Face contour points go clockwise from chin
  final jawWidth = _measureWidthAtPercentage(faceContour, 0.75);  // 75% down
  final foreheadWidth = _measureWidthAtPercentage(faceContour, 0.15);  // 15% down
  final cheekWidth = _measureWidthAtPercentage(faceContour, 0.50);  // 50% down

  final jawToForeheadRatio = jawWidth / foreheadWidth;
  final cheekToJawRatio = cheekWidth / jawWidth;

  // Classification logic
  if (ratio > 0.85) {
    // Wide face
    if (jawToForeheadRatio > 0.95) return FaceShapeType.square;    // 사각형
    if (jawToForeheadRatio > 0.85) return FaceShapeType.round;     // 둥근형
  }

  if (ratio < 0.70) return FaceShapeType.long;                      // 긴 얼굴형

  if (jawToForeheadRatio < 0.75) return FaceShapeType.heart;       // 하트형 (V라인)

  if (cheekToJawRatio > 1.15 && jawToForeheadRatio < 0.85) {
    return FaceShapeType.diamond;                                    // 다이아몬드형
  }

  return FaceShapeType.oval;                                        // 달걀형 (기본)
}
```

### 삼정 (Three Zones) Computation

```dart
/// Compute 삼정 (Three Zone) proportions
SamJeongMeasurement computeSamJeong({
  required List<Point<int>> faceContour,
  required List<Point<int>> leftEyebrowTop,
  required List<Point<int>> rightEyebrowTop,
  required List<Point<int>> noseBottom,
  required Rect boundingBox,
}) {
  // Top of face (from face contour)
  final faceTop = faceContour
      .map((p) => p.y)
      .reduce((a, b) => a < b ? a : b);

  // Eyebrow line (average of left and right eyebrow tops)
  final eyebrowY = [
    ...leftEyebrowTop.map((p) => p.y),
    ...rightEyebrowTop.map((p) => p.y),
  ].reduce((a, b) => a + b) ~/ (leftEyebrowTop.length + rightEyebrowTop.length);

  // Nose bottom (average y of nose bottom contour)
  final noseBottomY = noseBottom
      .map((p) => p.y)
      .reduce((a, b) => a + b) ~/ noseBottom.length;

  // Chin (bottom of face contour)
  final chinY = faceContour
      .map((p) => p.y)
      .reduce((a, b) => a > b ? a : b);

  final totalHeight = (chinY - faceTop).toDouble();
  final upperHeight = (eyebrowY - faceTop).toDouble();
  final middleHeight = (noseBottomY - eyebrowY).toDouble();
  final lowerHeight = (chinY - noseBottomY).toDouble();

  return SamJeongMeasurement(
    upperRatio: upperHeight / totalHeight,
    middleRatio: middleHeight / totalHeight,
    lowerRatio: lowerHeight / totalHeight,
    balanceScore: _computeBalanceScore(upperHeight, middleHeight, lowerHeight),
  );
}

/// Balance score: 100 = perfect 1:1:1, lower = more imbalanced
int _computeBalanceScore(double upper, double middle, double lower) {
  final total = upper + middle + lower;
  final ideal = total / 3;
  final deviation = (upper - ideal).abs() + (middle - ideal).abs() + (lower - ideal).abs();
  final maxDeviation = total * 2 / 3;  // theoretical max
  return ((1 - deviation / maxDeviation) * 100).round().clamp(0, 100);
}
```

### Mapping Contour Points to 관상 Measurements

| 관상 Measurement | Contour Types Used | Computation |
|---|---|---|
| Face shape (얼굴형) | `face` | Width-height ratio + jaw/forehead/cheek width ratios |
| 삼정 balance | `face`, `leftEyebrowTop`, `rightEyebrowTop`, `noseBottom` | Y-coordinate ratios of upper/middle/lower zones |
| Eye spacing | `leftEye`, `rightEye` | Distance between inner corners / face width |
| Eye shape | `leftEye`, `rightEye` | Width/height ratio, slant angle from inner to outer corner |
| Eye size | `leftEye`, `rightEye` | Eye width / face width |
| Eyebrow arch | `leftEyebrowTop`, `leftEyebrowBottom` | Max height above eye / eyebrow length |
| Eyebrow thickness | `leftEyebrowTop`, `leftEyebrowBottom` | Average vertical distance between top and bottom contours |
| Nose bridge | `noseBridge` | Length from forehead to nose tip |
| Nose width | `noseBottom` | Width of nose bottom contour |
| Mouth width | `upperLipTop` or landmarks: `leftMouth`, `rightMouth` | Distance between mouth corners / face width |
| Lip ratio | `upperLipBottom`, `lowerLipTop` | Upper lip height / total lip height |
| Forehead height | `face`, `leftEyebrowTop` | Distance from face top to eyebrow line |
| Jawline shape | `face` (lower portion) | Angle and curvature of lower face contour |
| Symmetry | All bilateral contours | Left-right mirroring deviation |

---

## 6. AI Interpretation Layer

### Model Selection: Claude Haiku 4.5

**Rationale**:

| Factor | Haiku 4.5 | Sonnet 4.5 |
|---|---|---|
| Cost (input) | $1/M tokens | $3/M tokens |
| Cost (output) | $5/M tokens | $15/M tokens |
| Quality for structured input | Excellent | Better but unnecessary |
| Latency | ~1-2s | ~2-4s |
| **Cost per 관상 reading** | **~$0.003-0.005** | **~$0.009-0.015** |

Haiku 4.5 is the clear winner because:
1. Input is highly structured JSON (not ambiguous natural language)
2. The model follows a detailed prompt template -- creativity is guided
3. Quality difference between Haiku and Sonnet on structured interpretation tasks is minimal (<5%)
4. At scale (100K users), cost difference: Haiku ~$400 vs Sonnet ~$1,200

**Fallback**: If Haiku quality proves insufficient during testing, upgrade to Sonnet 4.5. The Edge Function can be switched without client changes.

### Token Estimates Per Request

```
Input:
  System prompt (관상 interpretation instructions):   ~800 tokens
  Face measurements JSON:                             ~400 tokens
  Saju profile data:                                  ~200 tokens
  Combined prompt:                                    ~300 tokens
  ─────────────────────────────────────────────────
  Total input:                                       ~1,700 tokens

Output:
  관상 해석문 (gwansang_reading):                     ~400 tokens
  성격 키워드 (face_traits, 5-8 items):               ~50 tokens
  사주+관상 통합 인사이트 (combined_insight):          ~300 tokens
  연애운 (love_fortune):                              ~200 tokens
  궁합 힌트 (compatibility_hints, 3-5 items):         ~80 tokens
  ─────────────────────────────────────────────────
  Total output:                                      ~1,030 tokens
```

### Cost Per Analysis

```
Haiku 4.5:
  Input:  1,700 tokens * $1.00/1M  = $0.0017
  Output: 1,030 tokens * $5.00/1M  = $0.0052
  ──────────────────────────────────────────
  Total per analysis:               $0.0069 (~0.7 cents)

With prompt caching (system prompt cached):
  Cached input:  800 tokens * $0.10/1M = $0.00008 (90% off)
  Fresh input:   900 tokens * $1.00/1M = $0.0009
  Output:       1,030 tokens * $5.00/1M = $0.0052
  ──────────────────────────────────────────
  Total with caching:                $0.0062 (~0.6 cents)

Batch processing (if applicable, 50% off):
  Total with batch:                  $0.0035 (~0.35 cents)
```

### Prompt Engineering

The prompt must produce a 관상 reading that:
1. Feels authentic and rooted in traditional Korean physiognomy
2. Coherently integrates with the user's 사주 profile
3. Is positive and empowering (dating app context -- no doom-and-gloom)
4. Highlights compatibility-relevant traits

```
Edge Function: generate-gwansang-insight

System Prompt (cached):
─────────────────────────────────────────────────────────────────────
당신은 한국 전통 관상학(觀相學)에 정통한 AI 관상가입니다.

## 역할
사용자의 얼굴 측정 데이터와 사주(四柱) 정보를 결합하여
따뜻하고 통찰력 있는 관상 분석을 제공합니다.

## 관상학 핵심 원칙
1. **삼정(三停)**: 상정(이마~눈썹)은 초년운, 중정(눈썹~코)은 중년운, 하정(코~턱)은 만년운
2. **오관(五官)**: 귀(채청관), 눈썹(보수관), 눈(감찰관), 코(심판관), 입(출납관)
3. **오행 연결**: 관상의 특징을 사주 오행과 연결하여 일관된 해석을 제공
4. **균형의 원리**: 편향보다 균형이 좋고, 조화로운 이목구비가 길상

## 출력 형식
반드시 아래 JSON 형식으로 응답하세요:
{
  "gwansang_reading": "관상 해석문 (3-4 문단, 삼정과 오관을 아우르는 종합 해석)",
  "face_traits": ["키워드1", "키워드2", ...],  // 5-8개
  "combined_insight": "사주+관상 통합 인사이트 (사주의 오행과 관상이 어떻게 조화/보완되는지)",
  "love_fortune": "연애운 (관상에서 드러나는 연애 성향과 이상형)",
  "compatibility_hints": ["힌트1", "힌트2", ...]  // 3-5개, 매칭에 활용될 힌트
}

## 톤 & 스타일
- 따뜻하고 격려하는 톤 (소개팅 앱 맥락)
- 전통 관상학 용어를 자연스럽게 녹여 신뢰감 부여
- 부정적 특징도 긍정적 관점으로 재해석 (예: "턱이 각진 것은 의지와 결단력의 상")
- 구체적이고 개인화된 표현 (일반론 금지)
─────────────────────────────────────────────────────────────────────

User Prompt:
─────────────────────────────────────────────────────────────────────
## 관상 분석 요청

### 얼굴 측정 데이터
{face_measurements JSON}

### 사주 프로필
- 연주: {yearPillar}
- 월주: {monthPillar}
- 일주: {dayPillar} (일간: {dayStem})
- 시주: {hourPillar}
- 오행 분포: 목({wood}) 화({fire}) 토({earth}) 금({metal}) 수({water})
- 주도 오행: {dominantElement}
- 사주 성격 키워드: {personalityTraits}

### 분석 요청
위 얼굴 측정 데이터와 사주 정보를 결합하여 관상 분석을 수행해주세요.
특히 다음을 포함해주세요:
1. 삼정 비율에 기반한 인생 운세 흐름
2. 오관 각각의 특징과 의미
3. 사주 오행과 관상 특징의 조화/보완 관계
4. 연애/궁합 관점의 인사이트
─────────────────────────────────────────────────────────────────────
```

### 사주+관상 Coherent Combination Strategy

The key to making the combined reading feel authentic (not two separate readings stitched together):

1. **오행 Bridge**: The user's dominant 오행 from 사주 becomes the interpretive lens for facial features.
   - Example: 목(木) dominant in saju + long face → "나무처럼 곧고 쭉 뻗은 이목구비는 목(木)이 강한 사주와 완벽한 조화. 성장지향적 성격이 얼굴에도 드러납니다."

2. **Complementary Narrative**: Where saju and gwansang agree, reinforce. Where they differ, frame as "balance."
   - Example: Saju says 화(火) = passionate, but face shows calm eyes → "뜨거운 열정(화기)을 차분한 눈매가 다스려, 감정을 잘 조절하는 성숙한 사람"

3. **연애운 Integration**: Combine saju's 일주 (spouse palace) interpretation with gwansang's mouth/eye features for love fortune.

---

## 7. Photo Quality Validation

### Quality Gate Checks (Before Processing)

```dart
class PhotoQualityValidator {
  /// Validates a photo for 관상 analysis suitability
  PhotoQualityResult validate(Face face, Size imageSize) {
    final issues = <PhotoQualityIssue>[];

    // 1. Face size check: must be >= 20% of image area
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final imageArea = imageSize.width * imageSize.height;
    if (faceArea / imageArea < 0.20) {
      issues.add(PhotoQualityIssue.faceTooSmall);
    }

    // 2. Head angle check: must be within +-15 degrees
    if ((face.headEulerAngleY ?? 0).abs() > 15) {
      issues.add(PhotoQualityIssue.headTurnedTooMuch);
    }
    if ((face.headEulerAngleZ ?? 0).abs() > 10) {
      issues.add(PhotoQualityIssue.headTiltedTooMuch);
    }
    // For frontal photo, stricter: Y < 8 degrees
    // For side photos, Y should be 10-25 degrees

    // 3. Eyes open check
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
    if (leftEyeOpen < 0.5 || rightEyeOpen < 0.5) {
      issues.add(PhotoQualityIssue.eyesClosed);
    }

    // 4. Face completeness: bounding box should be fully within image
    final bbox = face.boundingBox;
    if (bbox.left < 0 || bbox.top < 0 ||
        bbox.right > imageSize.width || bbox.bottom > imageSize.height) {
      issues.add(PhotoQualityIssue.facePartiallyOutOfFrame);
    }

    // 5. Contour completeness: critical contours must be present
    if (face.contours[FaceContourType.face] == null ||
        face.contours[FaceContourType.leftEye] == null ||
        face.contours[FaceContourType.rightEye] == null ||
        face.contours[FaceContourType.noseBridge] == null) {
      issues.add(PhotoQualityIssue.insufficientContourData);
    }

    return PhotoQualityResult(
      isAcceptable: issues.isEmpty,
      issues: issues,
    );
  }
}
```

### User Guidance Messages

```dart
const qualityGuidanceMessages = {
  PhotoQualityIssue.faceTooSmall: '얼굴이 너무 작아요. 조금 더 가까이 와주세요!',
  PhotoQualityIssue.headTurnedTooMuch: '얼굴을 정면으로 향해주세요.',
  PhotoQualityIssue.headTiltedTooMuch: '고개를 똑바로 세워주세요.',
  PhotoQualityIssue.eyesClosed: '눈을 뜨고 찍어주세요!',
  PhotoQualityIssue.facePartiallyOutOfFrame: '얼굴 전체가 화면 안에 들어오게 해주세요.',
  PhotoQualityIssue.insufficientContourData: '조명이 부족해요. 밝은 곳에서 다시 촬영해주세요.',
  PhotoQualityIssue.noFaceDetected: '얼굴을 찾을 수 없어요. 다시 촬영해주세요.',
  PhotoQualityIssue.multipleFaces: '한 명만 촬영해주세요!',
};
```

### Photo Guidance UI Flow

```
┌──────────────────────────────────────────┐
│              관상 분석하기                 │
│                                           │
│  ┌───────────────────────────────────┐   │
│  │                                    │   │
│  │     [Face Outline Guide]           │   │
│  │     ┌─────────────────┐           │   │
│  │     │                  │           │   │
│  │     │   (oval guide    │           │   │
│  │     │    overlay)      │           │   │
│  │     │                  │           │   │
│  │     └─────────────────┘           │   │
│  │                                    │   │
│  └───────────────────────────────────┘   │
│                                           │
│  📸 정면 사진 (1/3)                       │
│  "얼굴을 가이드라인 안에 맞춰주세요"       │
│                                           │
│  [ 카메라로 촬영 ]  [ 앨범에서 선택 ]      │
└──────────────────────────────────────────┘
```

---

## 8. Performance & Cost Estimates

### Time Breakdown (Per User Onboarding)

| Step | Duration | Where |
|---|---|---|
| Photo capture (3 photos) | ~30-60s | User action |
| Quality validation (3 photos) | ~1.5s | On-device |
| Face measurement computation | ~0.2s | On-device |
| Network roundtrip to Edge Function | ~0.5s | Network |
| Claude API call (Haiku 4.5) | ~1.5-3s | Server |
| DB save | ~0.2s | Server |
| **Total processing time** | **~4-5.5s** | |
| **Total including user action** | **~35-65s** | |

### Cost Breakdown Per User Onboarding

| Component | Cost | Notes |
|---|---|---|
| ML Kit (on-device) | $0.00 | Free, runs on device |
| Supabase Edge Function | ~$0.0001 | Pay-per-invocation |
| Claude Haiku 4.5 API | ~$0.007 | 1,700 input + 1,030 output tokens |
| Supabase DB storage | ~$0.00001 | ~2KB per row |
| **Total per user** | **~$0.007** | **Less than 1 cent** |

### Cost at Scale

| Users | Claude API Cost | Monthly (if all new) |
|---|---|---|
| 1,000 | $7 | $7 |
| 10,000 | $70 | $70 |
| 100,000 | $700 | $700 |
| 1,000,000 | $7,000 | $7,000 |

These costs are extremely manageable. Even at 1M users, the Claude API cost for 관상 analysis is only $7,000 -- and this is a one-time cost per user (not recurring), since results are cached.

### Caching Strategy

관상 results are deterministic for the same photos + birth info:

```
Cache Key = SHA-256(photo1_hash + photo2_hash + photo3_hash + birth_datetime)
```

- **When to re-analyze**: Only if user uploads new photos
- **Photo change detection**: Store SHA-256 hash of photo bytes in `gwansang_profiles.photo_hash`
- **Result persistence**: Stored permanently in PostgreSQL (no TTL needed)
- **Saju change**: If user corrects birth time, re-run 관상 analysis with same face measurements but updated saju profile (only the AI interpretation step is re-run, not face analysis)

---

## 9. Flutter Implementation Architecture

### Feature Directory Structure

```
lib/features/gwansang/
├── data/
│   ├── datasources/
│   │   └── gwansang_remote_datasource.dart     # Edge Function calls
│   ├── models/
│   │   ├── face_analysis_result_model.dart     # ML Kit raw results
│   │   ├── gwansang_measurements_model.dart    # Computed measurements
│   │   └── gwansang_profile_model.dart         # Full profile (measurements + AI)
│   └── repositories/
│       └── gwansang_repository_impl.dart       # Repository implementation
│
├── domain/
│   ├── entities/
│   │   ├── face_analysis_result.dart           # Raw face data entity
│   │   ├── gwansang_measurements.dart          # Computed measurements entity
│   │   └── gwansang_profile.dart               # Full gwansang profile entity
│   ├── repositories/
│   │   └── gwansang_repository.dart            # Repository interface (abstract)
│   └── services/
│       ├── face_analyzer_service.dart          # ML Kit face detection wrapper
│       ├── gwansang_computer.dart              # Pure Dart measurement computation
│       └── photo_quality_validator.dart        # Photo quality checks
│
└── presentation/
    ├── pages/
    │   ├── gwansang_capture_page.dart          # Photo capture flow (3 photos)
    │   ├── gwansang_analysis_page.dart         # Processing animation
    │   └── gwansang_result_page.dart           # Result display
    ├── providers/
    │   ├── gwansang_provider.dart              # Main state management
    │   └── gwansang_provider.g.dart
    └── widgets/
        ├── face_guide_overlay.dart             # Camera face guide
        ├── photo_quality_feedback.dart         # Quality issue messages
        ├── gwansang_card.dart                  # Result card (shareable)
        └── sam_jeong_chart.dart                # 삼정 visualization
```

### State Management (Riverpod)

```dart
// lib/features/gwansang/presentation/providers/gwansang_provider.dart

@riverpod
class GwansangAnalysis extends _$GwansangAnalysis {
  @override
  FutureOr<GwansangProfile?> build() => null;

  /// Run the full 관상 analysis pipeline
  Future<void> analyze({
    required List<XFile> photos,  // 3 photos
    required SajuProfile sajuProfile,
    String? userName,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(gwansangRepositoryProvider);

      // Step 1: Analyze photos on-device
      final faceResults = <FaceAnalysisResult>[];
      for (final photo in photos) {
        final result = await repository.analyzePhoto(photo);
        if (result == null) throw GwansangException('얼굴을 인식할 수 없습니다');
        faceResults.add(result);
      }

      // Step 2: Compute measurements (on-device, pure Dart)
      final measurements = repository.computeMeasurements(
        faceResults: faceResults,
        primaryPhotoIndex: 0,  // frontal
      );

      // Step 3: Get AI interpretation (server-side)
      final profile = await repository.generateInterpretation(
        measurements: measurements,
        sajuProfile: sajuProfile,
        userName: userName,
      );

      // Step 4: Save to DB
      await repository.saveProfile(
        userId: sajuProfile.userId,
        profile: profile,
        photoHash: _computePhotoHash(photos),
      );

      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

### DI Registration (core/di/providers.dart addition)

```dart
// =============================================================================
// Gwansang (관상)
// =============================================================================

/// 관상 Face Analyzer Service Provider
@riverpod
FaceAnalyzerService faceAnalyzerService(Ref ref) {
  return FaceAnalyzerService();
}

/// 관상 Measurement Computer Provider
@riverpod
GwansangComputer gwansangComputer(Ref ref) {
  return GwansangComputer();
}

/// 관상 Remote Datasource Provider
@riverpod
GwansangRemoteDatasource gwansangRemoteDatasource(Ref ref) {
  return GwansangRemoteDatasource(ref.watch(supabaseHelperProvider));
}

/// 관상 Repository Provider
@riverpod
GwansangRepository gwansangRepository(Ref ref) {
  return GwansangRepositoryImpl(
    faceAnalyzer: ref.watch(faceAnalyzerServiceProvider),
    computer: ref.watch(gwansangComputerProvider),
    remoteDatasource: ref.watch(gwansangRemoteDatasourceProvider),
  );
}
```

### Routing Integration

```dart
// Addition to app_router.dart
// Place after saju result route, before matching profile route

// 관상 분석 (사진 촬영)
GoRoute(
  path: RoutePaths.gwansangCapture,
  name: RouteNames.gwansangCapture,
  builder: (context, state) {
    final sajuProfile = state.extra as SajuProfile?;
    return GwansangCapturePage(sajuProfile: sajuProfile);
  },
),

// 관상 분석 중 (로딩 애니메이션)
GoRoute(
  path: RoutePaths.gwansangAnalysis,
  name: RouteNames.gwansangAnalysis,
  builder: (context, state) {
    final data = state.extra as Map<String, dynamic>;
    return GwansangAnalysisPage(analysisData: data);
  },
),

// 관상 결과
GoRoute(
  path: RoutePaths.gwansangResult,
  name: RouteNames.gwansangResult,
  builder: (context, state) {
    final result = state.extra as GwansangProfile?;
    return GwansangResultPage(result: result);
  },
),
```

### Onboarding Flow Integration

The 관상 feature slots into the existing onboarding flow after saju analysis:

```
Current Flow:
  Login → Onboarding Form → Saju Analysis → Saju Result → Matching Profile → Home

New Flow (with 관상):
  Login → Onboarding Form → Saju Analysis → Saju Result
                                                  │
                                                  ▼
                                          관상 Capture (3 photos)
                                                  │
                                                  ▼
                                          관상 Analysis (loading)
                                                  │
                                                  ▼
                                          관상 Result (사주+관상 통합)
                                                  │
                                                  ▼
                                          Matching Profile → Home
```

The 관상 step is positioned AFTER saju result because:
1. User has already invested time and seen a "wow moment" (사주 결과)
2. 관상 analysis requires the saju profile as input for coherent interpretation
3. Natural progression: "Now that we know your inner destiny (사주), let's read your outer destiny (관상)"

---

## 10. Privacy & Security

### Privacy-First Architecture

```
                    DEVICE BOUNDARY
┌─────────────────────────────────────────────┐
│                                              │
│  Photos ──► ML Kit ──► Measurements (JSON)  │
│    ▲                         │               │
│    │                         │               │
│  NEVER leaves device         ▼               │
│                     Only structured numbers  │
│                     leave the device ────────┼──► Server
│                                              │
│  Photos are NOT:                             │
│  - Uploaded to any server                    │
│  - Stored persistently (temp cache only)     │
│  - Sent to Claude API                        │
│  - Accessible to other users                 │
│                                              │
└─────────────────────────────────────────────┘
```

### What Data Crosses the Network

| Data | Sent to Server? | Content |
|---|---|---|
| Raw photos | NEVER | Stay on device only |
| Face measurements | YES | Numeric ratios, angles, categories (e.g., "oval", 0.34) |
| Saju profile | YES (already on server) | Birth date, pillars, five elements |
| AI interpretation | YES (response) | Text reading, keywords |

### Key Privacy Measures

1. **No photo upload**: Raw photos stay on-device. Only computed measurements (numbers) cross the network.
2. **Photo hash only**: We store a SHA-256 hash of photos (for change detection), not the photos themselves.
3. **Temp file cleanup**: After ML Kit processing, temporary photo files are deleted.
4. **Measurement anonymity**: The measurements JSON alone cannot reconstruct a face image.
5. **RLS protection**: PostgreSQL Row-Level Security ensures only the user can access their gwansang profile.
6. **Edge Function isolation**: The Claude API call happens in a Supabase Edge Function (server-side), so the user's API key is never exposed.
7. **No biometric storage**: Face measurements are 관상 analysis data, not biometric identifiers. They cannot be used for facial recognition.

### Consent & Transparency

```dart
/// Show privacy consent before starting 관상 analysis
Widget _buildPrivacyConsent() {
  return AlertDialog(
    title: const Text('관상 분석 안내'),
    content: const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('관상 분석을 위해 얼굴 사진 3장이 필요해요.'),
        SizedBox(height: 12),
        Text('안심하세요!', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('- 사진은 기기에서만 분석되며 서버에 전송되지 않아요'),
        Text('- 분석 후 사진은 즉시 삭제돼요'),
        Text('- 오직 분석 결과(수치)만 안전하게 저장돼요'),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
      FilledButton(onPressed: _startCapture, child: const Text('시작하기')),
    ],
  );
}
```

---

## 11. Key Code Snippets

### FaceAnalyzerService (ML Kit Wrapper)

```dart
/// lib/features/gwansang/domain/services/face_analyzer_service.dart

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class FaceAnalyzerService {
  late final FaceDetector _detector;

  FaceAnalyzerService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.25,
      ),
    );
  }

  /// Analyze a single photo and extract face data
  Future<FaceAnalysisResult?> analyzePhoto(XFile photo) async {
    final inputImage = InputImage.fromFilePath(photo.path);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) return null;
    if (faces.length > 1) throw MultipleFacesException();

    final face = faces.first;

    return FaceAnalysisResult(
      boundingBox: face.boundingBox,
      landmarks: {
        for (final type in FaceLandmarkType.values)
          if (face.landmarks[type] != null)
            type: face.landmarks[type]!.position,
      },
      contours: {
        for (final type in FaceContourType.values)
          if (face.contours[type] != null)
            type: face.contours[type]!.points,
      },
      headEulerAngleX: face.headEulerAngleX,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
    );
  }

  /// Dispose of the face detector
  void dispose() {
    _detector.close();
  }
}
```

### GwansangComputer (Pure Dart Measurement Engine)

```dart
/// lib/features/gwansang/domain/services/gwansang_computer.dart

import 'dart:math';

class GwansangComputer {
  /// Compute all 관상 measurements from face analysis results
  GwansangMeasurements compute({
    required List<FaceAnalysisResult> faceResults,
    int primaryPhotoIndex = 0,
  }) {
    final primary = faceResults[primaryPhotoIndex];
    final faceContour = primary.contours[FaceContourType.face]!;
    final bbox = primary.boundingBox;

    return GwansangMeasurements(
      faceShape: _classifyFaceShape(faceContour, bbox),
      samJeong: _computeSamJeong(primary),
      eyes: _computeEyeMeasurements(primary),
      eyebrows: _computeEyebrowMeasurements(primary),
      nose: _computeNoseMeasurements(primary),
      mouth: _computeMouthMeasurements(primary),
      forehead: _computeForeheadMeasurements(primary),
      jawline: _computeJawlineMeasurements(primary),
      symmetry: _computeSymmetry(primary),
      proportions: _computeProportions(primary),
    );
  }

  // --- Face Shape ---

  FaceShapeResult _classifyFaceShape(
    List<Point<int>> faceContour,
    Rect bbox,
  ) {
    final width = bbox.width;
    final height = bbox.height;
    final ratio = width / height;

    // Measure width at different vertical positions
    final jawWidth = _widthAtPercentage(faceContour, 0.80);
    final cheekWidth = _widthAtPercentage(faceContour, 0.50);
    final foreheadWidth = _widthAtPercentage(faceContour, 0.20);

    final jawToForehead = jawWidth / foreheadWidth;
    final cheekToJaw = cheekWidth / jawWidth;

    FaceShapeType type;
    double confidence;

    if (ratio > 0.85 && jawToForehead > 0.95) {
      type = FaceShapeType.square;
      confidence = 0.7 + (jawToForehead - 0.95) * 2;
    } else if (ratio > 0.80 && jawToForehead > 0.85) {
      type = FaceShapeType.round;
      confidence = 0.7 + (ratio - 0.80) * 3;
    } else if (ratio < 0.68) {
      type = FaceShapeType.long;
      confidence = 0.7 + (0.68 - ratio) * 5;
    } else if (jawToForehead < 0.75) {
      type = FaceShapeType.heart;
      confidence = 0.7 + (0.75 - jawToForehead) * 3;
    } else if (cheekToJaw > 1.15) {
      type = FaceShapeType.diamond;
      confidence = 0.6 + (cheekToJaw - 1.15) * 3;
    } else {
      type = FaceShapeType.oval;
      confidence = 0.75;
    }

    return FaceShapeResult(
      type: type,
      confidence: confidence.clamp(0.0, 1.0),
      widthHeightRatio: ratio,
      jawForeheadRatio: jawToForehead,
    );
  }

  // --- Eyes ---

  EyeMeasurements _computeEyeMeasurements(FaceAnalysisResult face) {
    final leftEye = face.contours[FaceContourType.leftEye]!;
    final rightEye = face.contours[FaceContourType.rightEye]!;
    final faceWidth = face.boundingBox.width;

    // Eye width = distance between leftmost and rightmost points
    final leftEyeWidth = _contourWidth(leftEye);
    final rightEyeWidth = _contourWidth(rightEye);

    // Eye spacing = distance between inner corners
    final leftInner = leftEye.last;   // inner corner of left eye
    final rightInner = rightEye.first; // inner corner of right eye
    final eyeSpacing = _distance(leftInner, rightInner);

    // Slant angle = angle from inner to outer corner
    final leftSlant = _slantAngle(leftEye);
    final rightSlant = _slantAngle(rightEye);

    // Eye height (opening)
    final leftHeight = _contourHeight(leftEye);
    final rightHeight = _contourHeight(rightEye);

    return EyeMeasurements(
      leftWidth: leftEyeWidth,
      rightWidth: rightEyeWidth,
      spacingRatio: eyeSpacing / faceWidth,
      slantAngleLeft: leftSlant,
      slantAngleRight: rightSlant,
      sizeCategory: _categorizeEyeSize(leftEyeWidth / faceWidth),
      shape: _categorizeEyeShape(leftEyeWidth / leftHeight, leftSlant),
      openRatioLeft: leftHeight / leftEyeWidth,
      openRatioRight: rightHeight / rightEyeWidth,
      symmetryScore: _symmetryScore(leftEyeWidth, rightEyeWidth),
    );
  }

  // --- Utility Methods ---

  double _contourWidth(List<Point<int>> contour) {
    final xs = contour.map((p) => p.x);
    return (xs.reduce(max) - xs.reduce(min)).toDouble();
  }

  double _contourHeight(List<Point<int>> contour) {
    final ys = contour.map((p) => p.y);
    return (ys.reduce(max) - ys.reduce(min)).toDouble();
  }

  double _distance(Point<int> a, Point<int> b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

  double _slantAngle(List<Point<int>> eyeContour) {
    // Angle from inner corner to outer corner
    final inner = eyeContour.last;
    final outer = eyeContour.first;
    return atan2((outer.y - inner.y).toDouble(), (outer.x - inner.x).toDouble()) * 180 / pi;
  }

  double _widthAtPercentage(List<Point<int>> contour, double percentage) {
    final ys = contour.map((p) => p.y);
    final minY = ys.reduce(min);
    final maxY = ys.reduce(max);
    final targetY = minY + (maxY - minY) * percentage;

    // Find points closest to targetY
    final nearPoints = contour.where((p) => (p.y - targetY).abs() < (maxY - minY) * 0.05).toList();
    if (nearPoints.length < 2) return 0;

    final xs = nearPoints.map((p) => p.x);
    return (xs.reduce(max) - xs.reduce(min)).toDouble();
  }

  int _symmetryScore(double left, double right) {
    final diff = (left - right).abs();
    final avg = (left + right) / 2;
    if (avg == 0) return 100;
    return ((1 - diff / avg) * 100).round().clamp(0, 100);
  }
}
```

### Edge Function Skeleton (Supabase)

```typescript
// supabase/functions/generate-gwansang-insight/index.ts

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk";

const anthropic = new Anthropic({
  apiKey: Deno.env.get("ANTHROPIC_API_KEY"),
});

const SYSTEM_PROMPT = `당신은 한국 전통 관상학(觀相學)에 정통한 AI 관상가입니다.
... (full system prompt as defined in Section 6)
`;

serve(async (req: Request) => {
  const { faceMeasurements, sajuProfile, userName } = await req.json();

  // Validate input
  if (!faceMeasurements || !sajuProfile) {
    return new Response(JSON.stringify({ error: "Missing required fields" }), {
      status: 400,
    });
  }

  // Construct user prompt
  const userPrompt = `
## 관상 분석 요청

### 얼굴 측정 데이터
${JSON.stringify(faceMeasurements, null, 2)}

### 사주 프로필
- 사용자: ${userName || "사용자"}
- 연주: ${sajuProfile.yearPillar}
- 월주: ${sajuProfile.monthPillar}
- 일주: ${sajuProfile.dayPillar}
- 시주: ${sajuProfile.hourPillar || "미상"}
- 오행 분포: 목(${sajuProfile.fiveElements.wood}) 화(${sajuProfile.fiveElements.fire}) 토(${sajuProfile.fiveElements.earth}) 금(${sajuProfile.fiveElements.metal}) 수(${sajuProfile.fiveElements.water})
- 주도 오행: ${sajuProfile.dominantElement}

### 분석 요청
위 얼굴 측정 데이터와 사주 정보를 결합하여 관상 분석을 수행해주세요.
`;

  const response = await anthropic.messages.create({
    model: "claude-haiku-4-5-20250710",
    max_tokens: 2048,
    system: [
      {
        type: "text",
        text: SYSTEM_PROMPT,
        cache_control: { type: "ephemeral" },
      },
    ],
    messages: [{ role: "user", content: userPrompt }],
  });

  // Parse structured JSON from response
  const content = response.content[0].type === "text" ? response.content[0].text : "";

  let parsed;
  try {
    // Extract JSON from response (may be wrapped in markdown code blocks)
    const jsonMatch = content.match(/\{[\s\S]*\}/);
    parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : null;
  } catch {
    parsed = {
      gwansang_reading: content,
      face_traits: [],
      combined_insight: "",
      love_fortune: "",
      compatibility_hints: [],
    };
  }

  return new Response(JSON.stringify(parsed), {
    headers: { "Content-Type": "application/json" },
  });
});
```

---

## 12. Risk Analysis & Mitigations

### Technical Risks

| Risk | Severity | Probability | Mitigation |
|---|---|---|---|
| ML Kit contour data insufficient for some face shapes | Medium | Low | Test with diverse face photos during development; supplement with landmark positions |
| Face detection fails in poor lighting | Medium | Medium | Comprehensive quality gate + guidance UI; allow flash/light boost |
| Inconsistent measurements between photos | Medium | Medium | Use primary (frontal) photo for all key measurements; side photos only for supplementary data |
| Claude output format unpredictable | Low | Low | JSON extraction with regex fallback; structured prompt with strict output format |
| ML Kit model size impacts app download | Low | Low | google_mlkit uses dynamic model download (not bundled); first run downloads ~5MB |

### Product Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Users uncomfortable with face photo | High | Strong privacy messaging; option to skip 관상 |
| 관상 results feel generic/inauthentic | High | Detailed prompt engineering; combine with saju for personalization |
| Results feel negative/judgmental | High | Strict prompt guidelines: always positive/empowering tone |
| Feature adds too much friction to onboarding | Medium | Make 관상 optional; or move to post-onboarding engagement feature |

### Platform-Specific Considerations

| Platform | Issue | Solution |
|---|---|---|
| iOS | Camera permission prompt | Pre-explain why photos needed before permission dialog |
| iOS | App Store review (face analysis) | Privacy policy must disclose on-device ML processing |
| Android | ML Kit model download on first use | Show download progress; cache model |
| Both | Large image memory usage (3 photos) | Process sequentially, dispose after each; compress to 1080px max |

---

## Summary

This architecture achieves:

1. **Privacy-first**: Zero photo upload -- all face analysis runs on-device via Google ML Kit
2. **Cross-platform**: `google_mlkit_face_detection` supports both iOS and Android
3. **Cost-efficient**: ~$0.007 per user (Haiku 4.5), scaling linearly
4. **Coherent 사주+관상**: Single unified reading, not two separate analyses
5. **Fast**: ~4-5.5 seconds total processing time (excluding user photo capture)
6. **Clean Architecture**: Follows existing codebase patterns (feature-first, DI via core/di/providers.dart, Riverpod state management)
7. **Extensible**: Measurement JSON is versioned; new facial features can be added without breaking existing profiles

### Next Steps (Implementation Order)

1. Add packages to `pubspec.yaml` (`google_mlkit_face_detection`, `image_picker`, `image_cropper`, `image`, `crypto`)
2. Create domain entities: `FaceAnalysisResult`, `GwansangMeasurements`, `GwansangProfile`
3. Implement `FaceAnalyzerService` (ML Kit wrapper)
4. Implement `GwansangComputer` (measurement computation -- most complex piece)
5. Implement `PhotoQualityValidator`
6. Create Supabase Edge Function `generate-gwansang-insight`
7. Create DB table `gwansang_profiles` with RLS
8. Implement `GwansangRemoteDatasource` and `GwansangRepositoryImpl`
9. Build UI: capture page, analysis page, result page
10. Integrate into onboarding flow
11. Test with diverse face types and lighting conditions
