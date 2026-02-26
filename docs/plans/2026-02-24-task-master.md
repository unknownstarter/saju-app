# 테스크 마스터 — 2026-02-26 (v4)

> **작성일**: 2026-02-24 | **갱신**: 2026-02-26
> **목적**: 다음에 할 일을 한곳에 정리해, 다른 디바이스에서 보고 연속으로 작업할 수 있게 함.
> **참조**: PRD `docs/plans/2026-02-24-app-design.md`, 개선 제안서 `docs/plans/2026-02-24-saju-궁합-engine-improvement-proposal.md`, dev-log `docs/dev-log/2026-02-24-progress.md`

---

## 1. 완료된 것

### 2026-02-24

| # | 항목 | 상태 |
|---|------|------|
| 1 | 사주 엔진 만세력 기준 전환 (`calculate-saju` → @fullstackfamily/manseryeok, KASI) | ✅ |
| 2 | 실궁합 Edge Function `calculate-compatibility` 구현 (오행+일주 기반) | ✅ |
| 3 | RLS `saju_select_recommended` 추가, Saju `getSajuForCompatibility` | ✅ |
| 4 | MatchingRepositoryImpl 연동, DI 전환 (궁합만 실연동, 추천/좋아요 Mock 유지) | ✅ |
| 5 | Phase 1 스펙·dev-log·문서 반영 | ✅ |

### 2026-02-25

| # | 항목 | 커밋 | 상태 |
|---|------|------|------|
| 6 | 사주 분석 결과 DB 저장 파이프라인 (Tasks 1-4) | `da1a400` | ✅ |
| 7 | 온보딩→사주분석 데이터 핸드오프 연결 (Tasks 5-7) | `6071706` | ✅ |
| 8 | 두 퍼널 아키텍처 (DB 11컬럼 + 트리거 + RLS + 라우터 게이트) | `3944840` | ✅ |
| 9 | 궁합 프리뷰 버그 수정 (Mock 분기 + upsert onConflict) | `f41f4ae` | ✅ |
| 10 | 궁합 프리뷰 와우 모먼트 (게이지 1800ms + 딜레이 페이드인 + 글로우) | `f41f4ae` | ✅ |
| 11 | UI 토큰 시스템 구현 (ThemeExtension 기반 SajuColors/Typography/Elevation) | `a47c5fa` | ✅ |
| 12 | 코어 위젯 11개 + 피처 레이어 18개 토큰 마이그레이션 (deprecated 0개) | `0758045` | ✅ |
| 13 | AI 관상 + 동물상 Feature 설계 완료 (PM/Tech/Content/Growth 4개 에이전트 분석) | — | ✅ |
| 14 | 관상 구현 계획서 작성 (13 Tasks) | — | ✅ |

---

## 2. 다음에 할 일 (우선순위순)

### 🔥 즉시 (Highest) — AI 관상 + 동물상 Feature 구현 + 온보딩 리팩토링

> **전략**: 관상은 홈에서 "동물상 케미" 동기로 자발적 유도, 온보딩은 3분 이내로 축소
> **구현 계획**: `docs/plans/2026-02-25-gwansang-implementation.md` (13 Tasks)
> **온보딩 리팩토링**: 사주 결과→매칭 프로필 퀵 모드(2스텝)→홈, 관상은 홈 넛지로 분리
> **설계 문서**: 아래 4개 참조

| # | Task | 담당 관점 | 산출물/참고 | 상태 |
|---|------|-----------|-------------|------|
| G1 | **패키지 추가 + 상수 등록** | Flutter | pubspec.yaml, app_constants.dart | ✅ |
| G2 | **도메인 엔티티** (GwansangProfile, AnimalType 10종, FaceMeasurements) | Flutter | 3개 파일 생성 | ✅ |
| G3 | **Data 레이어** (Model, Datasource, Repository) | Flutter + Backend | 4개 파일 생성 | ✅ |
| G4 | **FaceAnalyzerService** (ML Kit on-device 얼굴 측정) | Flutter | google_mlkit_face_detection | ✅ |
| G5 | **DI 등록 + Riverpod Provider** | Flutter | providers.dart, gwansang_provider.dart | ✅ |
| G6 | **라우트 등록 + 사주 결과→관상 연결** | Flutter | app_router.dart, saju_result_page.dart 수정 | ✅ |
| G7 | **관상 브릿지 페이지** ("관상까지 더하면...") | Flutter | gwansang_bridge_page.dart | ✅ |
| G8 | **사진 업로드 페이지** (3장 가이드 + 얼굴 검증) | Flutter | gwansang_photo_page.dart | ✅ |
| G9 | **관상 분석 로딩 페이지** (8초 연출) | Flutter | gwansang_analysis_page.dart | ✅ |
| G10 | **관상 결과 페이지** (동물상 리빌 + 바이럴 공유) | Flutter | gwansang_result_page.dart + 위젯 2개 | ✅ |
| G11 | **매칭 프로필 사진 스킵** (관상 사진 자동 연동) | Flutter | matching_profile_page.dart 수정 | ✅ |
| G12 | **Supabase 마이그레이션 + Edge Function** | Backend | DB 테이블 + generate-gwansang-reading | ✅ |
| G13 | **통합 검증** (flutter analyze + 빌드) | QA | 0 errors 확인 | ✅ |

#### 온보딩 플로우 리팩토링 (2026-02-26)

> **핵심**: 12단계 ~7분 → 6단계 ~3분. 관상을 온보딩에서 분리, 홈 넛지로 유도.

| # | Task | 커밋 | 상태 |
|---|------|------|------|
| R1 | **사주 결과 CTA** → "운명의 인연 찾으러 가기" (matchingProfile quickMode) | `8493bea` | ✅ |
| R2 | **라우터 extra 타입** Map 확장 (quickMode + gwansangPhotoUrls) | `8493bea` | ✅ |
| R3 | **매칭 프로필 퀵 모드** — 사진 1장 + 기본정보 2스텝 | `26b827b` | ✅ |
| R4 | **홈 관상 넛지 배너** — "닮은 동물상끼리 잘 맞는대요!" | `f72fd76` | ✅ |
| R5 | **MatchProfile animalType** 필드 추가 | `d8ce376` | ✅ |
| R6 | **궁합 프리뷰 동물상 케미** 섹션 (넛지 CTA) | `d8ce376` | ✅ |
| R7 | **관상 결과 CTA** → "동물상 케미 확인하러 가기" (홈 복귀) | `03513f6` | ✅ |
| R8 | **관상 브릿지 스킵** → 홈으로 | `03513f6` | ✅ |
| R9 | **통합 검증** flutter analyze 0 errors | — | ✅ |

### 기존 (High) — 매칭·궁합 실데이터 연동

| # | Task | 담당 관점 | 산출물/참고 | 상태 |
|---|------|-----------|-------------|------|
| 1 | **daily_matches 실데이터** | Backend + Data | cron 또는 Edge Function으로 오늘의 추천 생성, `getDailyRecommendations` Mock 제거 후 Supabase 연동 | ⬜ |
| 2 | **프로필·사주 저장 연동** | Backend + Flutter | 온보딩/사주 분석 완료 시 `saju_profiles` 저장, `profiles.saju_profile_id` 갱신 | ✅ |
| 3 | **궁합 프리뷰 실사용 검증** | QA | Mock 분기 처리 완료, 와우 모먼트 강화 완료. 남은 것: 실유저 2명 E2E 테스트 | 🔶 |

### 단기 (Medium) — 궁합·매칭 고도화 (Phase 2)

| # | Task | 담당 관점 | 산출물/참고 | 상태 |
|---|------|-----------|-------------|------|
| 4 | **데이팅용 궁합 규칙집 + 상세 리포트** | PM + 도메인 전문가 + Backend | 전문가 검수 규칙 문서화, 상세 궁합(500P)에 반영 | ⬜ |
| 5 | **십신 기반 커플 궁합 보강** | Backend + 도메인 | 일간 대 일간 십신 관계 테이블, 스토리 문구 추가 | ⬜ |
| 6 | **받은 좋아요 목록 페이지** | Flutter | 현재 카드만 있음 → 상세 페이지/수락·거절 플로우 | ⬜ |
| 7 | **프로필 편집 페이지** | Flutter | 온보딩 후 프로필 수정 UI | ⬜ |

### 중기 (Phase 7·8)

| # | Task | 담당 관점 | 산출물/참고 | 상태 |
|---|------|-----------|-------------|------|
| 8 | **Phase 7: Chat** | Backend + Flutter | Supabase Realtime 1:1 채팅, 매칭 성사 시 채팅방 생성, 사주 아이스브레이커 | ⬜ |
| 9 | **Phase 8: Payment** | Backend + Flutter | RevenueCat 인앱 결제, 구독·포인트·상세 궁합 유료 | ⬜ |
| 10 | **Supabase 실연동 전반** | Backend | Auth(Apple/Google/Kakao), Mock Repository → Real 전환 | ⬜ |

### 장기 (Phase 3·그 외)

| # | Task | 담당 관점 | 산출물/참고 | 상태 |
|---|------|-----------|-------------|------|
| 11 | **궁합 가중치 A/B 테스트** | Data + Backend | 오행/일주/십신 비율 파라미터화, 실험 플래그·가중치 저장소 | ⬜ |
| 12 | **푸시 알림** | Backend + Flutter | 새 매칭, 좋아요, 채팅 알림 | ⬜ |
| 13 | **바이럴·분석** | Growth | 사주 카드 SNS 공유, Mixpanel A/B 인프라 | ⬜ |

---

## 3. 참조 문서 (다른 디바이스에서 연속 작업 시 먼저 볼 것)

| 문서 | 용도 |
|------|------|
| **본 파일** `docs/plans/2026-02-24-task-master.md` | 다음 할 일·우선순위·담당 관점 |
| `docs/dev-log/2026-02-24-progress.md` | 오늘 완료 내역, 아키텍처 현황, 레슨런 |
| `docs/plans/2026-02-24-app-design.md` | PRD·MVP 플로우·화면 설계 |
| `docs/plans/2026-02-24-saju-궁합-engine-improvement-proposal.md` | 궁합 엔진 Phase 2/3 로드맵 |
| `docs/plans/2026-02-24-phase1-calculate-compatibility-spec.md` | 궁합 API 스펙·배점·규칙집 |
| `docs/plans/2026-02-25-ui-token-system-design.md` | UI 토큰 시스템 설계 (ThemeExtension) |
| `docs/plans/2026-02-25-gwansang-implementation.md` | **관상 구현 계획 (13 Tasks)** |
| `docs/plans/2026-02-25-gwansang-onboarding-funnel.md` | 관상 온보딩 퍼널 설계 (PM) |
| `docs/plans/2026-02-25-gwansang-ai-architecture.md` | 관상 기술 아키텍처 (ML Kit + Claude) |
| `docs/plans/2026-02-25-gwansang-content-system.md` | 관상 콘텐츠 시스템 (동물상 + AI 프롬프트) |
| `CLAUDE.md` | 개발자룰·아키텍처·에셋·라우팅 규칙 |

---

## 4. 연속 작업 시 체크리스트

- [ ] 위 "다음에 할 일"에서 한 개 이상 Task 선택
- [ ] 참조 문서에서 해당 Task 관련 스펙·의존성 확인
- [ ] `lib/core/di/providers.dart` 확인 (새 Repository/DataSource 추가 시 반드시 등록)
- [ ] 작업 완료 시 본 테스크 마스터 상태(⬜→✅) 및 dev-log 업데이트
