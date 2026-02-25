-- ============================================================
-- 두 퍼널 아키텍처: 누락 컬럼 + 트리거 + RLS 통합
-- 참조: docs/plans/2026-02-25-two-funnel-architecture-design.md
-- ============================================================

-- ============================================================
-- 1. 누락 컬럼 추가
-- ============================================================
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
  ADD COLUMN IF NOT EXISTS is_profile_complete boolean NOT NULL DEFAULT false;

-- ============================================================
-- 2. 퍼널 완료 플래그 컬럼
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_saju_complete boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_matchable boolean NOT NULL DEFAULT false;

-- ============================================================
-- 3. 트리거: is_saju_complete 자동 계산
-- saju_profile_id가 설정되면 true
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_saju_complete()
RETURNS trigger AS $$
BEGIN
  NEW.is_saju_complete := (NEW.saju_profile_id IS NOT NULL);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_saju_complete ON public.profiles;
CREATE TRIGGER trg_update_saju_complete
  BEFORE INSERT OR UPDATE OF saju_profile_id ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.fn_update_saju_complete();

-- ============================================================
-- 4. 트리거: is_matchable 자동 계산
-- 사주 완료 + 프로필 완성 + 필수 필드 채워짐 + 미삭제
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_matchable()
RETURNS trigger AS $$
BEGIN
  -- is_saju_complete도 여기서 최신화 (saju_profile_id 변경 시 두 트리거 순서 무관하게)
  NEW.is_saju_complete := (NEW.saju_profile_id IS NOT NULL);

  NEW.is_matchable := (
    NEW.is_saju_complete = true
    AND NEW.is_profile_complete = true
    AND cardinality(COALESCE(NEW.profile_images, '{}')) >= 2
    AND NEW.occupation IS NOT NULL
    AND NEW.location IS NOT NULL
    AND NEW.height IS NOT NULL
    AND NEW.bio IS NOT NULL
    AND NEW.deleted_at IS NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_matchable ON public.profiles;
CREATE TRIGGER trg_update_matchable
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.fn_update_matchable();

-- ============================================================
-- 5. 기존 데이터 플래그 보정 (이미 사주 완료된 유저가 있을 경우)
-- ============================================================
UPDATE public.profiles
SET is_saju_complete = (saju_profile_id IS NOT NULL)
WHERE is_saju_complete = false AND saju_profile_id IS NOT NULL;

-- ============================================================
-- 6. RLS 정책: profiles 읽기 통합
-- 기존 profiles_select_own → 본인 + matchable 상대 통합
-- ============================================================
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;

CREATE POLICY "profiles_select_own_or_matchable" ON public.profiles
  FOR SELECT USING (
    auth_id = auth.uid()                          -- 본인 프로필
    OR (
      is_matchable = true                         -- 매칭 풀에 있는 상대
      AND deleted_at IS NULL
      AND id != public.current_profile_id()       -- 자기 자신 제외
    )
  );

-- 매칭 성사 상대 전체 프로필 읽기 (is_matchable이 아니어도)
CREATE POLICY "profiles_select_matched" ON public.profiles
  FOR SELECT USING (
    id IN (
      SELECT CASE
        WHEN user1_id = public.current_profile_id() THEN user2_id
        ELSE user1_id
      END
      FROM public.matches
      WHERE (user1_id = public.current_profile_id() OR user2_id = public.current_profile_id())
        AND unmatched_at IS NULL
    )
  );

-- ============================================================
-- 7. 인덱스: 매칭 풀 쿼리 최적화
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_profiles_matchable
  ON public.profiles(is_matchable)
  WHERE is_matchable = true AND deleted_at IS NULL;
