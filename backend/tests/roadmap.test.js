const { describe, it } = require('node:test');
const assert = require('node:assert');
const { validateRoadmapOutput } = require('../src/schemas/roadmap');

describe('Roadmap output validation', () => {
  it('accepts valid roadmap with 5 stages', () => {
    const data = {
      stages: [
        { title: 'Stage 1', resources: ['a', 'b', 'c'] },
        { title: 'Stage 2', resources: ['d', 'e', 'f'] },
        { title: 'Stage 3', resources: ['g', 'h', 'i'] },
        { title: 'Stage 4', resources: ['j', 'k', 'l'] },
        { title: 'Stage 5', resources: ['m', 'n', 'o'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, true);
  });

  it('accepts valid roadmap with 8 stages', () => {
    const data = {
      stages: Array.from({ length: 8 }, (_, i) => ({
        title: `Stage ${i + 1}`,
        resources: ['a', 'b', 'c'],
      })),
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, true);
  });

  it('rejects roadmap with fewer than 5 stages', () => {
    const data = {
      stages: [
        { title: 'Stage 1', resources: ['a', 'b', 'c'] },
        { title: 'Stage 2', resources: ['d', 'e', 'f'] },
        { title: 'Stage 3', resources: ['g', 'h', 'i'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects roadmap with more than 8 stages', () => {
    const data = {
      stages: Array.from({ length: 9 }, (_, i) => ({
        title: `Stage ${i + 1}`,
        resources: ['a', 'b', 'c'],
      })),
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects stage with fewer than 3 resources', () => {
    const data = {
      stages: [
        { title: 'Stage 1', resources: ['a', 'b'] },
        { title: 'Stage 2', resources: ['c', 'd', 'e'] },
        { title: 'Stage 3', resources: ['f', 'g', 'h'] },
        { title: 'Stage 4', resources: ['i', 'j', 'k'] },
        { title: 'Stage 5', resources: ['l', 'm', 'n'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects stage with more than 3 resources', () => {
    const data = {
      stages: [
        { title: 'Stage 1', resources: ['a', 'b', 'c', 'd'] },
        { title: 'Stage 2', resources: ['e', 'f', 'g'] },
        { title: 'Stage 3', resources: ['h', 'i', 'j'] },
        { title: 'Stage 4', resources: ['k', 'l', 'm'] },
        { title: 'Stage 5', resources: ['n', 'o', 'p'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects empty stage title', () => {
    const data = {
      stages: [
        { title: '', resources: ['a', 'b', 'c'] },
        { title: 'Stage 2', resources: ['d', 'e', 'f'] },
        { title: 'Stage 3', resources: ['g', 'h', 'i'] },
        { title: 'Stage 4', resources: ['j', 'k', 'l'] },
        { title: 'Stage 5', resources: ['m', 'n', 'o'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects empty resource string', () => {
    const data = {
      stages: [
        { title: 'Stage 1', resources: ['', 'b', 'c'] },
        { title: 'Stage 2', resources: ['d', 'e', 'f'] },
        { title: 'Stage 3', resources: ['g', 'h', 'i'] },
        { title: 'Stage 4', resources: ['j', 'k', 'l'] },
        { title: 'Stage 5', resources: ['m', 'n', 'o'] },
      ],
    };
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });

  it('rejects missing stages field', () => {
    const data = {};
    const result = validateRoadmapOutput(data);
    assert.strictEqual(result.valid, false);
  });
});
