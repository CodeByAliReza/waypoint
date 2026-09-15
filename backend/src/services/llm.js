const SYSTEM_PROMPT = `You are a learning roadmap generator. You take a user's ambition, current level, and available hours per week, then produce a short, linear roadmap.

RULES:
- Output ONLY valid JSON. No markdown, no explanation, no wrapping.
- The JSON must match this exact schema:
{
  "stages": [
    { "title": "string", "resources": ["string", "string", "string"] }
  ]
}
- Generate exactly 5 to 8 stages.
- Each stage must have exactly 3 resources.
- Resources must be free, publicly available URLs or well-known resource names (e.g., "freeCodeCamp Python Tutorial", "MDN Web Docs - JavaScript").
- Stages should be ordered from foundational to advanced.
- Each stage title should be a clear, actionable learning milestone.
- Tailor resources to the user's stated level and weekly hours.`;

async function generateRoadmap(ambition, level, hoursPerWeek) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY not set');
  }

  const userMessage = `Ambition: ${ambition}
Current level: ${level}
Available hours per week: ${hoursPerWeek}

Generate my learning roadmap as JSON.`;

  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
      'HTTP-Referer': 'https://waypoint.app',
      'X-Title': 'Waypoint',
    },
    body: JSON.stringify({
      model: 'meta-llama/llama-3.3-70b-instruct:free',
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: userMessage },
      ],
      temperature: 0.7,
      max_tokens: 2000,
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`LLM API error (${response.status}): ${text}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content;

  if (!content) {
    throw new Error('No content in LLM response');
  }

  let parsed;
  try {
    parsed = JSON.parse(content);
  } catch {
    // Try extracting JSON from markdown code block
    const jsonMatch = content.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (jsonMatch) {
      parsed = JSON.parse(jsonMatch[1].trim());
    } else {
      throw new Error('LLM returned non-JSON content');
    }
  }

  return parsed;
}

module.exports = { generateRoadmap };
