# 권장사항 실행 플랜 — 아키텍처·디자인 리뷰 후속

> 작성일: 2026-02-24  
> 근거: `docs/review/2026-02-24-architecture-design-review.md`  
> 협의: 프로덕트 디자이너(캐릭터·빈/에러 상태), Flutter 개발(구현), 기획(우선순위)

---

## 1. PRD/설계 문서 반영 사항

### 1.1 `docs/plans/2026-02-24-app-design.md` 연동
- **4.6 화면별 캐릭터 활용 맵**: 프로필·빈 상태·에러 상태에 캐릭터 적용 → 본 플랜 Task 1, 2로 구현
- **4.2 가이드 시스템**: "빈 상태: 캐릭터가 위로/격려", "에러 상태: 캐릭터가 당황/사과" → 공통 위젯으로 표준화

### 1.2 `CLAUDE.md` / 디자인 시스템
- **에셋 관리**: 캐릭터 에셋 경로는 `app_constants.dart` `CharacterAssets`만 사용
- **UI 디자인 원칙**: "미니멀 ≠ 휑함" — 빈/에러 화면에도 캐릭터 64~72px 배치

### 1.3 product-designer 스킬 원칙
- **Emotional Design**: 에러/빈 상태에 캐릭터로 감정 전달
- **Simplicity**: 한 화면 하나의 핵심 행동 — 빈/에러 위젯에 CTA 1개

---

## 2. 테스크 마스터 (실행 순서)

| # | Task | 담당 관점 | 산출물 | 상태 |
|---|------|-----------|--------|------|
| 1 | 프로필 탭에 "내 캐릭터" 추가 | 디자인 + 구현 | ProfilePage에 사용자 오행 → CharacterAssets → 64~72px 이미지 | ✅ |
| 2 | 빈/에러 상태 공통 위젯 도입 | 디자인 시스템 | `SajuEmptyState`, `SajuErrorState` (캐릭터 + 메시지 + 선택 CTA) | ✅ |
| 3 | 채팅 빈 상태에 공통 위젯 적용 | 구현 | ChatListPage `_EmptyState` → SajuEmptyState | ✅ |
| 4 | 매칭 빈/에러 상태에 공통 위젯 적용 | 구현 | MatchingPage 빈 그리드·에러 → SajuEmptyState / SajuErrorState | ✅ |
| 5 | 프로필 에러/다시 시도에 공통 위젯 적용 | 구현 | ProfilePage error state → SajuErrorState | ✅ |
| 6 | 여백/패딩 AppTheme 토큰 통일 | 디자인 시스템 | ProfilePage, MatchingPage, ChatListPage 매직 넘버 제거 | ✅ |
| 7 | dev-log 및 리뷰 문서 업데이트 | 문서 | 2026-02-24-progress.md, review 문서 "완료" 반영 | ✅ |

---

## 3. Task 상세 스펙

### Task 1: 프로필 탭 "내 캐릭터"
- **입력**: `UserEntity.sajuProfileId` 있으면 → 사주 주도 오행 조회 (현재는 프로필에 dominant_element 없으면 기본 나무리)
- **표시**: 아바타 오른쪽 또는 완성도 섹션 위에 캐릭터 이미지 64~72px
- **캐릭터 결정**: `UserEntity`에 dominant element 없으면 `CharacterAssets.namuriWoodDefault` (기본)

> **직군 협의**: 프로필에 "주도 오행"이 저장되지 않는 현재 구조에서는 기본 나무리로 통일. 추후 saju_profiles 연동 시 오행 반영.

### Task 2: SajuEmptyState / SajuErrorState
- **SajuEmptyState**
  - Props: `characterAssetPath`, `characterName`, `message`, `subtitle` (optional), `actionLabel` + `onAction` (optional)
  - 레이아웃: 캐릭터 64px + 메시지 + (선택) 버튼
  - 용도: 채팅 없음, 매칭 필터 결과 없음 등
- **SajuErrorState**
  - Props: `characterAssetPath` (당황/사과용, 기본 나무리), `message`, `actionLabel`, `onAction`
  - 레이아웃: 캐릭터 64px + 메시지 + "다시 시도" 버튼
  - 용도: 프로필 로드 실패, 매칭 로드 실패 등

### Task 6: 여백 토큰
- `20` → `AppTheme.spacingLg`(24) 또는 `AppTheme.spacingXl`(32) (페이지 좌우 패딩은 20 유지 시 20은 유지하되 상수 참조로 통일)
- `16` → `AppTheme.spacingMd`
- `8` → `AppTheme.spacingSm`
- design-system: 20px = xl이면 20 유지 가능. app_theme 기준 spacingXl=32이므로 "20" 사용 화면은 `const EdgeInsets.symmetric(horizontal: 20)` → `EdgeInsets.symmetric(horizontal: AppTheme.spacingLg + 4)` 또는 **새 토큰 pagePaddingH = 20** 추가 검토. (단순화: 20 유지하고 나머지만 토큰으로)

---

## 4. 완료 기준 (Definition of Done)
- [x] 프로필 탭 진입 시 내 캐릭터(또는 기본 나무리) 노출
- [x] 채팅/매칭/프로필 빈·에러 화면에 캐릭터 + 메시지 + (해당 시) CTA
- [x] core/widgets에 SajuEmptyState, SajuErrorState 추가 후 widgets.dart export
- [x] 프로필·매칭·채팅 페이지 여백이 AppTheme 또는 명시적 상수로 정리
- [ ] `flutter analyze` 0 issues, 기존 테스트 통과 (로컬에서 확인)
- [x] dev-log 및 리뷰 문서에 완료 반영

---

## 5. 참조
- 리뷰: `docs/review/2026-02-24-architecture-design-review.md`
- 설계: `docs/plans/2026-02-24-app-design.md` §4.2, §4.6
- 디자인 시스템: `docs/plans/2026-02-23-design-system.md`
- 스킬: `.claude/skills/product-designer.md`
