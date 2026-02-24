-- 궁합 계산 시 추천 대상( daily_matches )의 사주 조회 허용
-- Phase 1: calculate-compatibility 연동을 위해, 나의 추천 목록에 있는 사용자의 saju_profiles SELECT 허용
create policy "saju_select_recommended" on public.saju_profiles
  for select
  using (
    user_id in (
      select recommended_id
      from public.daily_matches
      where user_id = public.current_profile_id()
    )
  );
