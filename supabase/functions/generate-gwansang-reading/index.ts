/// 관상(觀相) AI 해석 Edge Function
///
/// 얼굴 측정값 + 사주 데이터를 기반으로 Claude Haiku 4.5를 호출하여
/// 동물상, 성격/연애 해석, 사주 시너지 등을 생성한다.
///
/// 페르소나: "도현 선생" — 30년 경력 관상 전문가
/// 프레임워크: 관상학 삼정(三停)/오관(五官)
/// 결과 톤: 80% 긍정 / 20% 성장 포인트

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// =============================================================================
// 타입 정의
// =============================================================================

interface FaceMeasurements {
  faceWidthToHeight: number;
  eyeDistance: number;
  noseToMouthRatio: number;
  jawWidth: number;
  foreheadRatio: number;
  eyeSize: number;
  mouthWidth: number;
  facialSymmetry: number;
  browArchAngle: number;
}

interface SajuData {
  dominantElement: string;
  yearPillar?: { heavenlyStem: string; earthlyBranch: string };
  dayPillar?: { heavenlyStem: string; earthlyBranch: string };
}

interface RequestBody {
  faceMeasurements: FaceMeasurements;
  sajuData?: SajuData;
  gender?: string;
  age?: number;
}

interface GwansangReadingResponse {
  animalType: string;
  headline: string;
  personalitySummary: string;
  romanceSummary: string;
  sajuSynergy: string;
  charmKeywords: string[];
  elementModifier: string | null;
  detailedReading: string | null;
}

// =============================================================================
// 동물상 매핑
// =============================================================================

const ANIMAL_TYPES = [
  "cat", "dog", "fox", "rabbit", "deer",
  "bear", "wolf", "horse", "eagle", "dolphin",
] as const;

const ANIMAL_LABELS: Record<string, string> = {
  cat: "고양이상",
  dog: "강아지상",
  fox: "여우상",
  rabbit: "토끼상",
  deer: "사슴상",
  bear: "곰상",
  wolf: "늑대상",
  horse: "말상",
  eagle: "독수리상",
  dolphin: "돌고래상",
};

// =============================================================================
// 오행 보정자 매핑
// =============================================================================

const ELEMENT_MODIFIERS: Record<string, string> = {
  wood: "木 기운의",
  fire: "火 기운의",
  earth: "土 기운의",
  metal: "金 기운의",
  water: "水 기운의",
};

// =============================================================================
// 프롬프트 빌더
// =============================================================================

function buildSystemPrompt(): string {
  return `당신은 "도현 선생"입니다. 30년 경력의 관상 전문가로, 전통 관상학(삼정/오관 프레임워크)과 현대 심리학을 융합한 해석을 합니다.

## 역할
- 얼굴 측정값을 기반으로 동물상을 판별하고, 성격/연애 스타일/매력 포인트를 해석합니다.
- 사주 데이터가 제공되면, 관상과 사주의 시너지를 분석합니다.

## 응답 규칙
반드시 아래 JSON 형식으로만 응답하세요. JSON 외의 텍스트는 절대 포함하지 마세요.

{
  "animalType": "동물상 영어 키 (cat/dog/fox/rabbit/deer/bear/wolf/horse/eagle/dolphin 중 하나)",
  "headline": "한줄 헤드라인 (15~30자)",
  "personalitySummary": "성격 해석 (100~200자)",
  "romanceSummary": "연애 스타일 해석 (100~200자)",
  "sajuSynergy": "사주×관상 시너지 해석 (80~150자, 사주 데이터 없으면 관상 단독 해석)",
  "charmKeywords": ["매력키워드1", "매력키워드2", "매력키워드3"],
  "detailedReading": "상세 관상 해석 (200~400자, 삼정/오관 프레임워크 기반)"
}

## 관상학 프레임워크
1. 삼정(三停): 상정(이마)=초년운, 중정(코)=중년운, 하정(턱)=말년운
2. 오관(五官): 눈=감찰관, 코=심판관, 입=출납관, 귀=채청관, 눈썹=보수관

## 동물상 판별 기준
- 얼굴 너비/높이, 눈 크기, 코-입 비율, 턱 너비, 눈썹 각도, 대칭도 등을 종합 분석
- 하나의 동물상을 명확히 선택할 것

## 톤 & 매너
- 80% 긍정적 (매력 포인트, 강점 위주)
- 20% 성장 포인트 (부드러운 표현으로)
- 따뜻하고 희망적인 톤
- 연애/인간관계 관점 강조
- charmKeywords는 정확히 3개, 한국어로, 매력적인 표현으로`;
}

function buildUserPrompt(body: RequestBody): string {
  const { faceMeasurements: fm, sajuData, gender, age } = body;

  const measurementsText = `
얼굴 측정값:
- 얼굴 너비/높이 비율: ${fm.faceWidthToHeight.toFixed(3)}
- 눈 간격: ${fm.eyeDistance.toFixed(3)}
- 코-입 비율: ${fm.noseToMouthRatio.toFixed(3)}
- 턱 너비: ${fm.jawWidth.toFixed(3)}
- 이마 비율(상정): ${fm.foreheadRatio.toFixed(3)}
- 눈 크기: ${fm.eyeSize.toFixed(3)}
- 입 너비: ${fm.mouthWidth.toFixed(3)}
- 좌우 대칭도: ${fm.facialSymmetry.toFixed(3)}
- 눈썹 아치 각도: ${fm.browArchAngle.toFixed(1)}°`;

  let sajuText = "사주 데이터: 미제공 (관상 단독 분석)";
  if (sajuData) {
    const parts = [`주도 오행: ${sajuData.dominantElement}`];
    if (sajuData.yearPillar) {
      parts.push(`년주: ${sajuData.yearPillar.heavenlyStem}${sajuData.yearPillar.earthlyBranch}`);
    }
    if (sajuData.dayPillar) {
      parts.push(`일주: ${sajuData.dayPillar.heavenlyStem}${sajuData.dayPillar.earthlyBranch}`);
    }
    sajuText = `사주 데이터:\n${parts.join("\n")}`;
  }

  const demographicText = [
    gender ? `성별: ${gender === "male" ? "남성" : "여성"}` : null,
    age ? `나이: ${age}세` : null,
  ]
    .filter(Boolean)
    .join("\n");

  return `${measurementsText}

${sajuText}
${demographicText ? `\n${demographicText}` : ""}

위 얼굴 측정값과 사주 데이터를 기반으로 관상 분석 결과를 JSON으로 응답해주세요.`;
}

// =============================================================================
// 검증
// =============================================================================

function validateRequest(body: RequestBody): string | null {
  if (!body.faceMeasurements) {
    return "faceMeasurements is required";
  }

  const fm = body.faceMeasurements;
  const requiredFields: (keyof FaceMeasurements)[] = [
    "faceWidthToHeight",
    "eyeDistance",
    "noseToMouthRatio",
    "jawWidth",
    "foreheadRatio",
    "eyeSize",
    "mouthWidth",
    "facialSymmetry",
    "browArchAngle",
  ];

  for (const field of requiredFields) {
    if (typeof fm[field] !== "number" || isNaN(fm[field])) {
      return `faceMeasurements.${field} must be a valid number`;
    }
  }

  return null;
}

// =============================================================================
// Claude 응답 파싱
// =============================================================================

function parseClaudeResponse(
  text: string,
  sajuData?: SajuData,
): GwansangReadingResponse {
  // JSON 블록 추출
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    throw new Error("No JSON object found in Claude response");
  }

  const parsed = JSON.parse(jsonMatch[0]);

  // animalType 검증
  if (!ANIMAL_TYPES.includes(parsed.animalType)) {
    throw new Error(
      `Invalid animalType: ${parsed.animalType}. Must be one of: ${ANIMAL_TYPES.join(", ")}`,
    );
  }

  // 필수 문자열 필드 검증
  for (const field of [
    "headline",
    "personalitySummary",
    "romanceSummary",
    "sajuSynergy",
  ]) {
    if (typeof parsed[field] !== "string" || parsed[field].length < 10) {
      throw new Error(`${field} must be a string with at least 10 characters`);
    }
  }

  // charmKeywords 검증
  if (
    !Array.isArray(parsed.charmKeywords) ||
    parsed.charmKeywords.length !== 3
  ) {
    throw new Error("charmKeywords must be an array of exactly 3 strings");
  }

  // 오행 보정자 계산
  const elementModifier = sajuData?.dominantElement
    ? ELEMENT_MODIFIERS[sajuData.dominantElement] ?? null
    : null;

  return {
    animalType: parsed.animalType,
    headline: parsed.headline,
    personalitySummary: parsed.personalitySummary,
    romanceSummary: parsed.romanceSummary,
    sajuSynergy: parsed.sajuSynergy,
    charmKeywords: parsed.charmKeywords.map((k: unknown) => String(k)),
    elementModifier,
    detailedReading:
      typeof parsed.detailedReading === "string"
        ? parsed.detailedReading
        : null,
  };
}

// =============================================================================
// 메인 핸들러
// =============================================================================

Deno.serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  // POST만 허용
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // API 키 확인
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({
        error: "Server configuration error: missing API key",
      }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // 요청 바디 파싱
  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid JSON in request body" }),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // 입력 검증
  const validationError = validateRequest(body);
  if (validationError) {
    return new Response(
      JSON.stringify({ error: validationError }),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // Claude API 호출
  let claudeResponse: Response;
  try {
    claudeResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 2048,
        system: buildSystemPrompt(),
        messages: [
          {
            role: "user",
            content: buildUserPrompt(body),
          },
        ],
      }),
    });
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: "Failed to connect to Claude API",
        detail: err instanceof Error ? err.message : "Unknown error",
      }),
      {
        status: 502,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // Claude 응답 상태 확인
  if (!claudeResponse.ok) {
    let detail = "";
    try {
      const errorBody = await claudeResponse.text();
      detail = errorBody;
    } catch {
      detail = `HTTP ${claudeResponse.status}`;
    }
    return new Response(
      JSON.stringify({
        error: "Claude API returned an error",
        status: claudeResponse.status,
        detail,
      }),
      {
        status: 502,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // Claude 응답 파싱
  let claudeData: {
    content: Array<{ type: string; text: string }>;
  };
  try {
    claudeData = await claudeResponse.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "Failed to parse Claude API response" }),
      {
        status: 502,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // 텍스트 블록 추출
  const textBlock = claudeData.content?.find(
    (block: { type: string }) => block.type === "text",
  );
  if (!textBlock || !textBlock.text) {
    return new Response(
      JSON.stringify({ error: "No text content in Claude API response" }),
      {
        status: 502,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // 결과 파싱 및 반환
  let result: GwansangReadingResponse;
  try {
    result = parseClaudeResponse(textBlock.text, body.sajuData);
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: "Failed to parse AI gwansang reading result",
        detail: err instanceof Error ? err.message : "Unknown parse error",
        rawResponse: textBlock.text,
      }),
      {
        status: 502,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
});
