// =============================================================================
// 사주팔자 (Four Pillars) Calculator — Supabase Edge Function
// =============================================================================
// 만세력 기준 정확한 사주 계산. 한국천문연구원(KASI) 데이터 기반
// @fullstackfamily/manseryeok 라이브러리 사용 (절기·음력·진태양시 보정 포함).
// =============================================================================

import { calculateSaju, lunarToSolar } from "npm:@fullstackfamily/manseryeok@1.0.7";

// ---------------------------------------------------------------------------
// 오행 매핑 (천간·지지 → wood/fire/earth/metal/water)
// ---------------------------------------------------------------------------
type FiveElement = "wood" | "fire" | "earth" | "metal" | "water";

const STEM_TO_ELEMENT: Record<string, FiveElement> = {
  갑: "wood", 을: "wood",
  병: "fire", 정: "fire",
  무: "earth", 기: "earth",
  경: "metal", 신: "metal",
  임: "water", 계: "water",
};

const BRANCH_TO_ELEMENT: Record<string, FiveElement> = {
  인: "wood", 묘: "wood",
  사: "fire", 오: "fire",
  축: "earth", 진: "earth", 미: "earth", 술: "earth",
  신: "metal", 유: "metal",
  자: "water", 해: "water",
};

function pillarToStemBranch(pillarStr: string): { stem: string; branch: string } {
  if (!pillarStr || pillarStr.length < 2) {
    return { stem: "갑", branch: "자" };
  }
  return {
    stem: pillarStr[0]!,
    branch: pillarStr[1]!,
  };
}

function countFiveElements(pillarStrs: string[]): Record<FiveElement, number> {
  const counts: Record<FiveElement, number> = {
    wood: 0, fire: 0, earth: 0, metal: 0, water: 0,
  };
  for (const s of pillarStrs) {
    const { stem, branch } = pillarToStemBranch(s);
    const se = STEM_TO_ELEMENT[stem];
    const be = BRANCH_TO_ELEMENT[branch];
    if (se) counts[se]++;
    if (be) counts[be]++;
  }
  return counts;
}

function getDominantElement(dayPillarStr: string): FiveElement {
  const { stem } = pillarToStemBranch(dayPillarStr);
  return STEM_TO_ELEMENT[stem] ?? "wood";
}

// ---------------------------------------------------------------------------
// Request validation
// ---------------------------------------------------------------------------
interface RequestBody {
  birthDate: string;
  birthTime: string | null;
  isLunar: boolean;
  isLeapMonth?: boolean;
}

function validateRequest(body: unknown): RequestBody {
  if (!body || typeof body !== "object") {
    throw new Error("Request body must be a JSON object");
  }

  const { birthDate, birthTime, isLunar, isLeapMonth } = body as Record<string, unknown>;

  if (!birthDate || typeof birthDate !== "string") {
    throw new Error("birthDate is required and must be a string in YYYY-MM-DD format");
  }

  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  if (!dateRegex.test(birthDate)) {
    throw new Error("birthDate must be in YYYY-MM-DD format");
  }

  const [yearStr, monthStr, dayStr] = birthDate.split("-");
  const year = parseInt(yearStr, 10);
  const month = parseInt(monthStr, 10);
  const day = parseInt(dayStr, 10);

  if (year < 1900 || year > 2050) {
    throw new Error("birthDate year must be between 1900 and 2050 (KASI 지원 범위)");
  }
  if (month < 1 || month > 12) {
    throw new Error("birthDate month must be between 1 and 12");
  }
  if (day < 1 || day > 31) {
    throw new Error("birthDate day must be between 1 and 31");
  }

  if (birthTime !== null && birthTime !== undefined) {
    if (typeof birthTime !== "string") {
      throw new Error("birthTime must be a string in HH:mm format or null");
    }
    const timeRegex = /^\d{2}:\d{2}$/;
    if (!timeRegex.test(birthTime)) {
      throw new Error("birthTime must be in HH:mm format");
    }
    const [hourStr, minStr] = birthTime.split(":");
    const hour = parseInt(hourStr, 10);
    const min = parseInt(minStr, 10);
    if (hour < 0 || hour > 23 || min < 0 || min > 59) {
      throw new Error("birthTime hour must be 0-23 and minute must be 0-59");
    }
  }

  return {
    birthDate,
    birthTime: (birthTime as string | null) ?? null,
    isLunar: typeof isLunar === "boolean" ? isLunar : false,
    isLeapMonth: typeof isLeapMonth === "boolean" ? isLeapMonth : false,
  };
}

// ---------------------------------------------------------------------------
// CORS
// ---------------------------------------------------------------------------
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed. Use POST." }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  try {
    const body = await req.json();
    const { birthDate, birthTime, isLunar, isLeapMonth } = validateRequest(body);

    const [yearStr, monthStr, dayStr] = birthDate.split("-");
    let year = parseInt(yearStr, 10);
    let month = parseInt(monthStr, 10);
    let day = parseInt(dayStr, 10);

    // 음력 → 양력 변환 (만세력 라이브러리 KASI 데이터 기반)
    if (isLunar) {
      const solar = lunarToSolar(year, month, day, isLeapMonth ?? false);
      year = solar.solar.year;
      month = solar.solar.month;
      day = solar.solar.day;
    }

    let hour = 0;
    let minute = 0;
    if (birthTime) {
      const [h, m] = birthTime.split(":").map((s) => parseInt(s, 10));
      hour = h ?? 0;
      minute = m ?? 0;
    }

    // 만세력 기반 사주 계산 (진태양시 보정·절기 기준 월주·KASI 데이터)
    const saju = calculateSaju(year, month, day, hour, minute);

    const yearSb = pillarToStemBranch(saju.yearPillar);
    const monthSb = pillarToStemBranch(saju.monthPillar);
    const daySb = pillarToStemBranch(saju.dayPillar);
    // 생시를 알 때만 시주 반환 (유저가 시간 미입력 시 null)
    const hourSb =
      birthTime != null && saju.hourPillar
        ? pillarToStemBranch(saju.hourPillar)
        : null;

    const pillarStrs = [saju.yearPillar, saju.monthPillar, saju.dayPillar];
    if (hourSb) pillarStrs.push(saju.hourPillar!);
    const fiveElements = countFiveElements(pillarStrs);
    const dominantElement = getDominantElement(saju.dayPillar);

    const response: Record<string, unknown> = {
      yearPillar: { stem: yearSb.stem, branch: yearSb.branch },
      monthPillar: { stem: monthSb.stem, branch: monthSb.branch },
      dayPillar: { stem: daySb.stem, branch: daySb.branch },
      hourPillar: hourSb
        ? { stem: hourSb.stem, branch: hourSb.branch }
        : null,
      fiveElements,
      dominantElement,
      birthDate: `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`,
      birthTime: birthTime ?? null,
      isLunar,
    };

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : "Internal server error";
    const status =
      message.startsWith("birthDate") ||
      message.startsWith("birthTime") ||
      message.startsWith("Request body")
        ? 400
        : 500;

    return new Response(JSON.stringify({ error: message }), {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
