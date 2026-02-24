# 아키텍처·디자인 리뷰 — GoRouter, 컴포넌트, 클린 아키텍처, 캐릭터

> 작성일: 2026-02-24  
> 참조: CLAUDE.md, product-designer 스킬, 2026-02-24-app-design.md, 2026-02-23-design-system.md

---

## 1. 요약

| 영역 | 상태 | 비고 |
|------|------|------|
| **GoRouter** | ✅ 양호 | 경로/리다이렉트/ShellRoute 일관됨. 일부 플레이스홀더만 교체 필요 |
| **클린 아키텍처** | ✅ 준수 | presentation → data 직접 의존 없음, DI는 core에서 |
| **디자인 시스템 컴포넌트** | ⚠️ 개선 여지 | SajuButton/Card/Chip/Avatar/CompatibilityGauge 등 적절히 사용. 일부 화면은 토큰 미사용 |
| **캐릭터 활용** | ⚠️ 불균형 | 온보딩·사주·매칭카드·홈(나무리)에는 있음. **프로필·빈/에러 상태·채팅 빈 상태**에는 없음 |

---

## 2. GoRouter

### 잘 된 점
- **경로 상수**: `RoutePaths` / `RouteNames`가 `app_constants.dart`에 중앙 정의되어 있고, 라우터에서만 참조. 경로 변경 시 한 곳만 수정하면 됨.
- **리다이렉트**: `refreshListenable` + `RouterAuthNotifier`로 인증 변경 시 자동 리다이렉트. 비로그인 시 로그인으로, 로그인 후 스플래시/로그인 접근 시 홈으로 보내는 로직 명확함.
- **ShellRoute**: `StatefulShellRoute.indexedStack`으로 4탭(홈/매칭/채팅/프로필) 구성. 탭별 상태 유지·`goBranch`로 탭 루트 이동 처리 적절함.
- **파라미터·extra**: `chatRoomPath(roomId)`, `matchDetailPath(matchId)` 헬퍼 존재. 사주 결과는 `extra: SajuAnalysisResult`로 전달.
- **에러 처리**: `errorBuilder`로 404 시 안내 + "홈으로 돌아가기" 제공.

### 보완할 점
- **서브라우트 경로**: `editProfile`은 `RoutePaths.editProfile = '/profile/edit'`로 **최상위** `GoRoute`에 있음. Shell의 `/profile`과 경로만 공유할 뿐, 중첩 자식이 아님. 의도된 구조라면 유지하고, 나중에 "프로필 탭 하위에 편집/설정을 두고 싶다"면 Shell profile 브랜치에 `routes: [ GoRoute(path: 'edit', ...), ... ]` 형태로 옮기는 선택 가능.
- **매칭 상세**: `/matching/:matchId` 라우트는 정의돼 있으나 현재 **미사용**. 홈/매칭 탭에서는 `showCompatibilityPreview`로 **바텀시트**만 띄움. "카드 탭 → 상세 프로필(풀페이지)"를 만들 계획이면 해당 라우트에 실제 페이지 연결 필요.
- **플레이스홀더**: 스플래시, SMS 인증, 프로필 편집, 설정, 결제, 매칭 상세는 아직 `_PlaceholderPage`. 구현 순서 정해두고 하나씩 교체하면 됨.

---

## 3. 클린 아키텍처

### 의존성 규칙
- **presentation → data 직접 import**: `lib/features/**/presentation/**`에서 `**/data/`를 import하는 파일 **없음** ✅  
- **DI**: Repository/Datasource는 `core/di/providers.dart`에서만 생성. Presentation은 `authRepositoryProvider`, `sajuRepositoryProvider` 등 **Provider만** 참조 ✅  
- **도메인**: `UserEntity`는 `core/domain/entities/user_entity.dart`에서 auth 엔티티 re-export. 여러 feature가 동일한 엔티티를 쓰는 구조 유지 ✅  

### 경계가 흐릿해질 수 있는 부분
- **app 레이어**: `app_router.dart`가 `SajuAnalysisResult`(saju feature의 provider 타입)를 `extra`로 쓰기 위해 `saju_provider.dart`를 import. 앱 진입점이 화면/타입을 알고 있는 것은 허용 범위로 보는 게 일반적. 필요하면 `SajuAnalysisResult`만 core나 app 쪽으로 올리는 선택지 있음.
- **채팅 Mock**: `chat_provider`가 `MockChatRepository`를 쓰고, DI에서 `ChatRepository`를 Mock으로 제공. 구현체 교체는 `providers.dart` 한 곳에서만 하면 되므로 아키텍처 위반 아님.

---

## 4. 디자인 시스템 컴포넌트 (프로덕트 디자이너 관점)

### 잘 쓰인 곳
- **SajuMatchCard**: 홈 "오늘의 추천", 매칭 탭 그리드에서 동일 컴포넌트 사용. 캐릭터 에셋·궁합 점수·오행 일관되게 표시.
- **SajuChip**: 매칭 필터(오행), 프로필 페이지(지역/직업/MBTI). `SajuSize.sm`, `SajuColor` 등 토큰 사용.
- **SajuButton**: 온보딩, 매칭 프로필 완성, 사주 결과, 로그인 등 CTA에 사용.
- **SajuCharacterBubble**: 온보딩 폼·매칭 프로필 스텝·사주 결과에서 캐릭터 말풍선으로 안내.
- **CompatibilityGauge**: 궁합 프리뷰 바텀시트에서 궁합 점수 시각화.
- **SajuAvatar**: 프로필 페이지, 매칭/채팅에서 프로필 이미지 + 폴백.
- **SajuCard**: 프로필 페이지 "사주 분석 완료" 블록, 기타 카드형 UI.
- **AppTheme**: `spacingMd`, `radiusLg`, `woodColor` 등 한지 팔레트·스페이싱이 여러 화면에서 사용됨.

### 개선 제안 (디자인 시스템 정합성)
- **프로필 페이지**: 상단 여백·패딩을 `AppTheme.spacingLg`(24), `AppTheme.spacingXl`(32)로 통일하면 좋음. 현재 `SizedBox(height: 20)` 등 매직 넘버가 일부 있음.
- **에러/빈 상태**: 지금은 `Icon` + `Text` + `TextButton` 조합. 디자인 원칙상 "에러 상태: 캐릭터가 당황/사과"를 적용하려면 `SajuCharacterBubble` 또는 전용 **에러/빈 상태 위젯**(캐릭터 + 메시지 + 액션)을 두고 재사용하는 편이 좋음.
- **라벨/캡션**: `Theme.of(context).textTheme.titleSmall` 등 시맨틱 토큰을 쓰면 다크/라이트·폰트 스케일 대응에 유리함. 이미 대부분 잘 맞춰져 있음.

---

## 5. 캐릭터 활용 (오행이 유니버스)

설계 문서(2026-02-24-app-design.md)의 **화면별 캐릭터 활용 맵**과 비교한 현황.

| 화면 | 설계 의도 | 현재 구현 |
|------|-----------|-----------|
| 스플래시 | 5캐릭터 → 로고 | ❌ 플레이스홀더만 |
| 온보딩 인트로 | 슬라이드별 캐릭터 | ✅ 나무리/물결이/불꼬리 |
| 온보딩 입력 | Step별 캐릭터 가이드 | ✅ SajuCharacterBubble (물결이, 쇠동이 등) |
| 매칭 프로필 완성 | Step별 캐릭터 | ✅ 불꼬리→흙순이→물결이→쇠동이→나무리 |
| 사주 분석 로딩 | 5캐릭터 회전 → 내 캐릭터 | ✅ 5캐릭터 + 오행 에너지 |
| 사주 결과 | 캐릭터가 결과 설명 | ✅ SajuCharacterBubble |
| 홈 | 내 캐릭터 인사 | ✅ 나무리 72px (오늘의 인연) |
| 매칭 카드 | 상대 오행 캐릭터 | ✅ SajuMatchCard에 characterAssetPath |
| 궁합 프리뷰 | 내+상대 캐릭터 | ✅ compatibility_preview_page |
| **프로필** | **내 캐릭터 커스터마이징 미리보기** | ❌ **캐릭터 없음** |
| 채팅 빈 상태 | 캐릭터 위로/격려 | ❌ 아이콘만 |
| 매칭 빈/에러 | 캐릭터 위로/당황 | ❌ 텍스트만 |
| 프로필 에러/다시 시도 | 캐릭터 사과 | ❌ 텍스트만 |

### 권장 조치
1. **프로필 탭**: 사용자 주도 오행(또는 기본 나무리)에 따라 **내 캐릭터 한 마리**를 헤더 근처 또는 완성도 아래에 배치. (예: 아바타 옆 또는 "사주 분석 완료" 카드 위에 64~72px 캐릭터.)
2. **빈 상태 통일**: "아직 채팅이 없어요", "프로필을 불러오지 못했어요", "해당 오행의 프로필이 없어요" 등에 **SajuCharacterBubble** 또는 공통 **EmptyStateWidget**(캐릭터 + 메시지 + 선택적 CTA) 도입.
3. **에러 상태**: "다시 시도"가 있는 에러 화면에 캐릭터 한 마리(당황/사과 포즈) 추가하면 감성 디자인 원칙에 맞음.
4. **스플래시**: 실제 스플래시 구현 시 5캐릭터 → 로고 연출 적용.

---

## 6. 액션 아이템 정리

| 우선순위 | 항목 | 담당 관점 | 상태 |
|----------|------|-----------|------|
| 1 | 프로필 탭에 "내 캐릭터" 추가 (sajuProfileId → 오행 → CharacterAssets) | 디자인 + 구현 | ✅ 완료 (2026-02-24, 기본 나무리) |
| 2 | 빈/에러 상태 공통 위젯 도입 (캐릭터 + 메시지 + 액션) | 디자인 시스템 | ✅ 완료 (SajuEmptyState, SajuErrorState) |
| 3 | 프로필·매칭·채팅 등 여백/패딩을 AppTheme 토큰으로 통일 | 디자인 시스템 | ✅ 완료 (일부 토큰 적용) |
| 4 | 매칭 상세 라우트(`/matching/:matchId`) 실제 페이지 연결 여부 결정 | 기획 + 라우팅 | ⬜ 보류 |
| 5 | 스플래시 실제 화면 구현 시 캐릭터 연출 | 디자인 + 구현 | ⬜ 예정 |

---

## 7. 결론

- **GoRouter**: 구조와 상수 사용이 잘 잡혀 있음. 플레이스홀더만 단계적으로 실제 페이지로 교체하면 됨.
- **클린 아키텍처**: presentation이 data를 직접 참조하지 않고, DI가 core에 모여 있어 규칙을 잘 지키고 있음.
- **컴포넌트**: Saju* 컴포넌트와 AppTheme가 전반적으로 잘 쓰이고 있으나, 여백/에러·빈 상태는 토큰·캐릭터를 더 끌어와서 통일할 여지가 있음.
- **캐릭터**: 온보딩·사주·매칭·홈에서는 잘 쓰이지만, **프로필 탭**과 **빈/에러 상태**에는 아직 반영되지 않았으므로, 디자이너 직군 스킬에서 말하는 "캐릭터가 앱 전체에 관통"하도록 위 액션 아이템을 적용하는 것을 추천합니다.
