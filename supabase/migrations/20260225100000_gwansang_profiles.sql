-- ============================================================
-- 관상(觀相) 프로필 테이블 + 프로필 확장 + Storage 버킷
-- 참조: docs/plans/2026-02-25-gwansang-implementation.md
-- ============================================================

-- ============================================================
-- 1. gwansang_profiles 테이블
-- ============================================================
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

-- ============================================================
-- 2. profiles 테이블에 관상 컬럼 추가
-- ============================================================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS gwansang_profile_id uuid REFERENCES public.gwansang_profiles(id),
  ADD COLUMN IF NOT EXISTS animal_type text,
  ADD COLUMN IF NOT EXISTS is_gwansang_complete boolean NOT NULL DEFAULT false;

-- ============================================================
-- 3. 인덱스
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_gwansang_profiles_user_id
  ON public.gwansang_profiles(user_id);

CREATE INDEX IF NOT EXISTS idx_gwansang_profiles_animal_type
  ON public.gwansang_profiles(animal_type);

CREATE INDEX IF NOT EXISTS idx_profiles_animal_type
  ON public.profiles(animal_type);

-- ============================================================
-- 4. RLS (Row Level Security)
-- ============================================================
ALTER TABLE public.gwansang_profiles ENABLE ROW LEVEL SECURITY;

-- 본인 관상 프로필 읽기
CREATE POLICY "gwansang_select_own" ON public.gwansang_profiles
  FOR SELECT USING (user_id = public.current_profile_id());

-- 본인 관상 프로필 생성
CREATE POLICY "gwansang_insert_own" ON public.gwansang_profiles
  FOR INSERT WITH CHECK (user_id = public.current_profile_id());

-- 본인 관상 프로필 수정
CREATE POLICY "gwansang_update_own" ON public.gwansang_profiles
  FOR UPDATE USING (user_id = public.current_profile_id());

-- ============================================================
-- 5. updated_at 자동 갱신 트리거
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_gwansang_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_gwansang_updated_at ON public.gwansang_profiles;
CREATE TRIGGER trg_gwansang_updated_at
  BEFORE UPDATE ON public.gwansang_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_gwansang_updated_at();

-- ============================================================
-- 6. is_gwansang_complete 자동 계산 트리거
-- gwansang_profile_id가 설정되면 true + animal_type 동기화
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_gwansang_complete()
RETURNS TRIGGER AS $$
BEGIN
  NEW.is_gwansang_complete := (NEW.gwansang_profile_id IS NOT NULL);

  -- animal_type을 gwansang_profiles에서 동기화
  IF NEW.gwansang_profile_id IS NOT NULL AND (
    OLD.gwansang_profile_id IS NULL OR
    OLD.gwansang_profile_id IS DISTINCT FROM NEW.gwansang_profile_id
  ) THEN
    SELECT gp.animal_type INTO NEW.animal_type
    FROM public.gwansang_profiles gp
    WHERE gp.id = NEW.gwansang_profile_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_gwansang_complete ON public.profiles;
CREATE TRIGGER trg_update_gwansang_complete
  BEFORE INSERT OR UPDATE OF gwansang_profile_id ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_update_gwansang_complete();

-- ============================================================
-- 7. Storage 버킷: 관상 분석 사진
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('gwansang-photos', 'gwansang-photos', true)
ON CONFLICT (id) DO NOTHING;

-- 본인 폴더에만 업로드 가능
CREATE POLICY "gwansang_storage_insert_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'gwansang-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- 관상 사진은 공개 (매칭 프로필에 노출되므로)
CREATE POLICY "gwansang_storage_select_public" ON storage.objects
  FOR SELECT USING (bucket_id = 'gwansang-photos');
