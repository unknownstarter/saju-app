# 두 퍼널 아키텍처 — 사주 퍼널 + 소개팅 퍼널

> **작성일**: 2026-02-25
> **승인**: 노아님
> **참조**: 테스크마스터 `docs/plans/2026-02-24-task-master.md`, 설계 `docs/plans/2026-02-25-high-group-saju-persistence-design.md`

---

## 1. 문제 정의

### 두 퍼널 구조

앱의 유저 플로우는 두 개의 독립적인 퍼널로 나뉜다:

| 퍼널 | 트리거 | 수집 정보 | 완료 플래그 |
|------|--------|----------|------------|
| **A: 사주 퍼널** | 회원가입 | 닉네임, 성별, 생년월일시 → 사주 분석 | `is_saju_complete` |
| **B: 소개팅 퍼널** | 첫 무료 매칭 확인 시 | 사진, 직업, 지역, 키, 자기소개 등 | `is_matchable` |

### 현재 상태 (GAP)

1. **DB 컬럼 9개 누락**: `email`, `phone`, `mbti`, `drinking`, `smoking`, `religion`, `dating_style`, `is_selfie_verified`, `is_profile_complete` — UserEntity/UserModel에는 있지만 DB에 없음
2. **게이트 로직 부재**: 라우터에 퍼널 게이트가 없어서 사주 미완료 유저도 매칭 탭 접근 가능
3. **RLS 정책 부족**: `profiles_select_own`만 존재 → 매칭 시 상대방 프로필 조회 불가
4. **완료 플래그 없음**: `is_saju_complete`, `is_matchable` 컬럼/트리거 없음

---

## 2. 필드 분류

### 퍼널 A: 사주 퍼널 (필수)

| DB 컬럼 | 타입 | 필수 | 수집 시점 | 현재 DB 상태 |
|---------|------|------|----------|------------|
| `name` | text | ✅ | 온보딩 | ✅ 있음 |
| `gender` | text | ✅ | 온보딩 | ✅ 있음 |
| `birth_date` | date | ✅ | 온보딩 | ✅ 있음 |
| `birth_time` | time | 선택 | 온보딩 | ✅ 있음 |
| `saju_profile_id` | uuid FK | 자동 | 사주 분석 완료 | ✅ 있음 (migration 추가됨) |
| `dominant_element` | text | 자동 | 사주 분석 완료 | ✅ 있음 |
| `character_type` | text | 자동 | 사주 분석 완료 | ✅ 있음 |

### 퍼널 B: 소개팅 퍼널 (매칭 활성화용)

| DB 컬럼 | 타입 | 필수/선택 | 수집 시점 | 현재 DB 상태 |
|---------|------|----------|----------|------------|
| `profile_images` | text[] | **필수** (2장+) | 매칭 프로필 Step 1 | ✅ 있음 |
| `occupation` | text | **필수** | 매칭 프로필 Step 2 | ✅ 있음 |
| `location` | text | **필수** | 매칭 프로필 Step 2 | ✅ 있음 |
| `height` | int | **필수** | 매칭 프로필 Step 2 | ✅ 있음 |
| `bio` | text | **필수** | 매칭 프로필 Step 3 | ✅ 있음 |
| `interests` | text[] | **필수** (3개+) | 매칭 프로필 Step 3 | ✅ 있음 |
| `mbti` | text | 선택 | 매칭 프로필 Step 3 | ❌ 누락 |
| `drinking` | text | 선택 | 매칭 프로필 Step 4 | ❌ 누락 |
| `smoking` | text | 선택 | 매칭 프로필 Step 4 | ❌ 누락 |
| `religion` | text | 선택 | 매칭 프로필 Step 4 | ❌ 누락 |
| `dating_style` | text | 선택 (AI 제안) | 사주 분석 후 자동 | ❌ 누락 |

### 인증/상태 컬럼

| DB 컬럼 | 타입 | 용도 | 현재 DB 상태 |
|---------|------|------|------------|
| `email` | text | 소셜 로그인 이메일 | ❌ 누락 |
| `phone` | text | SMS 인증 | ❌ 누락 |
| `is_selfie_verified` | boolean | 셀카 인증 완료 | ❌ 누락 |
| `is_profile_complete` | boolean | 앱 수준 프로필 완성 플래그 | ❌ 누락 |
| `is_saju_complete` | boolean | 사주 퍼널 완료 (트리거) | ❌ 누락 |
| `is_matchable` | boolean | 매칭 풀 노출 가능 (트리거) | ❌ 누락 |

---

## 3. 설계

### 3.1 DB 마이그레이션

```sql
-- 누락 컬럼 추가
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email text,
  ADD COLUMN IF NOT EXISTS phone text,
  ADD COLUMN IF NOT EXISTS mbti text CHECK (mbti IN (
    'ISTJ','ISFJ','INFJ','INTJ','ISTP','ISFP','INFP','INTP',
    'ESTP','ESFP','ENFP','ENTP','ESTJ','ESFJ','ENFJ','ENTJ'
  )),
  ADD COLUMN IF NOT EXISTS drinking text CHECK (drinking IN ('none','sometimes','often')),
  ADD COLUMN IF NOT EXISTS smoking text CHECK (smoking IN ('nonSmoker','smoker','eCigarette')),
  ADD COLUMN IF NOT EXISTS religion text CHECK (religion IN ('none','christian','catholic','buddhist','other')),
  ADD COLUMN IF NOT EXISTS dating_style text,
  ADD COLUMN IF NOT EXISTS is_selfie_verified boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_profile_complete boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_saju_complete boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_matchable boolean NOT NULL DEFAULT false;
```

### 3.2 DB 트리거

#### `is_saju_complete` 트리거

```sql
CREATE OR REPLACE FUNCTION public.fn_update_saju_complete()
RETURNS trigger AS $$
BEGIN
  NEW.is_saju_complete := (NEW.saju_profile_id IS NOT NULL);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_saju_complete
  BEFORE INSERT OR UPDATE OF saju_profile_id ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.fn_update_saju_complete();
```

#### `is_matchable` 트리거

```sql
CREATE OR REPLACE FUNCTION public.fn_update_matchable()
RETURNS trigger AS $$
BEGIN
  NEW.is_matchable := (
    NEW.is_saju_complete = true
    AND NEW.is_profile_complete = true
    AND cardinality(NEW.profile_images) >= 2
    AND NEW.occupation IS NOT NULL
    AND NEW.location IS NOT NULL
    AND NEW.height IS NOT NULL
    AND NEW.bio IS NOT NULL
    AND NEW.deleted_at IS NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_matchable
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.fn_update_matchable();
```

### 3.3 RLS 정책 추가

```sql
-- 매칭 가능한 상대 프로필 읽기 (매칭 풀)
CREATE POLICY "profiles_select_matchable" ON public.profiles
  FOR SELECT USING (
    auth_id = auth.uid()  -- 본인
    OR (
      is_matchable = true
      AND deleted_at IS NULL
      AND id != public.current_profile_id()
    )
  );

-- 기존 profiles_select_own 정책 대체 (DROP + CREATE)
-- 새 정책이 본인 + matchable 모두 커버
```

**주의**: 기존 `profiles_select_own` 정책을 DROP하고 위의 통합 정책으로 대체해야 합니다. 두 정책이 공존하면 OR로 동작하므로, 통합 정책 하나로 가는 것이 안전합니다.

### 3.4 라우터 게이트 로직

```
redirect(context, state):
  1. 미로그인 + 보호 경로 → /login
  2. 로그인 + splash/login → /home
  3. 로그인 + 매칭 탭 접근 + !is_saju_complete → /saju-analysis (사주 먼저)
  4. 로그인 + 매칭 탭 접근 + !is_profile_complete → /matching-profile (프로필 먼저)
```

#### 구현 방법

라우터의 redirect에서 유저 상태를 체크하려면 현재 유저의 `is_saju_complete`, `is_profile_complete` 정보가 필요합니다. 이를 위해:

1. `currentUserProvider` — 현재 로그인 유저의 프로필 정보를 캐시하는 프로바이더
2. 라우터 redirect에서 이 프로바이더의 값을 읽어 게이트 판단

**단, MVP 단계에서는 클라이언트 사이드 게이트로 충분합니다.**

### 3.5 UserEntity.isMatchable 정렬

현재 `UserEntity.isMatchable`은 클라이언트 계산:
```dart
bool get isMatchable =>
    isActive && isProfileComplete &&
    profileImageUrls.length >= 2 &&
    height != null && occupation != null && location != null;
```

DB 트리거의 `is_matchable`과 조건이 동일해야 합니다. DB 트리거에 `bio IS NOT NULL`과 `interests` 조건도 있으므로 UserEntity도 정렬합니다.

---

## 4. 구현 순서

### Phase A: DB 기반 (마이그레이션 + 트리거 + RLS)
1. 마이그레이션 파일 생성 (누락 컬럼 + 트리거 + RLS)

### Phase B: Flutter 데이터 레이어 정렬
2. `UserEntity.isMatchable` 조건 정렬 (DB 트리거와 동일하게)
3. `UserModel.fromJson/toJson` 에서 새 컬럼 반영 확인

### Phase C: 라우터 게이트 로직
4. `currentUserProvider` 추가 (이미 있으면 활용)
5. `app_router.dart` redirect에 퍼널 게이트 추가

### Phase D: 매칭 프로필 페이지 저장 로직 정렬
6. `matchingProfileNotifier.saveMatchingProfile`에서 `is_profile_complete = true` 설정

### Phase E: 검증
7. `flutter analyze` + `flutter test` 통과 확인
8. 전체 플로우 검증: 온보딩 → 사주 → 매칭 탭(게이트) → 매칭 프로필 → 매칭 풀

---

## 5. 와우 모먼트

| 시점 | 와우 요소 |
|------|----------|
| 사주 완료 후 매칭 탭 첫 접근 | "사주가 완성됐어! 이제 운명의 상대를 만나러 가볼까?" 캐릭터 안내 |
| 프로필 완성 → 첫 매칭 카드 | "드디어 매칭 풀에 입장! 오늘의 인연을 확인해보세요" |
| 프로필 완성도 100% | 축하 애니메이션 + 캐릭터 리액션 |
