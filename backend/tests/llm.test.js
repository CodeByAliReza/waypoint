const { describe, it } = require('node:test');
const assert = require('node:assert');

describe('LLM service', () => {
  it('throws if OPENROUTER_API_KEY not set', async () => {
    const original = process.env.OPENROUTER_API_KEY;
    delete process.env.OPENROUTER_API_KEY;

    const { generateRoadmap } = require('../src/services/llm');
    await assert.rejects(
      () => generateRoadmap('test', 'beginner', 5),
      /OPENROUTER_API_KEY not set/
    );

    process.env.OPENROUTER_API_KEY = original;
  });
});
