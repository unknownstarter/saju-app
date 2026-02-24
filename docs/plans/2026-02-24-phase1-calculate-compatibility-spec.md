# Phase 1: 실궁합 계산 Edge Function 설계·스펙

> **역할**: Product Manager (PM)  
> **작성일**: 2026-02-24  
> **목적**: `calculate-compatibility` Edge Function의 API 스펙, 배점 공식, 규칙집, 텍스트 출력, 백엔드/도메인 체크리스트 및 구현 태스크를 정의하여 Backend·Domain 검수 및 구현 에이전트가 그대로 실행할 수 있게 함.  
> **참조**: [궁합 엔진 개선 제안서](./2026-02-24-saju-궁합-engine-improvement-proposal.md)

---

## 1. API 스펙 (Backend 관점)

### 1.1 엔드포인트

- **메서드·경로**: `POST /functions/v1/calculate-compatibility`
- **인증**: Phase 1에서는 **선택(optional)**. 호출 시 `Authorization: Bearer <JWT>`를 넣으면 로깅/캐시 키에 활용 가능하나, 미제공 시에도 동작.

### 1.2 요청 본문 (Request Body)

**권장안: (A) 두 명의 사주 프로필 객체를 그대로 전달**

- 클라이언트가 이미 “나”와 “상대” 사주를 보유한 경우 DB 왕복 없이 한 번에 계산 가능.
- 옵션 (B) `myUserId` / `partnerUserId`만 보내고 서버가 DB에서 사주 조회하는 방식은 Phase 1에서 **미채택**. 필요 시 Phase 2에서 검토.

**JSON 스키마 (camelCase 일관)**

```json
{
  "mySaju": {
    "yearPillar":   { "stem": "갑", "branch": "자" },
    "monthPillar":  { "stem": "을", "branch": "축" },
    "dayPillar":    { "stem": "병", "branch": "인" },
    "hourPillar":   { "stem": "정", "branch": "묘" } | null,
    "fiveElements": { "wood": 2, "fire": 1, "earth": 2, "metal": 1, "water": 2 },
    "dominantElement": "wood"
  },
  "partnerSaju": {
    "yearPillar":   { "stem": "경", "branch": "진" },
    "monthPillar":  { "stem": "신", "branch": "사" },
    "dayPillar":    { "stem": "임", "branch": "오" },
    "hourPillar":   null,
    "fiveElements": { "wood": 1, "fire": 2, "earth": 1, "metal": 2, "water": 2 },
    "dominantElement": "fire"
  }
}
```

- **필수 필드**: `mySaju`, `partnerSaju` 각각 `yearPillar`, `monthPillar`, `dayPillar`, `fiveElements`.
- **선택 필드**: `hourPillar`(null 가능), `dominantElement`(null 가능).
- **기둥 형식**: `{ "stem": "천간 한 글자", "branch": "지지 한 글자" }`. 천간·지지 값은 `app_constants.dart`의 `HeavenlyStems.all` / `EarthlyBranches.all`과 동일한 한글 한 글자.
- **오행**: `fiveElements`는 `wood`, `fire`, `earth`, `metal`, `water` 각각 정수(0 이상). `dominantElement`는 `"wood"` | `"fire"` | `"earth"` | `"metal"` | `"water"` 중 하나 또는 생략.

### 1.3 응답 본문 (Response Body)

앱의 `Compatibility` 엔티티와 맞추기 위해 **camelCase** 사용.  
`id`, `userId`, `partnerId`는 클라이언트가 호출 맥락에서 채워 넣고, 서버는 궁합 계산 결과만 반환.

**성공 시 (200) JSON**

| 키 | 타입 | 필수 | 설명 |
|----|------|------|------|
| `score` | number | ✅ | 종합 궁합 점수 (0~100) |
| `fiveElementScore` | number | ✅ | 오행 궁합 점수 (0~100) |
| `dayPillarScore` | number | ✅ | 일주 궁합 점수 (0~100) |
| `overallAnalysis` | string | ⭕ | 전체 궁합 한 줄 요약 (2~3문장, 한국어) |
| `strengths` | string[] | ✅ | 강점 2~4개 (한국어 짧은 문구) |
| `challenges` | string[] | ✅ | 도전 과제 2~4개 (한국어 짧은 문구) |
| `advice` | string | ⭕ | 관계를 위한 조언 (1~2문장) |
| `aiStory` | string | ⭕ | Phase 1에서는 생략 가능. 있으면 AI 궁합 스토리 |
| `calculatedAt` | string | ✅ | ISO 8601 시각 (예: `"2026-02-24T12:00:00.000Z"`) |

- Flutter 쪽: `lib/core/domain/entities/compatibility_entity.dart`의 `Compatibility`는 `id`, `userId`, `partnerId`, `calculatedAt`(DateTime) 등을 포함. 응답에는 `id`/`userId`/`partnerId`를 넣지 않고, 클라이언트가 `getCompatibilityPreview(partnerId)` 호출 시 현재 사용자 ID·partnerId·생성 ID를 붙여 `Compatibility` 인스턴스를 만든다.
- **응답 키와 엔티티 매핑**: 엔티티에는 현재 `fromJson`이 없음. 연동 시 `Compatibility` 모델/팩토리에서 `score`→`score`, `fiveElementScore`→`fiveElementScore`, `dayPillarScore`→`dayPillarScore`, `overallAnalysis`→`overallAnalysis`, `strengths`→`strengths`, `challenges`→`challenges`, `advice`→`advice`, `aiStory`→`aiStory`, `calculatedAt`(문자열)→`DateTime.parse`로 매핑하고, `id`/`userId`/`partnerId`는 호출 측에서 주입.
- `score`, `fiveElementScore`, `dayPillarScore`는 **정수**로 반환 (0~100).

### 1.4 에러 응답

- **400 Bad Request**: 필수 필드 누락, 기둥 형식 오류(stem/branch 유효하지 않음), fiveElements 키/타입 오류 등.
  - 본문: `{ "error": "메시지" }` (문자열).
- **500 Internal Server Error**: 서버 내부 오류.
  - 본문: `{ "error": "메시지" }`.

### 1.5 CORS

- `calculate-saju`와 동일:  
  `Access-Control-Allow-Origin: *`,  
  `Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type`,  
  `Access-Control-Allow-Methods: POST, OPTIONS`.

---

## 2. 배점 공식 (Domain 관점)

### 2.1 총점 100점 구성 (Phase 1: 십신 미포함)

| 구분 | 배점 | 비고 |
|------|------|------|
| **일주(일간·일지)** | **40** | 천간합 + 지지 육합/삼합/충/형/파/해 |
| **오행** | **35** | 상생 가점, 상극 감점, 균형 보너스 |
| **년·월·시** | **20** | 기둥 간 오행·지지 관계 (일주보다 낮은 비중) |
| **종합 보정** | **5** | 하한 보정, 상한 100 캡 |

- **일주 비중(40)**이 **오행(35)**보다 크거나 동등하도록 하여, 제안서 및 사용자 기대(“일주가 궁합의 50% 이상”)에 부합.

### 2.2 오행 점수 (fiveElementScore, 0~100)

- **쌍 단위**: 두 사주의 오행 분포를 비교.
  - **상생**: A 오행이 B 오행을 생(生)하면 해당 쌍 +점 (예: 쌍당 +8점, 상한 40).
  - **상극**: A 오행이 B 오행을 극(剋)하면 해당 쌍 -점 (예: 쌍당 -4점).
  - **중립(비상생·비상극)**: 0점.
- **dominantElement** 간 관계를 우선 반영하고, 필요 시 `fiveElements` 전체 분포로 보정.
- **과도한 상극만 감점**: 상극 1쌍 -2, 2쌍 -5, **3쌍 이상 -8 상한**. 그 이상은 추가 감점 없음.
- **fiveElementScore** = 기본 50 + (상생 합계) + (상극 합계, 캡 적용) 후 0~100으로 클램프.

### 2.3 일주 점수 (dayPillarScore, 0~100)

- **일간(日干)**: mySaju.dayPillar.stem ↔ partnerSaju.dayPillar.stem  
  **일지(日支)**: mySaju.dayPillar.branch ↔ partnerSaju.dayPillar.branch.
- **천간합**: 5종 (아래 규칙집 참고). 합이면 **+10점**.
- **지지**:
  - **육합**: +8점
  - **삼합**: +6점
  - **충**: -5점
  - **형**: -3점
  - **파**: -2점
  - **해**: -2점
- 동일 관계가 중복 적용되지 않도록 “천간 1쌍 + 지지 1쌍”만 각각 반영.
- **dayPillarScore** = 50 + (천간 합/충 반영) + (지지 합/충/형/파/해 반영) 후 0~100 클램프.

### 2.4 년·월·시 기둥 (20점)

- 년주–년주, 월주–월주, 시주–시주(있을 때만) 쌍에 대해:
  - 오행 상생/상극을 소폭 반영 (쌍당 ±2 수준),
  - 지지 육합/삼합/충만 소폭 반영 (쌍당 ±1~2).
- 합산 후 20점 만점 기준으로 스케일하여 총점에 더함.

### 2.5 종합 점수 (score)

- **score** = (일주 40점 만점 환산) + (오행 35점 만점 환산) + (년·월·시 20점 만점 환산) + (종합 보정 5점).
- 최소 0, 최대 100. 소수는 반올림하여 정수로 반환.

---

## 3. 규칙집 (Domain 검수용)

### 3.1 천간 합 (5종)

| 천간1 | 천간2 | 합화 오행 |
|-------|-------|-----------|
| 갑 | 기 | 토(土) |
| 을 | 경 | 금(金) |
| 병 | 신 | 수(水) |
| 정 | 임 | 목(木) |
| 무 | 계 | 화(火) |

- 위 5쌍만 “천간합”으로 인정. 합이면 **가점** (+10, 일주 점수에 반영).

### 3.2 지지 육합 (6쌍)

| 지지1 | 지지2 |
|-------|-------|
| 자 | 축 |
| 인 | 해 |
| 묘 | 술 |
| 진 | 유 |
| 사 | 신 |
| 오 | 미 |

- 각 쌍 +8점 (일지 비교 시).

### 3.3 지지 삼합 (4조)

| 삼합 | 지지 세 개 |
|------|------------|
| 인오술 | 인, 오, 술 (화) |
| 해묘미 | 해, 묘, 미 (목) |
| 신자진 | 신, 자, 진 (수) |
| 사유축 | 사, 유, 축 (금) |

- 일지 두 개가 같은 삼합에 속하면 +6점 (예: 나=인, 상대=오 → 인오술 중 2개 → 삼합 반영).

### 3.4 지지 육충 (6쌍)

| 지지1 | 지지2 |
|-------|-------|
| 자 | 오 |
| 축 | 미 |
| 인 | 신 |
| 묘 | 유 |
| 진 | 술 |
| 사 | 해 |

- 각 쌍 -5점.

### 3.5 지지 형(刑)·파(破)·해(害)

- **형**: 인–사–신(삼형), 축–진–술(삼형), 자–묘(형), 기타 형 관계 시 -3점.
- **파**: 전통 파(破) 6쌍 (자–유, 인–해, 묘–오, 진–축, 사–술, 오–미 등) -2점.
- **해**: 자–미, 축–오, 인–사, 묘–진, 진–해, 사–인 등 해(害) 6쌍 -2점.

(구현 시 명리학 표준 표를 참고해 테이블을 완성할 것. 여기서는 “형 -3, 파 -2, 해 -2” 비율만 고정.)

### 3.6 과도한 상극 감점 정책

- **오행 상극**: 1쌍 -2, 2쌍 -5, **3쌍 이상 -8 상한**.
- “절대 안 맞는다” 수준의 과도한 감점을 막고, 데이팅용으로 “보완이 필요해요” 톤을 유지.

---

## 4. 텍스트 출력 (UX/Domain)

### 4.1 원칙

- **strengths** / **challenges**: 각 2~4개, 짧은 한국어 문장.
- 톤: “절대 안 맞는다” 금지. “서로 보완이 필요해요”, “갈등 시 대화로 풀어보세요” 등 완곡 표현.

### 4.2 조건별 템플릿 예시 (5~8종)

| 조건 | 유형 | 문구 예시 |
|------|------|-----------|
| 오행 상생 2쌍 이상 | strength | "오행이 잘 맞아요. 서로를 살려 주는 조합이에요." |
| 오행 상극 1~2쌍 | challenge | "기운이 맞지 않는 부분이 있어요. 서로 보완이 필요해요." |
| 천간합 있음 | strength | "일간이 잘 맞아요. 깊은 정서적 교감이 가능해요." |
| 지지 육합 | strength | "일지가 조화로워요. 안정적인 관계를 만들 수 있어요." |
| 지지 충 1쌍 | challenge | "서로 다른 성향이 있어요. 의견이 엇갈릴 때 대화로 풀어보세요." |
| 지지 형/파/해 | challenge | "가끔 마음이 엇갈릴 수 있어요. 배려와 소통이 중요해요." |
| 오행 균형 좋음 | strength | "두 분의 오행이 균형 있게 어울려요." |
| 전반 고득점 | strength | "여러 면에서 잘 맞는 조합이에요. 함께 성장할 수 있어요." |

- **overallAnalysis**: `score` 구간별 1문장 + “오행/일주가 ~해요” 수준의 요약.
- **advice**: “서로의 차이를 인정하고, 말로 풀어보세요” 등 공통 1~2문장 또는 조건 결합.

---

## 5. Backend 체크리스트 (Backend 에이전트 서명용)

- [ ] **입력 검증**: `mySaju`/`partnerSaju` 필수, 각각 `yearPillar`/`monthPillar`/`dayPillar`/`fiveElements` 필수. `stem`/`branch`는 천간 10자·지지 12자 화이트리스트 검사.
- [ ] **DB**: Phase 1에서는 요청 본문만 사용. DB 조회 없음. (B) 방식 도입 시 RLS 및 `saju_profiles` 테이블 문서화.
- [ ] **응답 시간**: 목표 **&lt; 500ms** (순수 계산만, 외부 API 없음).
- [ ] **인증**: Edge Function 호출 시 인증 optional. 미제공 시에도 200/400/500 정상 반환.
- [ ] **캐싱**: Phase 1에서는 **캐시 없음**. 동일 (mySaju, partnerSaju) → 동일 결과는 보장하되, 캐시 키/TTL은 Phase 2 이후 검토. (캐시 키 예: `sha256(JSON.stringify({ mySaju, partnerSaju }))`, TTL 24h 등.)

---

## 6. Domain 체크리스트 (fortune-master 에이전트 서명용)

- [ ] **일주 비중**: 일주 40점 ≥ 오행 35점으로, 일주가 오행보다 크거나 동등한가?
- [ ] **합/충/형/해 비율**: 데이팅용으로 “충 -5, 형 -3, 파/해 -2”가 과하지 않게, “보완이 필요해요” 수준으로 적절한가?
- [ ] **문구 톤**: “절대 안 맞는다”, “피하는 게 좋다” 등 과장 없이 “보완이 필요해요”, “대화로 풀어보세요” 톤인가?

---

## 7. 구현 태스크 목록

1. **Edge Function 스텁 생성**: `supabase/functions/calculate-compatibility/index.ts` 생성. CORS, POST 수신, 요청 검증(필수 필드·pillar 형식) 후 200 시 가짜 응답(score: 70, fiveElementScore: 72, dayPillarScore: 68, strengths/challenges 빈 배열) 반환.
2. **오행 점수 구현**: 상생/상극 규칙 및 과도한 상극 캡 적용, `fiveElementScore` 0~100 계산.
3. **일주 점수 구현**: 천간합 5종, 지지 육합/삼합/충/형/파/해 테이블 구현 및 `dayPillarScore` 0~100 계산.
4. **년·월·시 반영**: 20점분 계산 로직 추가.
5. **종합 score 계산**: 일주 40 + 오행 35 + 년월시 20 + 보정 5, 0~100 클램프.
6. **strengths/challenges 템플릿**: 조건별 5~8종 문구 매핑 및 2~4개씩 선택 로직.
7. **overallAnalysis / advice**: 점수 구간·조건별 1~2문장 생성.
8. **Flutter 연동**: Matching 데이터 레이어에서 `getCompatibilityPreview(partnerId)` 시 “나” 사주·상대 사주 확보 후 `SupabaseFunctionsClient.invoke('calculate-compatibility', body: { mySaju, partnerSaju })` 호출. 응답을 `Compatibility`로 변환 시 `id`/`userId`/`partnerId`/`calculatedAt` 클라이언트 설정. Mock 제거 또는 테스트 전용으로만 유지.
9. **Mock 정리**: 실제 구현체가 `calculate-compatibility`를 쓰도록 전환 후, Mock은 단위/위젯 테스트용으로만 유지.
10. **문서 반영**: 이 스펙 문서 경로 및 “Phase 1 완료 시 연동 완료” 내용을 `CLAUDE.md` 또는 `docs/dev-log`에 반영.

---

*이 문서는 Backend/Domain 에이전트의 “체크 및 설계”와 구현 에이전트의 “Edge Function + Flutter 연동”에 필요한 최소 명세를 담았습니다. 수정 시 제안서 및 `compatibility_entity.dart`, `app_constants.dart`와의 정합성을 유지할 것.*

---

## 8. Phase 1 구현 완료 (2026-02-24)

- [x] Edge Function `calculate-compatibility` 구현
- [x] RLS `saju_select_recommended` 추가
- [x] SajuRepository.getSajuForCompatibility, SajuRemoteDatasource.getSajuProfileByUserId
- [x] MatchingRepositoryImpl 연동, DI 전환
- [x] 문서 반영 (dev-log, 본 스펙)
