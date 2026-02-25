# 관상(觀相) 콘텐츠 시스템 설계

> 작성일: 2026-02-25
> 작성자: 아리(Ari)
> 승인 대기: 노아님
> 상태: 설계 완료, 구현 대기

---

## 목차

1. [핵심 전략](#1-핵심-전략)
2. [관상 지식 프레임워크](#2-관상-지식-프레임워크)
3. [동물상 분류 시스템](#3-동물상-분류-시스템-사주-앱-전용)
4. [결과 카드 콘텐츠 구조](#4-결과-카드-콘텐츠-구조)
5. [사주 × 관상 시너지 설계](#5-사주--관상-시너지-설계)
6. [AI 프롬프트 템플릿](#6-ai-프롬프트-템플릿)
7. [정확도 및 신뢰성 전략](#7-정확도-및-신뢰성-전략)
8. [바이럴 최적화 전략](#8-바이럴-최적화-전략)
9. [기술 통합 설계](#9-기술-통합-설계)

---

## 1. 핵심 전략

### 왜 관상인가?

| 근거 | 데이터 |
|------|--------|
| 동물상 테스트 바이럴 | 2022 연예인 동물상 테스트 3,000만 회 이상 진행 |
| MZ세대 관상 관심도 | 유튜브 "관상" 키워드 월 검색량 10만+ |
| 사진→콘텐츠 전환 | 이미 온보딩에서 사진 수집 (Step 3) → 추가 입력 없이 관상 분석 가능 |
| 사주와의 시너지 | "태어날 때 정해진 운명(사주) + 얼굴에 드러난 운명(관상)" = 이중 검증 효과 |
| 데이팅 앱 차별화 | 얼굴 기반 분석 → 자연스럽게 "이런 관상의 상대와 잘 맞아요" 연결 |

### 설계 원칙

1. **납득감 우선**: 바넘 효과 + 실측 데이터 = "와 이거 맞는데?!" 반응
2. **긍정 편향**: 80% 긍정 / 20% 성장 포인트 (100% 긍정 = 가짜 느낌)
3. **바이럴 설계**: 동물상 라벨 + 캡처 최적화 카드 = 인스타/카톡 공유
4. **데이팅 연결**: 모든 관상 해석이 자연스럽게 "이상형 매칭"으로 이어짐
5. **사주 연동**: 사주 + 관상이 서로를 뒷받침하여 신뢰도 2배

---

## 2. 관상 지식 프레임워크

### 2.1 얼굴 삼정(三停) — 시간축 운세

관상학에서 얼굴을 가로로 세 구역(상정/중정/하정)으로 나누어, 각각이 인생의 시기를 상징한다고 본다.

```
┌─────────────────────────┐
│   상정 (上停)            │  이마~눈썹: 초년운 (1~30세)
│   - 이마 넓이/높이       │  지적 능력, 부모운, 학업운
│   - 이마 형태(M자/둥근)   │  넓고 둥글면 → 초년에 기반 잡음
│   - 이마 윤기            │  좁거나 주름 → 초년 고생, 자수성가형
├─────────────────────────┤
│   중정 (中停)            │  눈썹~코끝: 중년운 (31~50세)
│   - 눈 크기/형태          │  실행력, 사회적 성취, 배우자운
│   - 코 높이/넓이          │  눈 맑고 코 반듯 → 중년 안정
│   - 광대뼈              │  광대 발달 → 사회적 영향력
├─────────────────────────┤
│   하정 (下停)            │  코끝~턱: 말년운 (51세~)
│   - 인중 길이/깊이        │  안정감, 건강운, 자녀운
│   - 입술 두께/모양        │  턱 풍성 → 말년 안정
│   - 턱 형태 (둥근/각진)   │  인중 깊고 길면 → 장수, 자녀 복
└─────────────────────────┘
```

**데이팅 앱 활용법**: 삼정 균형을 "인생 밸런스"로 해석 → "중정이 발달한 당신, 지금이 인연을 만날 최적기"

### 2.2 오관(五官) — 핵심 관상 포인트

관상의 핵심 다섯 기관. 각각 고유한 의미와 별칭(관직명)이 있다.

#### (1) 눈 — 감찰관(監察官)

| 유형 | 관상학적 의미 | 연애 해석 |
|------|-------------|----------|
| **큰 눈** | 감수성 풍부, 표현력 | 감정 표현이 솔직하고, 상대를 잘 이해해요 |
| **가늘고 긴 눈** | 관찰력, 인내 | 천천히 깊게 사랑하는 타입, 한번 빠지면 진심 |
| **쌍꺼풀 유무** | 외향/내향 성향 지표 | 쌍꺼풀: 적극적 어필 / 무쌍: 속 깊은 사랑 |
| **눈 간격 넓음** | 너그러운 성격, 대범 | 사소한 것에 연연하지 않는 여유로운 연애관 |
| **눈 간격 좁음** | 집중력, 디테일 | 디테일하게 챙기는 자상한 스타일 |
| **눈꼬리 올라감** | 결단력, 리더십 | 관계에서 주도적, 결정할 때 확실한 타입 |
| **눈꼬리 내려감** | 온화함, 친화력 | 상대를 편하게 해주는 따뜻한 스타일 |
| **눈 밑 애교살** | 사람 복, 이성 인기 | 이성에게 자연스럽게 호감을 주는 매력 |

**부부궁(夫婦宮)**: 눈 옆쪽(어미) 부위. 관상학에서 배우자 운을 보는 핵심 포인트.
- 깨끗하고 윤기 있음 → 좋은 배우자를 만남
- 주름이나 점 → 연애 과정에 파란만장

#### (2) 코 — 심판관(審判官)

| 유형 | 관상학적 의미 | 연애 해석 |
|------|-------------|----------|
| **높고 반듯** | 자존심, 원칙주의 | 자기 기준이 뚜렷, 진정한 인연을 찾는 타입 |
| **볼록 코 (매부리)** | 추진력, 야심 | 목표가 생기면 적극적으로 다가가는 스타일 |
| **동글 코** | 사교적, 재물복 | 함께 있으면 즐거운 사람, 데이트 플래너형 |
| **콧대 넓음** | 포용력, 안정감 | 상대를 품어주는 듬직한 타입 |
| **콧대 좁음** | 섬세, 예민 | 작은 변화도 느끼는 세심한 배려형 |
| **코끝 뾰족** | 완벽주의 | 서프라이즈를 좋아하는 로맨틱한 면 |

**준두(準頭, 코끝)**: 재물운의 핵심. 둥글고 풍성하면 재물 복.
**데이팅 연결**: "재물복이 있는 관상 → 안정적인 가정을 꾸릴 타입"

#### (3) 입 — 출납관(出納官)

| 유형 | 관상학적 의미 | 연애 해석 |
|------|-------------|----------|
| **큰 입** | 사교적, 식복 | 사람을 모으는 에너지, 즐거운 연애 |
| **작은 입** | 신중, 절제 | 말보다 행동으로 보여주는 진실한 사랑 |
| **두꺼운 입술** | 정이 많음, 감각적 | 한번 마음 주면 깊게 사랑하는 의리파 |
| **얇은 입술** | 이성적, 언변 | 대화로 마음을 사로잡는 지적 매력 |
| **입꼬리 올라감** | 긍정적, 복 많음 | 만나면 기분이 좋아지는 에너지 보유자 |
| **입꼬리 내려감** | 현실적, 진지 | 가벼운 만남보다 진지한 관계를 원함 |

**식록(食祿)**: 입이 크고 입술이 풍성하면 식복(먹을 복)이 있다는 전통 관상.
**데이팅 연결**: "맛집 데이트에서 빛나는 식복형 관상"

#### (4) 귀 — 채청관(採聽官)

| 유형 | 관상학적 의미 | 연애 해석 |
|------|-------------|----------|
| **큰 귀** | 장수, 복 | 듣는 능력이 좋아 대화가 통하는 인연을 만남 |
| **귓불 두툼** | 재물복, 복덕 | 안정적이고 풍요로운 가정을 꾸릴 상 |
| **귀 위치 높음** | 지적, 학업운 | 지적 대화를 좋아하는 깊이 있는 타입 |
| **귀 밀착** | 집중력, 의지 | 한 사람에게 집중하는 일편단심형 |

#### (5) 눈썹 — 보수관(保壽官)

| 유형 | 관상학적 의미 | 연애 해석 |
|------|-------------|----------|
| **진한 눈썹** | 의지력, 결단 | 관계에서도 책임감이 강한 타입 |
| **연한 눈썹** | 유연, 온화 | 상대에게 맞춰주는 따뜻한 스타일 |
| **일자 눈썹** | 고집, 직진형 | 좋아하면 망설이지 않는 직진 고백형 |
| **아치형 눈썹** | 사교적, 감각적 | 분위기를 잘 읽는 센스 있는 연애파 |
| **눈썹 간격 넓음** | 대범, 낙천 | 사소한 다툼에 연연하지 않는 넉넉한 스타일 |
| **눈썹 간격 좁음** | 집중, 열정 | 연애에도 올인하는 열정파 |

### 2.3 얼굴 형태별 성격 매핑

| 얼굴형 | 한자 | 관상학적 해석 | 연애 스타일 | 오행 연결 |
|--------|------|-------------|------------|---------|
| **둥근형 (원형)** | 圓面 | 사교적, 낙천적, 복이 많음 | "함께 있으면 편안해지는 사람" | 수(水)/토(土) |
| **계란형 (타원)** | 卵面 | 균형잡힌 성격, 조화로움 | "어디서나 자연스럽게 어울리는 타입" | 토(土) |
| **각진형 (사각)** | 方面 | 리더십, 고집, 실행력 | "한번 시작하면 끝까지 가는 사람" | 금(金)/토(土) |
| **역삼각형** | 逆三角 | 지적, 창의적, 독립적 | "지적 대화에서 빛나는 매력" | 화(火)/목(木) |
| **긴형 (장방)** | 長面 | 신중, 인내, 깊은 사고 | "천천히 깊어지는 사랑을 하는 타입" | 목(木) |
| **다이아몬드형** | 菱面 | 카리스마, 독특한 매력 | "한번 보면 잊기 힘든 강렬한 인상" | 화(火) |
| **하트형** | 心面 | 감성적, 이상주의 | "로맨틱한 사랑을 꿈꾸는 이상주의자" | 화(火)/수(水) |

### 2.4 연애/궁합 관련 관상 특수 포인트

#### 부부궁(夫婦宮) — 배우자를 만나는 운
- **위치**: 눈 바깥쪽 관자놀이 부근 (어미 부위)
- **좋은 부부궁**: 깨끗하고 윤기 있으며 흠이 없는 상태
- **해석**: "부부궁이 맑은 당신, 좋은 인연이 가까이 있어요"

#### 자녀궁(子女宮) — 자녀 운
- **위치**: 눈 아래 (와잠, 누당 부위)
- **풍성한 자녀궁**: 눈 밑이 도톰하고 윤기 → 자녀 복
- **해석**: "눈 밑이 환하고 도톰해서, 따뜻한 가정을 꾸릴 복이 있어요"

#### 도화살(桃花煞) — 이성 매력
- **관상 포인트**: 눈매 + 입술 + 피부 윤기의 조합
- **전통 해석**: 이성에게 자연스럽게 호감을 주는 매력이 있다는 의미
- **현대 해석**: "타고난 매력이 있어서, 첫인상에서 호감을 줘요"

#### 관록궁(官祿宮) — 사회적 성취
- **위치**: 이마 중앙
- **넓고 반듯한 이마**: 사회적 성공 → "커리어와 사랑 모두 잡을 수 있는 상"

---

## 3. 동물상 분류 시스템 (사주 앱 전용)

### 3.1 설계 철학

기존 동물상 테스트(강아지/고양이/토끼/곰/여우/공룡)를 참고하되, **사주 앱 특성에 맞게 재설계**한다.

핵심 차별화:
1. **오행(五行)과 연결** — 동물상 + 오행이 융합되어 사주와 일관성
2. **12가지 유형** — MBTI 16유형처럼 충분한 다양성, 하지만 외울 수 있는 수준
3. **궁합 매트릭스** — 동물상 끼리의 궁합이 자연스럽게 매칭으로 연결
4. **성별 무관** — 같은 얼굴형/특징이면 성별과 무관하게 같은 동물상

### 3.2 12동물상 체계

> **네이밍 컨벤션**: "{형용사} {동물}상" — 바이럴 핵심은 형용사에 있다

| # | 동물상 | 한글 라벨 | 오행 | 대표 얼굴 특징 | 성격 키워드 |
|---|--------|-----------|------|----------------|------------|
| 1 | **카리스마 호랑이** | 호랑이상 | 목(木) | 각진 턱, 진한 눈썹, 날카로운 눈매 | 리더십, 추진력, 정의감 |
| 2 | **따뜻한 곰** | 곰상 | 토(土) | 둥근 얼굴, 부드러운 눈, 넓은 코 | 포용력, 안정감, 듬직함 |
| 3 | **영리한 여우** | 여우상 | 화(火) | 좁은 턱, 올라간 눈꼬리, 높은 코 | 재치, 매력, 전략적 |
| 4 | **도도한 고양이** | 고양이상 | 금(金) | 갸름한 얼굴, 큰 눈, 작은 입 | 독립적, 미스터리, 자존감 |
| 5 | **순수한 사슴** | 사슴상 | 목(木) | 긴 얼굴, 큰 눈, 얇은 입술 | 순수, 감성적, 이상주의 |
| 6 | **사교적 강아지** | 강아지상 | 토(土) | 둥근 눈, 두꺼운 입술, 애교살 | 충성, 활발, 사람 좋아함 |
| 7 | **매혹적 뱀** | 뱀상 | 수(水) | 가늘고 긴 눈, 높은 코, 갸름한 얼굴 | 지혜, 신비, 집중력 |
| 8 | **씩씩한 말** | 말상 | 화(火) | 긴 얼굴, 넓은 이마, 큰 코 | 열정, 자유, 에너지 |
| 9 | **귀여운 토끼** | 토끼상 | 금(金) | 작은 얼굴, 둥근 눈, 앙증맞은 입 | 섬세, 감각적, 사랑스러움 |
| 10 | **지혜로운 올빼미** | 올빼미상 | 수(水) | 넓은 이마, 큰 눈, 둥근 얼굴 | 통찰력, 야행성, 깊은 사고 |
| 11 | **늠름한 늑대** | 늑대상 | 금(金) | 각진 얼굴, 깊은 눈, 날카로운 턱선 | 의리, 독립, 카리스마 |
| 12 | **화사한 공작** | 공작상 | 화(火) | 뚜렷한 이목구비, 아치형 눈썹, 큰 입 | 화려, 자신감, 예술적 |

### 3.3 동물상 판별 알고리즘 (Face Measurements → Animal Type)

```
입력: face_measurements JSON
  - face_shape: round | oval | square | oblong | heart | diamond | triangle
  - face_ratio: float (세로/가로 비율, 1.0~1.5+)
  - eye_size: small | medium | large
  - eye_shape: round | almond | upturned | downturned
  - eye_spacing: narrow | normal | wide
  - nose_bridge_height: low | medium | high
  - nose_width: narrow | medium | wide
  - nose_tip: round | pointed | flat
  - lip_thickness: thin | medium | thick
  - lip_width: small | medium | large
  - jaw_shape: round | angular | pointed | wide
  - forehead_height: low | medium | high
  - forehead_width: narrow | medium | wide
  - eyebrow_thickness: thin | medium | thick
  - eyebrow_shape: straight | arched | angled
  - cheekbone_prominence: low | medium | high
  - chin_shape: round | pointed | square | receding
  - aegyo_sal: boolean (애교살 유무)

출력: {
  primary_animal: string,     // 1차 동물상
  secondary_animal: string,   // 2차 동물상 (서브타입)
  confidence: float,          // 판별 확신도 0~1
  element_affinity: string,   // 오행 친화도
}
```

**판별 로직 (가중치 기반 스코어링)**:

```typescript
// 각 동물상별 특징 매칭 점수 계산
const ANIMAL_PROFILES = {
  tiger: {
    face_shape: { square: 3, diamond: 2 },
    jaw_shape: { angular: 3, wide: 2 },
    eyebrow_thickness: { thick: 3 },
    eyebrow_shape: { straight: 2, angled: 2 },
    eye_shape: { upturned: 2, almond: 1 },
    nose_bridge_height: { high: 2 },
    cheekbone_prominence: { high: 2, medium: 1 },
  },
  bear: {
    face_shape: { round: 3, oval: 1 },
    eye_shape: { round: 2, downturned: 2 },
    eye_size: { medium: 1, large: 1 },
    nose_width: { wide: 2, medium: 1 },
    nose_tip: { round: 2 },
    lip_thickness: { thick: 2 },
    jaw_shape: { round: 2, wide: 1 },
    chin_shape: { round: 2 },
  },
  fox: {
    face_shape: { oval: 2, heart: 2, diamond: 1 },
    jaw_shape: { pointed: 3 },
    eye_shape: { upturned: 3, almond: 1 },
    eye_size: { medium: 1, small: 1 },
    nose_bridge_height: { high: 3 },
    nose_tip: { pointed: 2 },
    lip_thickness: { thin: 2, medium: 1 },
    chin_shape: { pointed: 2 },
  },
  cat: {
    face_shape: { oval: 2, heart: 2 },
    eye_size: { large: 3 },
    eye_shape: { almond: 2, round: 1 },
    nose_bridge_height: { medium: 1, high: 1 },
    lip_width: { small: 2 },
    lip_thickness: { medium: 1, thin: 1 },
    chin_shape: { pointed: 2, round: 1 },
    jaw_shape: { pointed: 1 },
  },
  deer: {
    face_shape: { oblong: 3, oval: 2 },
    face_ratio: { high: 2 },  // 세로로 긴 얼굴
    eye_size: { large: 3 },
    eye_shape: { round: 2, downturned: 1 },
    lip_thickness: { thin: 2 },
    forehead_height: { high: 2 },
    nose_bridge_height: { medium: 1 },
  },
  puppy: {
    eye_shape: { round: 3, downturned: 2 },
    eye_size: { large: 2, medium: 1 },
    lip_thickness: { thick: 2, medium: 1 },
    aegyo_sal: { true: 3 },
    face_shape: { round: 2, oval: 1 },
    nose_tip: { round: 2 },
    chin_shape: { round: 1 },
  },
  snake: {
    eye_shape: { almond: 3 },
    eye_size: { small: 2 },
    eye_spacing: { narrow: 2 },
    face_shape: { oval: 2, oblong: 1 },
    nose_bridge_height: { high: 2 },
    lip_thickness: { thin: 2 },
    jaw_shape: { pointed: 1, angular: 1 },
  },
  horse: {
    face_shape: { oblong: 3 },
    face_ratio: { high: 3 },  // 매우 세로로 긴
    forehead_height: { high: 2 },
    forehead_width: { wide: 2 },
    nose_width: { wide: 2 },
    nose_bridge_height: { high: 1 },
    lip_width: { large: 2 },
  },
  rabbit: {
    face_shape: { round: 2, heart: 2, oval: 1 },
    eye_size: { large: 2, medium: 1 },
    eye_shape: { round: 2 },
    lip_width: { small: 2 },
    lip_thickness: { medium: 1 },
    nose_tip: { round: 2 },
    chin_shape: { round: 2, pointed: 1 },
    aegyo_sal: { true: 2 },
  },
  owl: {
    forehead_height: { high: 3 },
    forehead_width: { wide: 2 },
    eye_size: { large: 3 },
    eye_shape: { round: 2 },
    face_shape: { round: 2, oval: 1 },
    eye_spacing: { wide: 2 },
    nose_bridge_height: { medium: 1 },
  },
  wolf: {
    face_shape: { square: 2, diamond: 2 },
    jaw_shape: { angular: 3 },
    eye_shape: { almond: 2 },
    eye_size: { medium: 1, small: 1 },
    nose_bridge_height: { high: 2 },
    cheekbone_prominence: { high: 3 },
    eyebrow_thickness: { thick: 2 },
    chin_shape: { square: 2 },
  },
  peacock: {
    eye_size: { large: 2 },
    eyebrow_shape: { arched: 3 },
    lip_width: { large: 2 },
    lip_thickness: { thick: 1, medium: 1 },
    nose_bridge_height: { high: 2 },
    cheekbone_prominence: { high: 2 },
    face_shape: { oval: 2, diamond: 1 },
  },
};
```

### 3.4 동물상 궁합 매트릭스

동물상 간의 기본 궁합 친화도. 오행 상생/상극과 동물 성격 조합을 기반으로 설계.

```
         호랑이 곰   여우  고양이 사슴  강아지  뱀   말   토끼  올빼미 늑대  공작
호랑이    -     ★★★  ★★   ★★    ★★★  ★★★   ★★  ★★★★ ★★    ★★   ★★★★ ★★★
곰       ★★★   -    ★★   ★★★   ★★★★ ★★★★★ ★★  ★★★  ★★★★★ ★★★  ★★   ★★★
여우     ★★    ★★   -    ★★★★  ★★   ★★    ★★★ ★★★  ★★★   ★★★★ ★★★  ★★★★★
고양이   ★★    ★★★  ★★★★ -     ★★★  ★★    ★★★ ★★   ★★★★  ★★★  ★★★  ★★★
사슴     ★★★   ★★★★ ★★   ★★★   -    ★★★★  ★★★ ★★★  ★★★   ★★★  ★★   ★★★
강아지   ★★★   ★★★★★★★   ★★   ★★★★ -     ★★  ★★★★ ★★★★  ★★★  ★★★  ★★★★
뱀      ★★    ★★   ★★★  ★★★   ★★★  ★★    -   ★★   ★★    ★★★★★★★★ ★★★
말      ★★★★  ★★★  ★★★  ★★    ★★★  ★★★★  ★★  -    ★★★   ★★★  ★★★★ ★★★★★
토끼    ★★    ★★★★★★★★  ★★★★  ★★★  ★★★★  ★★  ★★★  -     ★★★  ★★   ★★★
올빼미   ★★   ★★★  ★★★★ ★★★   ★★★  ★★★   ★★★★★★★★ ★★★   -    ★★★  ★★★
늑대    ★★★★  ★★   ★★★  ★★★   ★★   ★★★   ★★★ ★★★★ ★★    ★★★  -    ★★★
공작    ★★★   ★★★  ★★★★★★★★   ★★★  ★★★★  ★★★ ★★★★★★★★   ★★★  ★★★  -
```

**최고 궁합 조합 TOP 5** (바이럴 소재):
1. **곰 + 강아지** ★★★★★ — "따뜻함의 완전체, 서로를 끝까지 챙기는 의리 커플"
2. **곰 + 토끼** ★★★★★ — "든든함 + 사랑스러움, 누구나 부러워하는 보호자 커플"
3. **여우 + 공작** ★★★★★ — "센스 + 화려함, 에너지가 넘치는 파워 커플"
4. **뱀 + 올빼미** ★★★★★ — "지혜 + 통찰, 말 안 해도 통하는 텔레파시 커플"
5. **호랑이 + 말** ★★★★ — "리더십 + 열정, 함께 세상을 달리는 모험 커플"

---

## 4. 결과 카드 콘텐츠 구조

### 4.1 전체 결과 화면 구조

기존 `SajuResultPage`의 스태거드 리빌 패턴을 재활용하되, 관상 전용 섹션을 추가한다.

```
┌─────────────────────────────────┐
│  [관상 결과 카드 — 전체 화면]     │
│                                 │
│  ① 동물상 히어로 섹션            │  ← 첫 화면에 꽉 차게
│     - 동물 일러스트 + 이름       │
│     - "카리스마 호랑이상"         │
│     - 한줄 훅 "타고난 리더의 관상" │
│     - [공유 버튼]               │
│                                 │
│  ② 관상 수치 카드 (삼정 밸런스)   │  ← 시각적 차트
│     - 상정/중정/하정 비율 바      │
│     - "지금이 최적기" 메시지      │
│                                 │
│  ③ 오관 해석 카드 (스와이프)      │  ← 카드 스와이프
│     - 눈: "깊은 통찰의 눈매"     │
│     - 코: "반듯한 원칙주의자"     │
│     - 입: "말 한마디에 매력이"    │
│     - 눈썹: "의지의 일자 눈썹"    │
│                                 │
│  ④ 사주 × 관상 시너지 섹션       │  ← 핵심 차별화
│     - "사주에서도 관상에서도       │
│       리더의 기운이 흘러요"       │
│     - 오행 아이콘 + 관상 포인트    │
│                                 │
│  ⑤ 연애 스타일 카드              │  ← 데이팅 연결
│     - "당신의 연애 키워드"         │
│     - 3개 키워드 칩              │
│     - "이런 사람과 잘 맞아요" 힌트 │
│                                 │
│  ⑥ 관상 궁합 이상형 힌트          │  ← CTA
│     - "당신의 관상 이상형은..."    │
│     - 동물상 2~3개 추천           │
│     - [운명의 인연 찾으러 가기]    │
│                                 │
└─────────────────────────────────┘
```

### 4.2 각 섹션 상세 콘텐츠

#### 섹션 1: 동물상 히어로 — "첫 화면 임팩트"

```json
{
  "animal_type": "카리스마 호랑이상",
  "animal_icon": "tiger",
  "hook_line": "타고난 리더의 관상, 눈빛에 결단력이 서려 있어요",
  "sub_description": "당신의 얼굴에서 가장 먼저 느껴지는 건 강인한 카리스마예요. 각진 턱선과 깊은 눈매가 만들어내는 당당한 인상이, 처음 만나는 사람에게도 신뢰감을 줘요.",
  "share_text": "내 관상은 카리스마 호랑이상! 🐯\n사주+관상 AI가 분석한 나의 얼굴 운명은?",
  "element_badge": "목(木) 기운"
}
```

**훅 라인 예시 (동물상별)**:

| 동물상 | 훅 라인 |
|--------|---------|
| 카리스마 호랑이 | "타고난 리더의 관상, 눈빛에 결단력이 서려 있어요" |
| 따뜻한 곰 | "한번 안으면 놓치기 싫은, 포근한 인상의 소유자" |
| 영리한 여우 | "한 번 눈이 마주치면 빠져드는, 묘한 매력의 관상" |
| 도도한 고양이 | "미스터리한 아우라, 알수록 빠져드는 관상" |
| 순수한 사슴 | "맑은 눈동자 속에 깊은 감성이 숨어 있는 관상" |
| 사교적 강아지 | "만나면 기분이 좋아지는, 타고난 분위기 메이커 관상" |
| 매혹적 뱀 | "차분한 눈매 속에 강렬한 지혜가 깃든 관상" |
| 씩씩한 말 | "보는 것만으로 에너지가 전해지는, 자유로운 영혼의 관상" |
| 귀여운 토끼 | "보호본능을 자극하는, 사랑스러운 관상의 소유자" |
| 지혜로운 올빼미 | "조용하지만 깊은, 한번 빠지면 헤어나올 수 없는 매력" |
| 늠름한 늑대 | "강인한 턱선 아래 따뜻한 마음이 숨어 있는 관상" |
| 화사한 공작 | "어디서든 시선을 사로잡는, 타고난 스타의 관상" |

#### 섹션 2: 삼정 밸런스 카드

```json
{
  "balance": {
    "upper": { "score": 75, "label": "넓고 밝은 이마", "fortune": "초년운이 좋아요" },
    "middle": { "score": 85, "label": "또렷한 이목구비", "fortune": "지금이 인연의 적기!" },
    "lower": { "score": 70, "label": "안정적인 턱선", "fortune": "말년도 안정적이에요" }
  },
  "overall_message": "삼정이 균형 잡혀 있어서, 인생 전반에 걸쳐 고른 운을 타고났어요",
  "highlight": "특히 중정이 발달해서 지금 시기에 좋은 인연을 만날 확률이 높아요"
}
```

#### 섹션 3: 오관 해석 (스와이프 카드)

각 카드는 오행 색상 + 아이콘 + 2~3문장 해석.

```json
{
  "eyes": {
    "icon": "eye",
    "title": "감찰관 — 눈",
    "reading": "눈꼬리가 살짝 올라간 형태로, 관상학에서는 결단력과 리더십을 의미해요.",
    "romance_hint": "연애에서도 주도적인 편이에요. 좋아하는 사람에게는 확실히 표현하는 타입!",
    "element_link": "목(木)의 기운과 어울려, 성장하는 관계를 선호해요"
  },
  "nose": { ... },
  "mouth": { ... },
  "eyebrows": { ... }
}
```

#### 섹션 4: 사주 × 관상 시너지 (핵심 차별화)

```json
{
  "synergy_title": "사주와 관상이 말하는 당신",
  "synergies": [
    {
      "saju_point": "사주의 목(木) 기운이 강해요",
      "gwansang_point": "넓은 이마가 창의적 에너지를 보여줘요",
      "combined": "태어날 때부터 타고난 목(木)의 성장 에너지가, 얼굴에서도 그대로 드러나고 있어요. 새로운 것을 시작하고 키워나가는 능력이 당신의 핵심 매력이에요."
    },
    {
      "saju_point": "일주에 화(火)의 열정이 있어요",
      "gwansang_point": "밝은 눈빛이 열정을 담고 있어요",
      "combined": "사주의 뜨거운 열정이 눈빛에 그대로 담겨 있어요. 처음 만나는 사람도 당신의 에너지에 이끌리게 될 거예요."
    }
  ],
  "credibility_note": "사주(태어난 시간)와 관상(얼굴의 형태)이 같은 방향을 가리키고 있어서, 해석의 신뢰도가 높아요."
}
```

#### 섹션 5: 연애 스타일 카드

```json
{
  "romance_keywords": ["진심형", "리더형", "보호자형"],
  "romance_style": "한번 마음을 주면 끝까지 가는 타입이에요. 표현은 서툴 수 있지만, 행동으로 보여주는 진심이 상대의 마음을 움직여요.",
  "dating_strength": "첫인상의 신뢰감 — 만나자마자 '이 사람 괜찮다'는 느낌을 줘요",
  "dating_growth": "가끔은 힘든 것도 표현해보세요. 약한 모습을 보여주는 것도 매력이에요",
  "ideal_date": "조용한 카페에서 깊은 대화, 또는 함께 뭔가를 만들어가는 체험형 데이트"
}
```

#### 섹션 6: 궁합 이상형 힌트 — CTA

```json
{
  "title": "관상으로 본 당신의 이상형",
  "ideal_animals": [
    {
      "animal": "따뜻한 곰상",
      "reason": "당신의 강인함을 부드럽게 감싸줄 수 있는 포근한 상대"
    },
    {
      "animal": "사교적 강아지상",
      "reason": "당신의 진지함에 활기를 불어넣어줄 밝은 에너지의 상대"
    },
    {
      "animal": "씩씩한 말상",
      "reason": "함께 목표를 향해 달릴 수 있는 열정적인 파트너"
    }
  ],
  "cta_text": "이런 관상의 인연이 기다리고 있어요",
  "cta_button": "운명의 인연 찾으러 가기"
}
```

### 4.3 공유용 요약 카드 (캡처 최적화)

Instagram Story / KakaoTalk 공유에 최적화된 1장짜리 카드.

```
┌──────────────────────────────┐
│  ◇ 사주 × 관상 분석 결과 ◇    │
│                              │
│      🐯                     │
│  [카리스마 호랑이상]           │
│                              │
│  "타고난 리더의 관상,          │
│   눈빛에 결단력이 서려 있어요" │
│                              │
│  ━━━━━━━━━━━━━━━━━━━━━      │
│  성격: 리더십 | 추진력 | 정의감 │
│  연애: 진심형 | 한번 빠지면 끝 │
│  오행: 목(木) 기운 ████░░    │
│  ━━━━━━━━━━━━━━━━━━━━━      │
│                              │
│  🔮 나의 이상형: 곰상 × 강아지상│
│                              │
│       사주 소개팅 앱 로고       │
│    "운명이 이끈 만남"          │
└──────────────────────────────┘
```

규격: 1080x1920px (Instagram Story), 배경색은 한지 톤 (라이트) 또는 먹색 (다크)

---

## 5. 사주 x 관상 시너지 설계

### 5.1 오행-관상 크로스레퍼런스 테이블

사주에서 도출한 오행 데이터와 관상 해석을 자연스럽게 연결하는 매핑.

| 오행 | 사주에서의 의미 | 관상에서의 시각적 증거 | 시너지 해석 예시 |
|------|---------------|---------------------|----------------|
| **목(木)** | 성장, 인, 창의 | 넓은 이마, 긴 얼굴, 올라간 눈매 | "타고난 목 기운이 넓은 이마에 담겨, 끊임없이 성장하는 에너지를 가졌어요" |
| **화(火)** | 열정, 예, 표현 | 밝은 눈빛, 뚜렷한 이목구비, 입꼬리 올라감 | "화의 열정이 밝은 눈빛으로 드러나, 만나는 사람에게 에너지를 줘요" |
| **토(土)** | 안정, 신, 중심 | 둥근 얼굴, 풍성한 볼, 두꺼운 입술 | "토의 안정감이 부드러운 인상으로 나타나, 함께 있으면 편안해지는 매력이에요" |
| **금(金)** | 결단, 의, 날카로움 | 각진 턱, 높은 코, 날카로운 눈 | "금의 결단력이 선명한 이목구비로 드러나, 첫인상에서 강한 신뢰를 줘요" |
| **수(水)** | 지혜, 지, 유연 | 깊은 눈매, 부드러운 턱선, 큰 귀 | "수의 지혜가 깊은 눈매에 담겨, 조용하지만 강한 내면의 힘이 느껴져요" |

### 5.2 시너지 생성 규칙

1. **일치 패턴** (오행 dominant와 얼굴 특징이 같은 방향):
   - "사주에서도, 관상에서도 같은 기운이 흘러요" → 신뢰도 UP
   - 예: 사주 목(木) 강 + 이마 넓음 → "태어날 때부터 타고난 목의 기운이 얼굴에 그대로 드러나고 있어요"

2. **보완 패턴** (오행 약점을 관상이 보완):
   - "사주에서 부족한 기운을 관상이 채워주고 있어요" → 희망적 메시지
   - 예: 사주 화(火) 부족 + 밝은 눈빛 → "사주에서는 화의 기운이 조금 약한데, 밝은 눈빛이 그 부분을 보완하고 있어요"

3. **강화 패턴** (특정 오행이 사주+관상 모두에서 강함):
   - "이 기운이 당신의 핵심 무기예요" → 자신감 부여
   - 예: 사주 금(金) 강 + 각진 턱 → "결단력의 금 기운이 사주와 관상 모두에서 강하게 나타나요. 이것이 당신의 핵심 매력이에요"

### 5.3 일주(日柱) × 동물상 특별 조합

일주의 천간(나 자신)과 동물상의 조합으로 유니크한 레이블을 생성:

```
{일간 한글} + {동물상} = {유니크 레이블}

갑(甲) + 호랑이 = "푸른 숲의 호랑이" — 성장하는 리더
을(乙) + 토끼 = "꽃밭의 토끼" — 부드러운 감성가
병(丙) + 공작 = "태양의 공작" — 빛나는 표현자
정(丁) + 여우 = "달빛의 여우" — 은은한 매력가
무(戊) + 곰 = "산의 곰" — 흔들림 없는 안정감
기(己) + 강아지 = "들판의 강아지" — 따뜻한 동반자
경(庚) + 늑대 = "서리의 늑대" — 날카로운 의리
신(辛) + 고양이 = "보석의 고양이" — 정교한 아름다움
임(壬) + 올빼미 = "바다의 올빼미" — 깊은 지혜
계(癸) + 뱀 = "이슬의 뱀" — 섬세한 통찰
```

이 유니크 레이블은 사주 결과 카드에 함께 표시되어, 순수 동물상 테스트와 차별화된다.

---

## 6. AI 프롬프트 템플릿

### 6.1 시스템 프롬프트 (관상 전문가 페르소나)

```
당신은 30년 경력의 한국 전통 관상학(觀相學) 전문가이자,
사주명리학(四柱命理學)과 관상을 융합한 통합 운명 해석가입니다.

이름: 도현 선생 (都玄 先生)
스타일: 따뜻하고 격려하는 톤, 하지만 전문성이 느껴지는 깊이

당신의 역할:
1. AI가 분석한 얼굴 측정 데이터를 받아 관상학적 해석을 제공합니다.
2. 사용자의 사주 데이터와 교차 분석하여 시너지 인사이트를 생성합니다.
3. 결과는 긍정적이되 100% 좋은 말만 하지 않습니다 (80% 긍정 / 20% 성장 포인트).
4. 모든 해석은 한국어로, 존댓말(~해요, ~이에요)로 합니다.
5. 전통 관상학 용어를 적절히 사용하되, 현대적으로 풀어서 설명합니다.

중요 규칙:
- 부정적인 관상 해석은 절대 하지 않습니다 (흉상, 빈상, 극상 등의 표현 금지)
- 개선이 필요한 부분은 "~하면 더 좋아질 수 있어요"로 표현합니다
- 연애/관계 관련 해석을 반드시 포함합니다 (데이팅 앱이므로)
- 실제 얼굴 특징 데이터를 반드시 참조하여, 구체적으로 언급합니다
- 바넘 효과를 활용하되, 측정 데이터에 기반한 구체성을 더합니다

반드시 아래 JSON 형식으로만 응답하세요. JSON 외의 텍스트는 절대 포함하지 마세요.

{
  "animal_type": "동물상 이름 (12종 중 하나)",
  "animal_type_label": "형용사 + 동물상 (예: 카리스마 호랑이상)",
  "hook_line": "한줄 훅 (30자 이내, ~해요/~이에요 종결)",
  "hero_description": "메인 설명 (80~120자, 첫인상 중심)",

  "three_zones": {
    "upper": {
      "score": 0-100,
      "feature_description": "이마 특징 설명 (15~25자)",
      "fortune_reading": "초년운 해석 (20~40자)"
    },
    "middle": {
      "score": 0-100,
      "feature_description": "중정 특징 설명",
      "fortune_reading": "중년운 해석"
    },
    "lower": {
      "score": 0-100,
      "feature_description": "하정 특징 설명",
      "fortune_reading": "말년운 해석"
    },
    "balance_message": "삼정 균형 종합 메시지 (30~50자)"
  },

  "five_features": {
    "eyes": {
      "title": "감찰관 — 눈 (8자 이내)",
      "reading": "눈 관상 해석 (40~60자)",
      "romance_hint": "연애 관련 해석 (30~50자)"
    },
    "nose": {
      "title": "심판관 — 코",
      "reading": "코 관상 해석",
      "romance_hint": "연애 관련 해석"
    },
    "mouth": {
      "title": "출납관 — 입",
      "reading": "입 관상 해석",
      "romance_hint": "연애 관련 해석"
    },
    "eyebrows": {
      "title": "보수관 — 눈썹",
      "reading": "눈썹 관상 해석",
      "romance_hint": "연애 관련 해석"
    }
  },

  "saju_synergies": [
    {
      "saju_point": "사주 데이터 기반 포인트 (15~25자)",
      "gwansang_point": "관상 데이터 기반 포인트 (15~25자)",
      "combined_reading": "융합 해석 (50~80자)"
    },
    {
      "saju_point": "...",
      "gwansang_point": "...",
      "combined_reading": "..."
    }
  ],

  "romance_profile": {
    "keywords": ["키워드1", "키워드2", "키워드3"],
    "style_description": "연애 스타일 설명 (60~100자)",
    "strength": "연애에서의 강점 (30~50자)",
    "growth_point": "성장 포인트 (30~50자, 긍정적 톤)",
    "ideal_date": "추천 데이트 스타일 (20~40자)"
  },

  "ideal_match": {
    "animals": [
      {"type": "동물상1", "reason": "이유 (20~30자)"},
      {"type": "동물상2", "reason": "이유"},
      {"type": "동물상3", "reason": "이유"}
    ],
    "summary": "이상형 종합 한줄 (30~50자)"
  },

  "unique_label": "일간+동물상 유니크 레이블 (예: 푸른 숲의 호랑이)",

  "share_text": "SNS 공유용 텍스트 (50자 이내, 이모지 포함)"
}
```

### 6.2 유저 프롬프트 템플릿

```
[사용자 정보]
- 이름: {{user_name}}
- 성별: {{gender}}
- 나이: {{age}}세

[얼굴 측정 데이터 — AI 비전 분석 결과]
- 얼굴 형태: {{face_shape}} ({{face_shape_korean}})
- 얼굴 비율 (세로/가로): {{face_ratio}}
- 눈 크기: {{eye_size}}
- 눈 형태: {{eye_shape}}
- 눈 간격: {{eye_spacing}}
- 눈꼬리 방향: {{eye_tail_direction}}
- 애교살 유무: {{aegyo_sal}}
- 코 높이: {{nose_bridge_height}}
- 코 너비: {{nose_width}}
- 코끝 형태: {{nose_tip}}
- 입술 두께: {{lip_thickness}}
- 입 크기: {{lip_width}}
- 입꼬리 방향: {{lip_corner_direction}}
- 턱 형태: {{jaw_shape}}
- 턱선: {{chin_shape}}
- 이마 높이: {{forehead_height}}
- 이마 너비: {{forehead_width}}
- 눈썹 두께: {{eyebrow_thickness}}
- 눈썹 형태: {{eyebrow_shape}}
- 광대뼈 돌출: {{cheekbone_prominence}}
- 삼정 비율: 상정 {{upper_ratio}}% / 중정 {{middle_ratio}}% / 하정 {{lower_ratio}}%

[사주 데이터]
- 사주팔자:
  년주(年柱): {{year_pillar_stem}}{{year_pillar_branch}} ({{year_pillar_hanja}})
  월주(月柱): {{month_pillar_stem}}{{month_pillar_branch}} ({{month_pillar_hanja}})
  일주(日柱): {{day_pillar_stem}}{{day_pillar_branch}} ({{day_pillar_hanja}})
  시주(時柱): {{hour_pillar_display}}
- 오행 분포: 목(木) {{wood}}, 화(火) {{fire}}, 토(土) {{earth}}, 금(金) {{metal}}, 수(水) {{water}}
- 주도 오행: {{dominant_element}}
- 일간(日干): {{day_stem}} — 이것이 "나 자신"을 대표하는 천간입니다.

[동물상 사전 판별 결과]
- 1차 동물상: {{primary_animal}} (확신도: {{primary_confidence}})
- 2차 동물상: {{secondary_animal}} (확신도: {{secondary_confidence}})
- 오행 친화도: {{element_affinity}}

[해석 지침]
1. 위 동물상 사전 판별을 참고하되, 관상학적 관점에서 최종 판단해주세요.
2. 사주의 오행과 관상 특징을 교차 분석하여 시너지를 2개 이상 찾아주세요.
3. 연애 스타일 해석은 반드시 포함해주세요.
4. "~하는 경향이 있어요", "~일 가능성이 높아요" 등 단정 대신 경향성으로 표현해주세요.
5. 일간({{day_stem}})과 동물상을 조합한 유니크 레이블을 만들어주세요.
6. 이상형 동물상은 궁합 매트릭스를 참고하여 3개를 추천해주세요.

JSON으로 응답해주세요.
```

### 6.3 프롬프트 사용 예시 (실제 입력/출력)

**입력 예시:**
```
[사용자 정보]
- 이름: 민지
- 성별: 여성
- 나이: 27세

[얼굴 측정 데이터]
- 얼굴 형태: oval (계란형)
- 얼굴 비율: 1.35
- 눈 크기: large
- 눈 형태: almond
- 눈 간격: normal
- 눈꼬리 방향: slightly_upturned
- 애교살 유무: true
- 코 높이: medium
- 코 너비: narrow
- 코끝 형태: round
- 입술 두께: medium
- 입 크기: medium
- 입꼬리 방향: upturned
- 턱 형태: pointed
- 턱선: smooth
- 이마 높이: medium
- 이마 너비: medium
- 눈썹 두께: medium
- 눈썹 형태: arched
- 광대뼈 돌출: low
- 삼정 비율: 상정 30% / 중정 40% / 하정 30%

[사주 데이터]
- 년주: 기묘 (己卯)
- 월주: 병인 (丙寅)
- 일주: 정해 (丁亥)
- 시주: 미입력
- 오행: 목2 화2 토1 금0 수3
- 주도 오행: water
- 일간: 정(丁)

[동물상 사전 판별]
- 1차: cat (확신도: 0.72)
- 2차: fox (확신도: 0.58)
- 오행 친화도: fire
```

**기대 출력 예시:**
```json
{
  "animal_type": "고양이",
  "animal_type_label": "도도한 고양이상",
  "hook_line": "미스터리한 아우라, 알수록 빠져드는 관상이에요",
  "hero_description": "갸름한 얼굴과 아몬드형 큰 눈이 만들어내는 묘한 분위기. 처음엔 다가가기 어려워 보이지만, 미소를 지을 때 드러나는 애교살과 올라간 입꼬리가 반전 매력을 만들어요.",

  "three_zones": {
    "upper": {
      "score": 72,
      "feature_description": "균형 잡힌 이마, 밝은 기운",
      "fortune_reading": "안정적인 환경에서 자란 기반이 느껴져요. 학업이나 초기 커리어에서 좋은 기회가 있었을 거예요."
    },
    "middle": {
      "score": 88,
      "feature_description": "또렷한 눈매, 정돈된 코",
      "fortune_reading": "지금이 인연의 적기! 이목구비가 조화로워 좋은 인연을 끌어들이는 시기예요."
    },
    "lower": {
      "score": 75,
      "feature_description": "갸름한 턱선, 환한 미소",
      "fortune_reading": "꾸준한 노력이 말년에 결실을 맺어요. 안정적인 가정을 꾸릴 상이에요."
    },
    "balance_message": "중정이 특히 발달해서 20~30대에 좋은 인연을 만날 확률이 높아요. 지금이 바로 그때!"
  },

  "five_features": {
    "eyes": {
      "title": "깊은 매력의 눈",
      "reading": "크고 또렷한 아몬드형 눈에 살짝 올라간 눈꼬리는 관상학에서 '판단력이 뛰어나고 자기 기준이 분명한 사람'의 상이에요. 여기에 애교살까지 있어 차가워 보이지 않는 절묘한 균형이에요.",
      "romance_hint": "눈빛만으로 상대의 마음을 읽는 능력이 있어요. 진심인 사람을 알아보는 눈이 정확해요."
    },
    "nose": {
      "title": "섬세한 감각의 코",
      "reading": "좁고 정돈된 코에 동글한 코끝은 관상학에서 '섬세하면서도 복이 있는 상'으로 봐요. 재물에 대한 감각이 좋고, 작은 것에서도 아름다움을 찾아요.",
      "romance_hint": "분위기를 잘 읽어서 데이트 장소 선정이 탁월해요. 함께 있으면 즐거운 시간을 만들어요."
    },
    "mouth": {
      "title": "온기를 담은 입",
      "reading": "적당한 두께의 입술에 올라간 입꼬리는 관상학의 '복구(福口)' — 평소에도 미소 띤 인상이라 주변에 좋은 에너지를 줘요.",
      "romance_hint": "말 한마디에 상대를 기분 좋게 만드는 재주가 있어요. 달달한 표현은 서툴러도 위로의 말은 정확해요."
    },
    "eyebrows": {
      "title": "센스 있는 아치형",
      "reading": "자연스러운 아치형 눈썹은 사교적이고 감각적인 성격을 드러내요. 관상학에서는 '분위기를 만드는 사람'의 눈썹이에요.",
      "romance_hint": "대화의 분위기를 자연스럽게 이끄는 센스가 있어요. 어색한 첫 만남도 금방 편해져요."
    }
  },

  "saju_synergies": [
    {
      "saju_point": "일간 정(丁)화의 따뜻한 불꽃 기운",
      "gwansang_point": "차가워 보이지만 따뜻한 반전 관상",
      "combined_reading": "사주의 정화(丁火)는 촛불처럼 은은하고 따뜻한 불이에요. 관상에서도 도도해 보이지만 웃으면 따뜻한 반전이 있잖아요? 안팎이 같은 거예요. 가까이 다가가면 따뜻함을 느끼는, 그런 사람이에요."
    },
    {
      "saju_point": "수(水) 기운이 강해 직관이 뛰어나요",
      "gwansang_point": "큰 눈과 깊은 눈매에 지혜가 담겨 있어요",
      "combined_reading": "사주에서 수(水)가 3으로 가장 강한데, 관상에서도 큰 눈이 사람을 꿰뚫어 보는 듯한 느낌을 줘요. 직관이 뛰어나서 첫인상으로 사람을 정확하게 판단하는 능력이 있어요."
    }
  ],

  "romance_profile": {
    "keywords": ["직관형", "반전매력", "깊은사랑"],
    "style_description": "처음에는 다가가기 어려워 보이지만, 한번 마음을 열면 누구보다 깊이 사랑하는 타입이에요. 표현은 직접적이지 않지만, 행동과 눈빛으로 마음을 전해요. 한번 좋아하면 쉽게 변하지 않는 일편단심이에요.",
    "strength": "진심을 알아보는 눈이 정확해서, 좋은 인연을 놓치지 않아요",
    "growth_point": "가끔은 마음을 말로 표현해보세요. 상대는 당신의 진심을 더 확인하고 싶을 거예요",
    "ideal_date": "분위기 좋은 와인바에서 깊은 대화, 또는 감성적인 전시회 데이트"
  },

  "ideal_match": {
    "animals": [
      {"type": "따뜻한 곰상", "reason": "당신의 도도함을 포근하게 감싸줄 든든한 상대"},
      {"type": "사교적 강아지상", "reason": "당신의 내면의 따뜻함을 자연스럽게 이끌어낼 밝은 에너지"},
      {"type": "영리한 여우상", "reason": "서로의 감각을 이해하는 지적인 대화 파트너"}
    ],
    "summary": "당신의 도도함을 이해하고, 내면의 따뜻함을 알아봐 줄 수 있는 사람이에요"
  },

  "unique_label": "달빛의 고양이",

  "share_text": "내 관상은 도도한 고양이상 🐱✨ 달빛처럼 은은한 매력이래요!"
}
```

---

## 7. 정확도 및 신뢰성 전략

### 7.1 "와 이거 맞는데?!" 반응을 만드는 5가지 기법

#### (1) Barnum Effect + 실측 앵커링

**원리**: 누구에게나 맞는 말 + 실제 얼굴 특징을 결합하면 "내 얘기!"라고 느낌

```
❌ (순수 바넘): "당신은 겉으로는 강해 보이지만 속으로는 여린 면이 있어요"
✅ (앵커링): "눈꼬리가 살짝 올라가서 당당해 보이는데, 애교살이 있어서 실은 따뜻한 사람이에요"
```

실측 데이터 참조 포인트:
- "눈 간격이 넓은 편이어서..." (eye_spacing = wide)
- "이마가 넓고 시원한 편이라..." (forehead_height = high)
- "입꼬리가 자연스럽게 올라가는 편이어서..." (lip_corner = upturned)

#### (2) 자기 실현적 구체성 (Self-Fulfilling Specificity)

실제 측정값을 언급하되, 해석은 누구나 공감할 수 있는 방향으로:

```
"눈이 큰 편이어서 감정 표현이 풍부한 타입이에요.
좋아하는 사람 앞에서 눈이 더 반짝이는 거, 주변에서 알아챌 거예요."
→ 눈이 큰 건 사실 / 눈이 반짝이는 건 대부분의 사람에게 해당
→ 하지만 "눈이 큰" 사실이 전체를 신빙성 있게 만듦
```

#### (3) 문화적 공감 (Cultural Resonance)

한국인이 자연스럽게 동의하는 관상 상식을 활용:

```
"귓불이 두툼한 편이어서 복이 있는 상이에요" → 한국인 대부분 동의
"이마가 넓으면 지혜롭다는 옛말이 있잖아요" → 전통 지식 레퍼런스
"입꼬리가 올라가면 식복이 있다고 하죠" → 일상적 관상 상식
```

#### (4) 헤징 언어 (Hedging Language)

단정 대신 경향성으로 표현하여 반박 가능성을 줄임:

```
✅ "~하는 경향이 있어요"
✅ "~일 가능성이 높아요"
✅ "관상학에서는 ~라고 해석해요"
✅ "~하는 편이에요"
✅ "~할 수 있어요"

❌ "당신은 ~입니다" (단정)
❌ "반드시 ~할 것입니다" (예언)
```

#### (5) 교차 검증 프레이밍 (Cross-Validation Framing)

사주와 관상이 같은 결론을 가리키면 신뢰도가 급상승:

```
"사주에서도 목(木)의 기운이 강하고, 관상에서도 이마가 넓어서
두 가지가 같은 방향을 가리키고 있어요. 이럴 때는 해석의 정확도가 높아져요."
→ "두 가지가 맞다니까 진짜인가 보다" 효과
```

### 7.2 "성장 포인트" 설계 — 신뢰도를 위한 20%

100% 긍정 = 가짜 느낌. 약간의 "주의점"이 있어야 전체가 신뢰 가능.

**규칙**:
- 전체 결과 중 **1~2개만** 성장 포인트로 배치
- 반드시 **긍정적 프레이밍**으로 전환
- 절대 심각한 부정적 표현 사용 금지

**패턴**:

```
✅ "가끔 혼자만의 시간이 필요할 수 있어요. 그건 에너지를 충전하는 거예요."
✅ "마음을 표현하는 게 서툴 수 있는데, 글로 쓰면 훨씬 잘 전달돼요."
✅ "완벽주의 성향이 있어서 가끔 지칠 수 있어요. 80점도 충분히 잘하고 있는 거예요."

❌ "사교성이 부족해요"
❌ "연애운이 나빠요"
❌ "고집이 세서 문제가 될 수 있어요"
```

### 7.3 일관성 보장 전략

사주 해석과 관상 해석이 모순되면 안 됨:

1. **동물상의 오행과 사주 dominant 오행 비교**
   - 일치하면: "사주와 관상이 하나의 방향을 가리켜요" (강화)
   - 다르면: "사주와 관상이 서로 다른 매력을 보여줘요. 다면적인 매력의 소유자!" (보완 프레이밍)

2. **성격 키워드 통일**
   - 사주에서 "따뜻한"이라고 했으면, 관상에서도 "차가운"이라고 하면 안 됨
   - 다만 "겉으로는 차분해 보이지만, 내면에는 따뜻한 정이 있어요" 형태는 가능 (표리 구조)

3. **AI 프롬프트에 사주 해석 결과 포함**
   - 기존 `generate-saju-insight`의 결과를 관상 프롬프트에 전달
   - AI가 자체적으로 일관성을 유지하도록 지시

---

## 8. 바이럴 최적화 전략

### 8.1 바이럴 루프 설계

```
[사진 업로드] → [AI 관상 분석] → [동물상 결과 카드]
                                       ↓
                                 [공유 버튼 터치]
                                       ↓
                              ┌────────┴────────┐
                              │                  │
                         [인스타 스토리]      [카카오톡]
                              │                  │
                         "내 관상은           "야 너도 해봐!
                          호랑이상🐯"          [앱 링크]"
                              │                  │
                              └────────┬────────┘
                                       ↓
                              [친구가 앱 설치]
                                       ↓
                              [친구도 관상 분석]
                                       ↓
                              [친구도 공유] → 🔄 반복
```

### 8.2 공유 최적화 포인트

#### Instagram Story 최적화
- **카드 크기**: 1080x1920px (스토리 풀사이즈)
- **텍스트 크기**: 최소 24pt (작은 화면에서도 읽힘)
- **색상**: 한지 팔레트 — 인스타에서 차별화 (기존 MBTI 테스트는 비비드 컬러)
- **앱 로고 + URL**: 하단 자연스럽게 배치
- **동물 이모지**: 동물상 이름 옆에 해당 이모지 → 텍스트만으로도 공유 가능

#### KakaoTalk 공유 최적화
- **미리보기 카드**: OG Image 1200x630px
- **제목**: "내 관상은 [동물상]! 너도 해볼래?"
- **설명**: "사주+관상 AI가 분석한 나의 얼굴 운명"
- **CTA**: "나도 관상 보러 가기"
- **딥링크**: 앱 설치 → 바로 관상 분석 화면으로

#### X(Twitter) / 텍스트 공유
```
내 관상은 "도도한 고양이상" 🐱
사주+관상 AI가 분석한 나의 운명:
"미스터리한 아우라, 알수록 빠져드는 관상"

연애 스타일: 직관형 | 반전매력 | 깊은사랑
이상형 관상: 따뜻한 곰상 🐻

👉 너도 해볼래? [앱 링크]
```

### 8.3 바이럴 촉발 장치

| 장치 | 설명 | 효과 |
|------|------|------|
| **동물상 이름** | MBTI처럼 쉽게 라벨링 | "나 고양이상이래!" 대화 유발 |
| **궁합 힌트** | "곰상이랑 잘 맞대" | 친구들끼리 서로 비교 |
| **유니크 레이블** | "달빛의 고양이" 같은 시적 표현 | 프로필에 쓰고 싶은 욕구 |
| **비교 기능** | "친구랑 관상 비교하기" | 함께 사용 유도 |
| **주간 변화** | "이번 주 관상 운세" | 재방문 유도 |

### 8.4 커플 궁합 공유 카드

매칭 성사 후, 두 사람의 관상 궁합 카드를 생성하여 커플이 함께 공유 가능.

```
┌──────────────────────────────────┐
│     🐯 × 🐻                     │
│  호랑이상 ♥ 곰상                 │
│  "리더와 포용자, 완벽한 밸런스"    │
│                                  │
│  관상 궁합: ★★★★★ (98%)          │
│  사주 궁합: ★★★★ (85%)           │
│  종합: ★★★★★ (92%)              │
│                                  │
│  "함께라면 못 이룰 게 없는         │
│   운명적 만남이에요"               │
│                                  │
│       사주 소개팅 앱 로고          │
└──────────────────────────────────┘
```

---

## 9. 기술 통합 설계

### 9.1 아키텍처 개요

기존 사주 파이프라인과 동일한 패턴을 따른다.

```
[Flutter App]
    │
    ├── 온보딩 Step 3: 사진 업로드 (기존)
    │       │
    │       ▼
    │   [Supabase Storage]에 사진 저장
    │       │
    │       ▼
    ├── [Edge Function: analyze-face]
    │       │
    │       ├── MediaPipe/ML Kit 또는 Claude Vision으로 얼굴 측정
    │       │
    │       ▼
    │   face_measurements JSON 생성
    │       │
    │       ▼
    ├── [Edge Function: generate-gwansang-reading]
    │       │
    │       ├── 입력: face_measurements + saju_data + gender + age
    │       ├── 동물상 사전 판별 (스코어링 알고리즘)
    │       ├── Claude API 호출 (관상 해석 프롬프트)
    │       │
    │       ▼
    │   gwansang_result JSON (위 §6 형식)
    │       │
    │       ▼
    ├── [Supabase DB]에 결과 저장
    │       │
    │       ▼
    └── [Flutter: GwansangResultPage]에 표시
            │
            ├── 동물상 히어로 카드
            ├── 삼정 밸런스 차트
            ├── 오관 해석 스와이프 카드
            ├── 사주×관상 시너지
            ├── 연애 스타일
            ├── 이상형 힌트 → 매칭 CTA
            └── 공유 카드 생성
```

### 9.2 새로 필요한 Edge Function

#### `analyze-face` (얼굴 분석)
```typescript
// 입력
interface AnalyzeFaceRequest {
  imageUrls: string[];  // Supabase Storage URLs (최대 3장)
  userId: string;
}

// 출력
interface FaceMeasurements {
  face_shape: 'round' | 'oval' | 'square' | 'oblong' | 'heart' | 'diamond' | 'triangle';
  face_ratio: number;
  eye_size: 'small' | 'medium' | 'large';
  eye_shape: 'round' | 'almond' | 'upturned' | 'downturned';
  eye_spacing: 'narrow' | 'normal' | 'wide';
  nose_bridge_height: 'low' | 'medium' | 'high';
  nose_width: 'narrow' | 'medium' | 'wide';
  nose_tip: 'round' | 'pointed' | 'flat';
  lip_thickness: 'thin' | 'medium' | 'thick';
  lip_width: 'small' | 'medium' | 'large';
  jaw_shape: 'round' | 'angular' | 'pointed' | 'wide';
  forehead_height: 'low' | 'medium' | 'high';
  forehead_width: 'narrow' | 'medium' | 'wide';
  eyebrow_thickness: 'thin' | 'medium' | 'thick';
  eyebrow_shape: 'straight' | 'arched' | 'angled';
  cheekbone_prominence: 'low' | 'medium' | 'high';
  chin_shape: 'round' | 'pointed' | 'square' | 'receding';
  aegyo_sal: boolean;
  upper_ratio: number;  // 삼정 상정 비율 (%)
  middle_ratio: number; // 삼정 중정 비율 (%)
  lower_ratio: number;  // 삼정 하정 비율 (%)
}
```

**얼굴 분석 방법 선택지**:

| 옵션 | 장점 | 단점 | 비용 |
|------|------|------|------|
| **A. Claude Vision API** | 기존 인프라 활용, 설계 간단 | 느릴 수 있음 (2~5초) | ~$0.01/요청 |
| **B. Google ML Kit (온디바이스)** | 무료, 빠름 | 측정 항목 제한적 | 무료 |
| **C. MediaPipe Face Mesh** | 468 랜드마크, 정밀 | Flutter 통합 복잡 | 무료 |
| **D. 하이브리드 (B+A)** | ML Kit로 기본 + Vision으로 보강 | 구현 복잡도 중간 | ~$0.005/요청 |

**추천: 옵션 A (Claude Vision API)**
- 이유: 이미 Claude API 사용 중, 추가 패키지 불필요, "관상학적 해석"까지 한번에 가능
- 구현: 사진을 Vision API에 보내면서 측정 + 해석을 동시에 요청

#### `generate-gwansang-reading` (관상 해석 생성)
```typescript
// 입력
interface GwansangRequest {
  faceMeasurements: FaceMeasurements;
  sajuData: SajuResult;        // 기존 사주 계산 결과
  sajuInsight: SajuInsight;    // 기존 AI 사주 해석 결과
  userName: string;
  gender: 'male' | 'female';
  age: number;
}

// 출력: §6의 JSON 구조 그대로
```

### 9.3 DB 스키마 확장

```sql
-- 관상 분석 결과 테이블
CREATE TABLE gwansang_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- 얼굴 측정 데이터
  face_measurements JSONB NOT NULL,

  -- 동물상 분류
  animal_type TEXT NOT NULL,          -- 'tiger', 'bear', 'fox', ...
  animal_type_label TEXT NOT NULL,    -- '카리스마 호랑이상'
  unique_label TEXT,                  -- '달빛의 고양이' (일간+동물상)
  element_affinity TEXT,              -- 오행 친화도

  -- AI 해석 결과 (전체 JSON)
  reading_result JSONB NOT NULL,

  -- 메타데이터
  analyzed_photos TEXT[] NOT NULL,    -- 분석에 사용된 사진 URL
  analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id)
);

-- profiles 테이블에 컬럼 추가
ALTER TABLE profiles ADD COLUMN gwansang_profile_id UUID REFERENCES gwansang_profiles(id);
ALTER TABLE profiles ADD COLUMN animal_type TEXT;

-- RLS
ALTER TABLE gwansang_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own gwansang" ON gwansang_profiles
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own gwansang" ON gwansang_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 매칭 추천 대상의 관상도 볼 수 있도록
CREATE POLICY "Can read matched user gwansang" ON gwansang_profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM daily_matches dm
      WHERE dm.user_id = auth.uid()
        AND dm.matched_user_id = gwansang_profiles.user_id
        AND dm.matched_date = CURRENT_DATE
    )
  );
```

### 9.4 Flutter 도메인 엔티티

```dart
// lib/features/gwansang/domain/entities/gwansang_entity.dart

/// 관상 프로필 — 한 사람의 관상 분석 결과
class GwansangProfile {
  const GwansangProfile({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.animalTypeLabel,
    this.uniqueLabel,
    required this.hookLine,
    required this.heroDescription,
    required this.threeZones,
    required this.fiveFeatures,
    required this.sajuSynergies,
    required this.romanceProfile,
    required this.idealMatch,
    required this.shareText,
    required this.analyzedAt,
  });

  final String id;
  final String userId;
  final String animalType;        // 'tiger', 'bear', ...
  final String animalTypeLabel;   // '카리스마 호랑이상'
  final String? uniqueLabel;      // '달빛의 고양이'
  final String hookLine;
  final String heroDescription;
  final ThreeZones threeZones;
  final FiveFeatures fiveFeatures;
  final List<SajuSynergy> sajuSynergies;
  final RomanceProfile romanceProfile;
  final IdealMatch idealMatch;
  final String shareText;
  final DateTime analyzedAt;
}

class ThreeZones {
  const ThreeZones({
    required this.upper,
    required this.middle,
    required this.lower,
    required this.balanceMessage,
  });

  final ZoneReading upper;
  final ZoneReading middle;
  final ZoneReading lower;
  final String balanceMessage;
}

class ZoneReading {
  const ZoneReading({
    required this.score,
    required this.featureDescription,
    required this.fortuneReading,
  });

  final int score;
  final String featureDescription;
  final String fortuneReading;
}

class FeatureReading {
  const FeatureReading({
    required this.title,
    required this.reading,
    required this.romanceHint,
  });

  final String title;
  final String reading;
  final String romanceHint;
}

class FiveFeatures {
  const FiveFeatures({
    required this.eyes,
    required this.nose,
    required this.mouth,
    required this.eyebrows,
  });

  final FeatureReading eyes;
  final FeatureReading nose;
  final FeatureReading mouth;
  final FeatureReading eyebrows;
}

class SajuSynergy {
  const SajuSynergy({
    required this.sajuPoint,
    required this.gwansangPoint,
    required this.combinedReading,
  });

  final String sajuPoint;
  final String gwansangPoint;
  final String combinedReading;
}

class RomanceProfile {
  const RomanceProfile({
    required this.keywords,
    required this.styleDescription,
    required this.strength,
    required this.growthPoint,
    required this.idealDate,
  });

  final List<String> keywords;
  final String styleDescription;
  final String strength;
  final String growthPoint;
  final String idealDate;
}

class IdealMatch {
  const IdealMatch({
    required this.animals,
    required this.summary,
  });

  final List<MatchAnimal> animals;
  final String summary;
}

class MatchAnimal {
  const MatchAnimal({
    required this.type,
    required this.reason,
  });

  final String type;
  final String reason;
}
```

### 9.5 유저 플로우 통합

현재 온보딩에서 사진은 Phase B (MatchingProfilePage)에서 수집되므로, 관상 분석은 사진 업로드 직후에 트리거:

```
기존 플로우:
  온보딩(Phase A) → 사주 분석 → 사주 결과 → 매칭 프로필(Phase B: 사진+소개)

변경 플로우:
  온보딩(Phase A) → 사주 분석 → 사주 결과
    → 매칭 프로필(Phase B: 사진+소개)
        → 사진 업로드 완료 시 백그라운드로 관상 분석 시작
    → 관상 분석 로딩 (사주 분석 로딩 연출 재활용)
    → 관상 결과 카드 (새 화면)
    → "운명의 인연 찾으러 가기" → 홈
```

또는 (더 나은 UX):

```
사주 결과 확인 → 매칭 프로필 작성 → 홈
  │
  └── 홈에서 "내 관상 분석하기" 배너 (사진이 이미 있으므로)
        → 관상 분석 로딩
        → 관상 결과 카드
```

---

## 부록 A: 동물상별 일러스트 에셋 가이드

기존 오행이 캐릭터 스타일(치이카와풍)을 유지하면서, 12동물상 일러스트 추가.

```
assets/images/animals/
├── tiger_default.png       # 호랑이상
├── bear_default.png        # 곰상
├── fox_default.png         # 여우상
├── cat_default.png         # 고양이상
├── deer_default.png        # 사슴상
├── puppy_default.png       # 강아지상
├── snake_default.png       # 뱀상
├── horse_default.png       # 말상
├── rabbit_default.png      # 토끼상
├── owl_default.png         # 올빼미상
├── wolf_default.png        # 늑대상
├── peacock_default.png     # 공작상
├── couple/                 # 궁합 커플 일러스트
│   ├── tiger_bear.png
│   ├── cat_puppy.png
│   └── ...
└── share/                  # 공유 카드 배경
    ├── share_card_light.png
    └── share_card_dark.png
```

## 부록 B: 관상 해석 품질 체크리스트

AI 결과 검증용 (파싱 후 품질 검사):

- [ ] `animal_type`이 12종 중 하나인가?
- [ ] `hook_line`이 30자 이내인가?
- [ ] `hero_description`이 80~120자 범위인가?
- [ ] 삼정 점수가 모두 0~100 사이인가?
- [ ] 삼정 중 최소 하나는 70 이상인가? (너무 낮으면 부정적)
- [ ] 오관 해석 4개가 모두 있는가?
- [ ] 각 오관 해석에 `romance_hint`가 있는가?
- [ ] `saju_synergies`가 2개 이상인가?
- [ ] `romance_profile.keywords`가 정확히 3개인가?
- [ ] `growth_point`가 긍정적 프레이밍으로 되어 있는가? (부정어 미포함)
- [ ] `ideal_match.animals`가 정확히 3개인가?
- [ ] `unique_label`이 존재하는가?
- [ ] `share_text`가 50자 이내인가?
- [ ] 전체 JSON이 정상 파싱되는가?

## 부록 C: 참고 문헌 및 관상학 원전

- 『마의상법(麻衣相法)』 — 관상학의 고전, 삼정/오관 체계의 원전
- 『유장상법(柳莊相法)』 — 명나라 시대 관상서
- 『관상학 입문』 (신기원) — 현대 한국어 관상학 교과서
- 『명리학 × 관상학 통합 해석론』 — 사주와 관상의 교차 해석 방법론
- 동물상 심리학: 형태 유사성(morphological similarity)이 성격 판단에 미치는 영향 연구

---

> **다음 단계**:
> 1. 노아님 승인 → 동물상 일러스트 AI 생성 or 외주
> 2. Edge Function `analyze-face` 구현 (Claude Vision API)
> 3. Edge Function `generate-gwansang-reading` 구현
> 4. Flutter `GwansangResultPage` UI 구현
> 5. 공유 카드 렌더링 기능 구현
> 6. 매칭 알고리즘에 동물상 궁합 가중치 반영
